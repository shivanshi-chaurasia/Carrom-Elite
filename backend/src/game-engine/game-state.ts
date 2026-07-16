import {
  GameState, CoinState, PlayerScore, GameConfig, CoinType,
  QueenState, WinReason, MoveType, GameMoveInput,
} from './types';

const DEFAULT_CONFIG: GameConfig = {
  targetScore: 21,
  turnTimeLimit: 30000,
  maxTurns: 200,
  pointsPerCoin: 1,
  queenPoints: 3,
  foulPenalty: 1,
  coinsPerColor: 9,
};

export class GameStateMachine {
  private state: GameState;
  private config: GameConfig;
  private playerIds: string[];

  constructor(playerIds: string[], config?: Partial<GameConfig>) {
    this.config = { ...DEFAULT_CONFIG, ...config };
    this.playerIds = playerIds;
    this.state = this.initializeState();
  }

  static fromSerializedState(serialized: Record<string, unknown>, playerIds: string[]): GameStateMachine {
    const machine = new GameStateMachine(playerIds);

    const coins = (serialized.coins as any[]) || [];
    const scores = (serialized.scores as any[]) || [];

    machine.state.coins = coins.map((c: any) => ({
      id: c.id,
      type: c.type as CoinType,
      initialPosition: c.initialPosition || { x: 0, y: 0 },
      pocketed: c.pocketed,
      pocketedByUserId: c.pocketedByUserId,
      pocketedAtTurn: c.pocketedAtTurn,
    }));

    const scoresMap: Record<string, PlayerScore> = {};
    for (const s of scores) {
      scoresMap[s.userId] = {
        userId: s.userId,
        points: s.points || 0,
        pocketedBlack: s.pocketedBlack || 0,
        pocketedWhite: s.pocketedWhite || 0,
        queenPocketed: s.queenPocketed || false,
        queenCovered: s.queenCovered || false,
        fouls: s.fouls || 0,
        isConnected: s.isConnected !== false,
      };
    }
    machine.state.scores = scoresMap;

    machine.state.currentTurnUserId = serialized.currentTurnUserId as string || null;
    machine.state.turnNumber = (serialized.turnNumber as number) || 1;
    machine.state.turnStartTime = (serialized.turnStartTime as number) || Date.now();
    machine.state.turnTimeLimit = (serialized.turnTimeLimit as number) || DEFAULT_CONFIG.turnTimeLimit;
    machine.state.queenState = (serialized.queenState as QueenState) || QueenState.ON_BOARD;
    machine.state.queenLastPocketedByUserId = serialized.queenLastPocketedByUserId as string;
    machine.state.isComplete = serialized.isComplete as boolean || false;
    machine.state.winnerId = serialized.winnerId as string;
    machine.state.winReason = serialized.winReason as WinReason;
    machine.state.startedAt = (serialized.startedAt as number) || Date.now();
    machine.state.lastMoveAt = (serialized.lastMoveAt as number) || Date.now();

    return machine;
  }

  private initializeState(): GameState {
    const coins: CoinState[] = [];
    let id = 0;

    for (let i = 0; i < this.config.coinsPerColor; i++) {
      coins.push({
        id: `black-${id++}`,
        type: CoinType.BLACK,
        initialPosition: { x: 0, y: 0 },
        pocketed: false,
      });
    }

    for (let i = 0; i < this.config.coinsPerColor; i++) {
      coins.push({
        id: `white-${id++}`,
        type: CoinType.WHITE,
        initialPosition: { x: 0, y: 0 },
        pocketed: false,
      });
    }

    coins.push({
      id: `red-${id++}`,
      type: CoinType.RED,
      initialPosition: { x: 0, y: 0 },
      pocketed: false,
    });

    const scores: Record<string, PlayerScore> = {};
    for (const userId of this.playerIds) {
      scores[userId] = {
        userId,
        points: 0,
        pocketedBlack: 0,
        pocketedWhite: 0,
        queenPocketed: false,
        queenCovered: false,
        fouls: 0,
        isConnected: true,
      };
    }

    return {
      coins,
      scores,
      currentTurnUserId: this.playerIds[0],
      turnNumber: 1,
      turnStartTime: Date.now(),
      turnTimeLimit: this.config.turnTimeLimit,
      queenState: QueenState.ON_BOARD,
      isComplete: false,
      startedAt: Date.now(),
      lastMoveAt: Date.now(),
    };
  }

