import { Router } from 'express';
import { authenticate } from '../../../middlewares/auth.middleware';
import { validate } from '../../../middlewares/validate.middleware';
import {
  depositSchema, withdrawSchema, transferSchema, transactionHistorySchema,
} from '../../../validators/wallet.validator';
import {
  getWallet, getBalance, deposit, withdraw, getTransactions, transferFunds,
} from './wallet.controller';

const router = Router();

router.use(authenticate);

router.get('/', getWallet);
router.get('/balance', getBalance);
router.post('/deposit', validate(depositSchema), deposit);
router.post('/withdraw', validate(withdrawSchema), withdraw);
router.get('/transactions', validate(transactionHistorySchema), getTransactions);
router.post('/transfer', validate(transferSchema), transferFunds);

export default router;
