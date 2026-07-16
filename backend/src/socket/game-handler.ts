import { Server, Socket } from 'socket.io';
import { TurnTimer } from '../game-engine/timer';
import { GameService } from '../api/v1/game/game.service';
import { logger } from '../config/logger';

interface GameAuthenticatedSocket extends Socket {
  userId?: string;
}

export function registerGameHandlers(io: Server, socket: GameAuthenticatedSocket): void {
  const userId = socket.userId!;

  socket.on('game:move', async (data: { matchId: string; moveData: any }, callback) => {
    try {
      if (!data.matchId || !data.moveData) {
        callback?.({ error: 'Invalid move data' });
        return;
      }

      const result = await GameService.submitMove(userId, data.matchId, data.moveData);

      io.to(`match:${data.matchId}`).emit('game:opponent-move', {
        userId,
        turnNumber: result.gameState?.turnNumber,
        gameState: result.gameState,
      });

      callback?.(result);
    } catch (error: any) {
      logger.error(`Game move error for user ${userId}:`, error);
      callback?.({ error: error.message || 'Move failed' });
    }
  });

  socket.on('game:surrender', async (data: { matchId: string }, callback) => {
    try {
      if (!data.matchId) {
        callback?.({ error: 'Match ID required' });
        return;
      }

      const result = await GameService.surrender(userId, data.matchId);

      io.to(`match:${data.matchId}`).emit('game:opponent-surrender', {
        userId,
      });

      callback?.(result);
    } catch (error: any) {
      callback?.({ error: error.message || 'Surrender failed' });
    }
  });

  socket.on('game:ready', async (data: { matchId: string }) => {
    try {
      if (!data.matchId) return;
      socket.to(`match:${data.matchId}`).emit('game:player-ready', { userId });
    } catch (error) {
      logger.error(`Game ready error for user ${userId}:`, error);
    }
  });

  socket.on('game:ping', async (data: { matchId: string }, callback) => {
    try {
      const remainingTime = await TurnTimer.getRemainingTime(data.matchId);
      callback?.({ timestamp: Date.now(), remainingTime });
    } catch {
      callback?.({ timestamp: Date.now() });
    }
  });

  socket.on('disconnecting', async () => {
    const rooms = Array.from(socket.rooms).filter(r => r.startsWith('match:'));
    for (const room of rooms) {
      const matchId = room.replace('match:', '');
      try {
        await GameService.handleDisconnect(userId, matchId);
      } catch (error) {
        logger.error(`Disconnect handling error for ${userId} in match ${matchId}:`, error);
      }
    }
  });
}
