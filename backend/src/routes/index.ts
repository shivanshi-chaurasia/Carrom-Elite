import { Router } from 'express';
import { config } from '../config';
import v1Routes from './v1';

const router = Router();

router.use(config.apiPrefix, v1Routes);

export default router;
