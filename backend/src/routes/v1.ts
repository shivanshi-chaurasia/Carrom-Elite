import { Router } from 'express';
import authRoutes from '../api/v1/auth/auth.routes';
import homeRoutes from '../api/v1/home/home.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/home', homeRoutes);

export default router;