  getState(): Readonly<GameState> {
    return this.state;
  }

  getSerializableState(): Record<string, unknown> {
    return {
      coins: this.state.coins.map(c => ({
        id: c.id,
        type: c.type,
        pocketed: c.pocketed,
        pocketedByUserId: c.pocketedByUserId,
      })),
      scores: Object.values(this.state.scores).map(s => ({
        userId: s.userId,
        points: s.points,
        pocketedBlack: s.pocketedBlack,
        pocketedWhite: s.pocketedWhite,
        queenPocketed: s.queenPocketed,
        fouls: s.fouls,
      })),
      currentTurnUserId: this.state.currentTurnUserId,
      turnNumber: this.state.turnNumber,
      queenState: this.state.queenState,
      isComplete: this.state.isComplete,
      winnerId: this.state.winnerId,
      winReason: this.state.winReason,
    };
  }

  validateMove(input: GameMoveInput): { valid: boolean; error?: string } {
    if (this.state.isComplete) {
      return { valid: false, error: 'Match already completed' };
    }

    if (this.state.currentTurnUserId !== input.userId) {
      return { valid: false, error: 'Not your turn' };
    }

    if (Date.now() - this.state.turnStartTime > this.config.turnTimeLimit) {
      return { valid: false, error: 'Turn time expired' };
    }

    if (input.moveType === MoveType.STRIKE) {
      const data = input.moveData;
      if (data.force < 0 || data.force > 100) {
        return { valid: false, error: 'Invalid force value' };
      }
      if (data.aimAngle < 0 || data.aimAngle > 360) {
        return { valid: false, error: 'Invalid aim angle' };
      }
    }

    return { valid: true };
  }

  applyMove(input: GameMoveInput): void {
    this.state.lastMoveAt = Date.now();
    this.state.turnNumber++;

    const data = input.moveData;

    if (data.isFoul || data.pocketedCoinIds.includes('striker')) {
      this.applyFoul(input.userId);
      this.advanceTurn(input.userId);
      return;
    }

    const pocketedCoins = this.state.coins.filter(
      c => data.pocketedCoinIds.includes(c.id) && !c.pocketed,
    );

    for (const coin of pocketedCoins) {
      coin.pocketed = true;
      coin.pocketedByUserId = input.userId;
      coin.pocketedAtTurn = this.state.turnNumber;

      if (coin.type === CoinType.BLACK) {
        this.state.scores[input.userId].pocketedBlack++;
        this.state.scores[input.userId].points += this.config.pointsPerCoin;
      } else if (coin.type === CoinType.WHITE) {
        this.state.scores[input.userId].pocketedWhite++;
        this.state.scores[input.userId].points += this.config.pointsPerCoin;
      } else if (coin.type === CoinType.RED) {
        this.handleQueenPocketed(input.userId);
      }
    }

    const hasQueenPocketedThisTurn = pocketedCoins.some(c => c.type === CoinType.RED);
    if (hasQueenPocketedThisTurn) {
      if (pocketedCoins.length < 2) {
        this.state.queenLastPocketedByUserId = input.userId;
      } else {
        this.state.scores[input.userId].queenPocketed = true;
        this.state.scores[input.userId].queenCovered = true;
        this.state.scores[input.userId].points += this.config.queenPoints;
      }
    }

    if (pocketedCoins.length > 0) {
      this.continueTurn(input.userId);
    } else {
      this.advanceTurn(input.userId);
    }

    this.checkWinCondition();
  }

  applyTimeout(userId: string): void {
    this.state.scores[userId].fouls++;
    this.advanceTurn(userId);
    this.checkWinCondition();
  }

  applyDisconnect(userId: string): void {
    this.state.scores[userId].isConnected = false;
    const otherPlayer = this.playerIds.find(pid => pid !== userId);
    if (otherPlayer) {
      this.state.winnerId = otherPlayer;
      this.state.winReason = WinReason.OPPONENT_DISCONNECTED;
      this.state.isComplete = true;
    }
  }

