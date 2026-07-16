import { Request, Response } from 'express';
import { GameService } from './game.service';
import { sendSuccess } from '../../../utils/api-response';
import { asyncHandler } from '../../../utils/async-handler';

export const joinQueue = asyncHandler(async (req: Request, res: Response) => {
  const { entryFee } = req.body;
  const result = await GameService.joinQueue(req.user!.id, entryFee);
  sendSuccess(res, result, 'Joined queue successfully');
});

export const leaveQueue = asyncHandler(async (req: Request, res: Response) => {
  const result = await GameService.leaveQueue(req.user!.id);
  sendSuccess(res, result, 'Left queue successfully');
});

export const getQueueStatus = asyncHandler(async (req: Request, res: Response) => {
  const result = await GameService.getQueueStatus(req.user!.id);
  sendSuccess(res, result, 'Queue status fetched successfully');
});

export const createPrivateMatch = asyncHandler(async (req: Request, res: Response) => {
  const { entryFee, maxPlayers } = req.body;
  const result = await GameService.createPrivateMatch(req.user!.id, entryFee, maxPlayers);
  sendSuccess(res, result, 'Private match created');
});

export const joinPrivateMatch = asyncHandler(async (req: Request, res: Response) => {
  const roomCode = req.params.roomCode as string;
  const result = await GameService.joinPrivateMatch(req.user!.id, roomCode);
  sendSuccess(res, result, 'Joined private match');
});

export const submitMove = asyncHandler(async (req: Request, res: Response) => {
  const { matchId, moveData } = req.body;
  const result = await GameService.submitMove(req.user!.id, matchId, moveData);
  sendSuccess(res, result, 'Move processed');
});

export const surrender = asyncHandler(async (req: Request, res: Response) => {
  const matchId = req.params.matchId as string;
  const result = await GameService.surrender(req.user!.id, matchId);
  sendSuccess(res, result, 'Match surrendered');
});

export const getMatchDetails = asyncHandler(async (req: Request, res: Response) => {
  const matchId = req.params.matchId as string;
  const result = await GameService.getMatchDetails(matchId, req.user!.id);
  sendSuccess(res, result, 'Match details fetched');
});

export const getMatchHistory = asyncHandler(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string, 10) || 1;
  const limit = parseInt(req.query.limit as string, 10) || 20;
  const result = await GameService.getMatchHistory(req.user!.id, page, limit);
  sendSuccess(res, result.matches, 'Match history fetched', 200, undefined, result.meta);
});

export const getActiveMatches = asyncHandler(async (req: Request, res: Response) => {
  const result = await GameService.getActiveMatches(req.user!.id);
  sendSuccess(res, result, 'Active matches fetched');
});
