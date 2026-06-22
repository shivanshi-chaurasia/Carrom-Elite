import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { logger } from '../config/logger';
import { JwtPayload } from '../interfaces/response.interface';
import { getRedisClient } from '../config/redis';

const JWT_SECRET = process.env.JWT_SECRET!;

let io!: Server;

interface AuthenticatedSocket extends Socket {
  userId?: string;
}

export function initializeSocket(httpServer: HttpServer): Server {
  io = new Server(httpServer, {
    cors: {
      origin: config.cors.origin,
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingInterval: 10000,
    pingTimeout: 5000,
    transports: ['websocket', 'polling'],
    allowEIO3: true,
  });

  // Authentication middleware
  io.use(async (socket: AuthenticatedSocket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.query?.token;

      if (!token) {
        return next(new Error('Authentication required'));
      }

      const decoded = jwt.verify(token, JWT_SECRET) as JwtPayload;

      socket.userId = decoded.userId;

      next();
    } catch (error) {
      next(new Error('Authentication failed'));
    }
  });

  io.on('connection', async (socket: AuthenticatedSocket) => {
    const userId = socket.userId!;
    logger.info(`User connected: ${userId} (socket: ${socket.id})`);

    // Join user to their personal room
    socket.join(`user:${userId}`);

    // Set user online status in Redis
    await setUserOnline(userId, socket.id);

    // Join user to their rooms
    await joinUserRooms(socket, userId);

    // Emit online status
    io.emit('user:online', { userId });

    // Handle typing indicator
    socket.on(
      'typing:start',
      (data: { receiverId: string }) => {
        io.to(`user:${data.receiverId}`).emit('typing:start', {
          senderId: userId,
        });
      },
    );

    socket.on(
      'typing:stop',
      (data: { receiverId: string }) => {
        io.to(`user:${data.receiverId}`).emit('typing:stop', {
          senderId: userId,
        });
      },
    );

    // Handle join match room
    socket.on(
      'room:join',
      async (data: { roomId: string }) => {
        const room = `match:${data.roomId}`;
        socket.join(room);
        io.to(room).emit('room:user-joined', {
          userId,
          socketId: socket.id,
        });
      },
    );

    // Handle leave match room
    socket.on(
      'room:leave',
      (data: { roomId: string }) => {
        const room = `match:${data.roomId}`;
        socket.leave(room);
        io.to(room).emit('room:user-left', {
          userId,
          socketId: socket.id,
        });
      },
    );

    // Handle match events
    socket.on(
      'match:move',
      (data: { matchId: string; moveData: unknown }) => {
        const room = `match:${data.matchId}`;
        socket.to(room).emit('match:opponent-move', {
          userId,
          moveData: data.moveData,
        });
      },
    );

    socket.on(
      'match:ready',
      (data: { matchId: string }) => {
        const room = `match:${data.matchId}`;
        io.to(room).emit('match:player-ready', {
          userId,
        });
      },
    );

    // Handle chat messages
    socket.on(
      'chat:message',
      async (data: { receiverId: string; message: string }) => {
        io.to(`user:${data.receiverId}`).emit('chat:message', {
          senderId: userId,
          message: data.message,
          timestamp: new Date().toISOString(),
        });
      },
    );

    // Handle voice chat events
    socket.on(
      'voice:offer',
      (data: { receiverId: string; offer: unknown }) => {
        io.to(`user:${data.receiverId}`).emit('voice:offer', {
          senderId: userId,
          offer: data.offer,
        });
      },
    );

    socket.on(
      'voice:answer',
      (data: { receiverId: string; answer: unknown }) => {
        io.to(`user:${data.receiverId}`).emit('voice:answer', {
          senderId: userId,
          answer: data.answer,
        });
      },
    );

    socket.on(
      'voice:ice-candidate',
      (data: { receiverId: string; candidate: unknown }) => {
        io.to(`user:${data.receiverId}`).emit('voice:ice-candidate', {
          senderId: userId,
          candidate: data.candidate,
        });
      },
    );

    // Handle disconnection
    socket.on('disconnect', async () => {
      logger.info(`User disconnected: ${userId} (socket: ${socket.id})`);
      await removeUserOnline(userId, socket.id);

      // Check if user has other active sockets
      const userSockets = await io.in(`user:${userId}`).fetchSockets();
      if (userSockets.length === 0) {
        io.emit('user:offline', { userId });
      }
    });
  });

  logger.info('Socket.IO initialized');
  return io;
}

function getIo(): Server {
  if (!io) {
    throw new Error('Socket.IO not initialized');
  }
  return io;
}

async function setUserOnline(userId: string, socketId: string): Promise<void> {
  const redis = getRedisClient();
  await redis.sadd(`online:users`, userId);
  await redis.sadd(`online:sockets:${userId}`, socketId);
  await redis.set(`socket:user:${socketId}`, userId);
}

async function removeUserOnline(userId: string, socketId: string): Promise<void> {
  const redis = getRedisClient();
  await redis.srem(`online:sockets:${userId}`, socketId);

  const remainingSockets = await redis.scard(`online:sockets:${userId}`);
  if (remainingSockets === 0) {
    await redis.srem(`online:users`, userId);
    await redis.del(`online:sockets:${userId}`);
  }
  await redis.del(`socket:user:${socketId}`);
}

async function joinUserRooms(
  socket: AuthenticatedSocket,
  userId: string,
): Promise<void> {
  // Join active match rooms
  try {
    const { prisma } = await import('../config/database');
    const activeMatches = await prisma.matchPlayer.findMany({
      where: {
        userId,
        match: {
          status: { in: ['WAITING', 'READY', 'IN_PROGRESS'] },
        },
      },
      select: {
        matchId: true,
      },
    });

    activeMatches.forEach(({ matchId }) => {
      socket.join(`match:${matchId}`);
    });
  } catch (error) {
    logger.error(`Error joining user rooms for ${userId}:`, error);
  }
}

export { getIo, AuthenticatedSocket };
export default io;