  applySurrender(userId: string): void {
    const otherPlayer = this.playerIds.find(pid => pid !== userId);
    if (otherPlayer) {
      this.state.winnerId = otherPlayer;
      this.state.winReason = WinReason.OPPONENT_DISCONNECTED;
      this.state.isComplete = true;
    }
  }

  getWinner(): { userId: string; reason: WinReason; scores: Record<string, number> } | null {
    if (!this.state.isComplete || !this.state.winnerId) return null;

    const scoreMap: Record<string, number> = {};
    for (const [uid, score] of Object.entries(this.state.scores)) {
      scoreMap[uid] = score.points;
    }

    return {
      userId: this.state.winnerId,
      reason: this.state.winReason!,
      scores: scoreMap,
    };
  }

  isComplete(): boolean {
    return this.state.isComplete;
  }

  private applyFoul(userId: string): void {
    this.state.scores[userId].fouls++;
    const penalty = this.config.foulPenalty;
    this.state.scores[userId].points = Math.max(0, this.state.scores[userId].points - penalty);

    const pocketedByUser = this.state.coins.filter(
      c => c.pocketedByUserId === userId && c.type !== CoinType.RED,
    );

    if (pocketedByUser.length > 0) {
      const lastCoin = pocketedByUser[pocketedByUser.length - 1];
      lastCoin.pocketed = false;
      lastCoin.pocketedByUserId = undefined;
      lastCoin.pocketedAtTurn = undefined;

      if (lastCoin.type === CoinType.BLACK) {
        this.state.scores[userId].pocketedBlack = Math.max(0, this.state.scores[userId].pocketedBlack - 1);
      } else if (lastCoin.type === CoinType.WHITE) {
        this.state.scores[userId].pocketedWhite = Math.max(0, this.state.scores[userId].pocketedWhite - 1);
      }
    }
  }

  private handleQueenPocketed(userId: string): void {
    this.state.queenState = QueenState.POCKETED;
    this.state.queenLastPocketedByUserId = userId;
    this.state.scores[userId].queenPocketed = true;
  }

  private advanceTurn(currentUserId: string): void {
    const nextIndex = this.playerIds.indexOf(currentUserId) === 0 ? 1 : 0;
    this.state.currentTurnUserId = this.playerIds[nextIndex];
    this.state.turnStartTime = Date.now();

    if (this.state.queenState === QueenState.POCKETED && this.state.queenLastPocketedByUserId) {
      this.state.scores[this.state.queenLastPocketedByUserId].queenPocketed = false;
      this.state.queenState = QueenState.COVERED;

      const queenCoin = this.state.coins.find(c => c.type === CoinType.RED);
      if (queenCoin) {
        queenCoin.pocketed = false;
        queenCoin.pocketedByUserId = undefined;
        queenCoin.pocketedAtTurn = undefined;
      }
    }
  }

  private continueTurn(userId: string): void {
    this.state.currentTurnUserId = userId;
    this.state.turnStartTime = Date.now();
  }

  private checkWinCondition(): void {
    const allPocketed = this.state.coins.every(c => c.pocketed || c.type === CoinType.RED);
    const redPocketed = this.state.coins.find(c => c.type === CoinType.RED)?.pocketed;
    const allCoinsGone = allPocketed && redPocketed;

    if (allCoinsGone) {
      this.state.isComplete = true;
      this.state.winnerId = this.determineWinner();
      this.state.winReason = WinReason.ALL_COINS_POCKETED;
      return;
    }

    if (this.state.turnNumber >= this.config.maxTurns) {
      this.state.isComplete = true;
      this.state.winnerId = this.determineWinner();
      this.state.winReason = WinReason.MAX_TURNS_REACHED;
      return;
    }

    for (const [userId, score] of Object.entries(this.state.scores)) {
      if (score.points >= this.config.targetScore) {
        this.state.isComplete = true;
        this.state.winnerId = userId;
        this.state.winReason = WinReason.TARGET_SCORE_REACHED;
        return;
      }
    }
  }

  private determineWinner(): string {
    let maxPoints = -1;
    let winner = this.playerIds[0];

    for (const userId of this.playerIds) {
      const score = this.state.scores[userId].points;
      if (score > maxPoints) {
        maxPoints = score;
        winner = userId;
      }
    }

    return winner;
  }
}
