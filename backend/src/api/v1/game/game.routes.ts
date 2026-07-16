import { Router } from 'express';
import { authenticate } from '../../../middlewares/auth.middleware';
import { validate } from '../../../middlewares/validate.middleware';
import {
  joinMatchQueueSchema, createPrivateMatchSchema, joinPrivateMatchSchema,
  submitMoveSchema, surrenderSchema, matchIdParamSchema,
} from '../../../validators/game.validator';
import {
  joinQueue, leaveQueue, getQueueStatus, createPrivateMatch, joinPrivateMatch,
  submitMove, surrender, getMatchDetails, getMatchHistory, getActiveMatches,
} from './game.controller';

const router = Router();

router.use(authenticate);

router.post('/queue/join', validate(joinMatchQueueSchema), joinQueue);
router.post('/queue/leave', leaveQueue);
router.get('/queue/status', getQueueStatus);

router.post('/private', validate(createPrivateMatchSchema), createPrivateMatch);
router.post('/private/join/:roomCode', validate(joinPrivateMatchSchema), joinPrivateMatch);

router.post('/move', validate(submitMoveSchema), submitMove);
router.post('/:matchId/surrender', validate(surrenderSchema), surrender);

router.get('/history', getMatchHistory);
router.get('/active', getActiveMatches);
router.get('/:matchId', validate(matchIdParamSchema), getMatchDetails);

export default router;
