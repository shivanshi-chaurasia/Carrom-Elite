import { Request, Response } from 'express';
import { WalletService } from './wallet.service';
import { sendSuccess } from '../../../utils/api-response';
import { asyncHandler } from '../../../utils/async-handler';

export const getWallet = asyncHandler(async (req: Request, res: Response) => {
  const wallet = await WalletService.getWallet(req.user!.id);
  sendSuccess(res, wallet, 'Wallet details fetched successfully');
});

export const getBalance = asyncHandler(async (req: Request, res: Response) => {
  const balance = await WalletService.getBalance(req.user!.id);
  sendSuccess(res, balance, 'Balance fetched successfully');
});

export const deposit = asyncHandler(async (req: Request, res: Response) => {
  const { amount, paymentGateway, paymentId } = req.body;
  const transaction = await WalletService.deposit(req.user!.id, amount, paymentGateway, paymentId);
  sendSuccess(res, transaction, 'Deposit successful');
});

export const withdraw = asyncHandler(async (req: Request, res: Response) => {
  const { amount, accountType, accountId } = req.body;
  const transaction = await WalletService.withdraw(req.user!.id, amount, accountType, accountId);
  sendSuccess(res, transaction, 'Withdrawal request submitted');
});

export const getTransactions = asyncHandler(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string, 10) || 1;
  const limit = parseInt(req.query.limit as string, 10) || 20;
  const type = req.query.type as string | undefined;
  const status = req.query.status as string | undefined;
  const startDate = req.query.startDate as string | undefined;
  const endDate = req.query.endDate as string | undefined;
  const result = await WalletService.getTransactions(req.user!.id, {
    page, limit, type, status, startDate, endDate,
  });
  sendSuccess(res, result.transactions, 'Transaction history fetched successfully', 200, undefined, result.meta);
});

export const transferFunds = asyncHandler(async (req: Request, res: Response) => {
  const { toUserId, amount } = req.body;
  await WalletService.transferFunds(req.user!.id, toUserId, amount);
  sendSuccess(res, null, 'Transfer successful');
});
