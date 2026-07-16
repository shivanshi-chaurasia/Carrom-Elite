import { Router } from 'express';
import authRoutes from '../api/v1/auth/auth.routes';
import homeRoutes from '../api/v1/home/home.routes';
import gameRoutes from '../api/v1/game/game.routes';
import walletRoutes from '../api/v1/wallet/wallet.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/home', homeRoutes);
router.use('/game', gameRoutes);
router.use('/wallet', walletRoutes);

export default router;
