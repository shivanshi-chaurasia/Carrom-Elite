import { StrikeMoveData, CoinState } from './types';

const BOARD_WIDTH = 100;
const BOARD_HEIGHT = 100;
const MIN_FORCE = 1;
const MAX_FORCE = 100;
const MAX_POCKETED_COINS_PER_STRIKE = 4;

export class MoveValidator {
  static validateStrikeMove(
    moveData: StrikeMoveData,
    coins: CoinState[],
    _userId: string,
  ): { valid: boolean; error?: string } {
    if (moveData.force < MIN_FORCE || moveData.force > MAX_FORCE) {
      return { valid: false, error: 'Force out of range' };
    }

    if (moveData.aimAngle < 0 || moveData.aimAngle > 360) {
      return { valid: false, error: 'Angle out of range' };
    }

    if (moveData.pocketedCoinIds.length > MAX_POCKETED_COINS_PER_STRIKE) {
      return { valid: false, error: 'Too many coins pocketed in single strike' };
    }

    for (const coinId of moveData.pocketedCoinIds) {
      if (coinId === 'striker') continue;
      const coin = coins.find(c => c.id === coinId);
      if (!coin) {
        return { valid: false, error: `Coin ${coinId} not found` };
      }
      if (coin.pocketed) {
        return { valid: false, error: `Coin ${coinId} already pocketed` };
      }
    }

    return { valid: true };
  }

  static validateCoinProximity(
    moveData: StrikeMoveData,
    coins: CoinState[],
  ): { valid: boolean; error?: string } {
    const strikerPos = moveData.strikerPosition;

    if (strikerPos.x < 0 || strikerPos.x > BOARD_WIDTH || strikerPos.y < 0 || strikerPos.y > BOARD_HEIGHT) {
      return { valid: false, error: 'Striker position out of bounds' };
    }

    for (const coinId of moveData.pocketedCoinIds) {
      if (coinId === 'striker') continue;
      const coin = coins.find(c => c.id === coinId)!;
      const dx = strikerPos.x - coin.initialPosition.x;
      const dy = strikerPos.y - coin.initialPosition.y;
      const distance = Math.sqrt(dx * dx + dy * dy);
      if (distance > 150) {
        return { valid: false, error: `Coin ${coinId} too far from striker to be pocketed` };
      }
    }

    return { valid: true };
  }

  static isReasonableShot(
    moveData: StrikeMoveData,
    _coins: CoinState[],
  ): boolean {
    if (moveData.pocketedCoinIds.length === 0) return true;

    const pocketed = moveData.pocketedCoinIds.filter(id => id !== 'striker');
    if (pocketed.length === 0) return true;

    return pocketed.length <= 3;
  }
}
