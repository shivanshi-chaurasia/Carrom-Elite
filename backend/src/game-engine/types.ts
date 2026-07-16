export enum CoinType {
  BLACK = 'BLACK',
  WHITE = 'WHITE',
  RED = 'RED',
}

export enum QueenState {
  ON_BOARD = 'ON_BOARD',
  POCKETED = 'POCKETED',
  COVERED = 'COVERED',
}

export enum MoveType {
  STRIKE = 'STRIKE',
  FOUL = 'FOUL',
  TIMEOUT = 'TIMEOUT',
}

export enum WinReason {
  ALL_COINS_POCKETED = 'ALL_COINS_POCKETED',
  TARGET_SCORE_REACHED = 'TARGET_SCORE_REACHED',
  OPPONENT_DISCONNECTED = 'OPPONENT_DISCONNECTED',
  OPPONENT_TIMEOUT = 'OPPONENT_TIMEOUT',
  MAX_TURNS_REACHED = 'MAX_TURNS_REACHED',
}

export interface CoinState {
  id: string;
  type: CoinType;
  initialPosition: { x: number; y: number };
  pocketed: boolean;
  pocketedByUserId?: string;
  pocketedAtTurn?: number;
}

export interface PlayerScore {
  userId: string;
  points: number;
  pocketedBlack: number;
  pocketedWhite: number;
  queenPocketed: boolean;
  queenCovered: boolean;
  fouls: number;
  isConnected: boolean;
}

export interface GameState {
  coins: CoinState[];
  scores: Record<string, PlayerScore>;
  currentTurnUserId: string | null;
  turnNumber: number;
  turnStartTime: number;
  turnTimeLimit: number;
  queenState: QueenState;
  queenLastPocketedByUserId?: string;
  winnerId?: string;
  winReason?: WinReason;
  isComplete: boolean;
  startedAt: number;
  lastMoveAt: number;
}

export interface StrikeMoveData {
  aimAngle: number;
  force: number;
  strikerPosition: { x: number; y: number };
  pocketedCoinIds: string[];
  isFoul: boolean;
}

export interface GameMoveInput {
  matchId: string;
  userId: string;
  moveType: MoveType;
  moveData: StrikeMoveData;
  timestamp: number;
}

export interface GameMoveRecord {
  id: string;
  matchId: string;
  userId: string;
  turnNumber: number;
  moveType: string;
  moveData: Record<string, unknown>;
  timestamp: Date;
}

export interface GameConfig {
  targetScore: number;
  turnTimeLimit: number;
  maxTurns: number;
  pointsPerCoin: number;
  queenPoints: number;
  foulPenalty: number;
  coinsPerColor: number;
}
