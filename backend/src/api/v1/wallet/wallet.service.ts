import { prisma } from '../../../config/database';
import { ApiError } from '../../../utils/api-error';

export class WalletService {
  static async getWallet(userId: string) {
    const wallet = await prisma.wallet.findFirst({ where: { userId } });
    if (!wallet) {
      return prisma.wallet.create({ data: { userId } });
    }
    return wallet;
  }

  static async getBalance(userId: string) {
    const wallet = await this.getWallet(userId);
    return { balance: wallet.balance, winnings: wallet.totalWinnings, bonus: wallet.bonusBalance };
  }

  static async deposit(userId: string, amount: number, paymentGateway: string, paymentId: string) {
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findFirst({ where: { userId } });
      if (!wallet) throw ApiError.notFound('Wallet not found');

      const existing = await tx.transaction.findFirst({
        where: { gatewayReference: paymentId, type: 'DEPOSIT' as any },
      });
      if (existing) throw ApiError.conflict('Payment already processed');

      const balanceBefore = wallet.balance;
      const balanceAfter = balanceBefore.toNumber() + amount;

      const transaction = await tx.transaction.create({
        data: {
          walletId: wallet.id,
          userId,
          type: 'DEPOSIT' as any,
          amount,
          status: 'SUCCESS' as any,
          gateway: paymentGateway as any,
          gatewayReference: paymentId,
          balanceBefore,
          balanceAfter,
          description: `Deposit of ${amount} via ${paymentGateway}`,
        },
      });

      await tx.wallet.update({
        where: { id: wallet.id },
        data: {
          balance: { increment: amount },
          totalDeposited: { increment: amount },
        },
      });

      return transaction;
    });
  }

  static async withdraw(userId: string, amount: number, accountType: string, accountId: string) {
    return prisma.$transaction(async (tx) => {
      const wallet = await tx.wallet.findFirst({ where: { userId } });
      if (!wallet) throw ApiError.notFound('Wallet not found');

      const minWithdrawal = parseFloat(process.env.MIN_WITHDRAWAL || '50');
      const maxWithdrawal = parseFloat(process.env.MAX_WITHDRAWAL || '50000');

      if (amount < minWithdrawal) throw ApiError.badRequest(`Minimum withdrawal is ${minWithdrawal}`);
      if (amount > maxWithdrawal) throw ApiError.badRequest(`Maximum withdrawal is ${maxWithdrawal}`);
      if (wallet.balance.toNumber() < amount) throw ApiError.badRequest('Insufficient balance');

      let account: any;
      if (accountType === 'BANK') {
        account = await tx.bankAccount.findFirst({ where: { id: accountId, userId } });
      } else {
        account = await tx.upiAccount.findFirst({ where: { id: accountId, userId } });
      }
      if (!account) throw ApiError.notFound('Account not found');

      const balanceBefore = wallet.balance;
      const balanceAfter = balanceBefore.toNumber() - amount;

      await tx.wallet.update({
        where: { id: wallet.id },
        data: {
          balance: { decrement: amount },
          totalWithdrawn: { increment: amount },
        },
      });

      return tx.transaction.create({
        data: {
          walletId: wallet.id,
          userId,
          type: 'WITHDRAWAL' as any,
          amount: -amount,
          status: 'PENDING' as any,
          gateway: 'MANUAL' as any,
          balanceBefore,
          balanceAfter,
          description: `Withdrawal of ${amount} to ${accountType}:${account.accountNumber || account.upiId}`,
        },
      });
    });
  }

  static async getTransactions(userId: string, query: {
    page: number; limit: number; type?: string; status?: string; startDate?: string; endDate?: string;
  }) {
    const where: any = { userId };
    if (query.type) where.type = query.type;
    if (query.status) where.status = query.status;
    if (query.startDate || query.endDate) {
      where.createdAt = {};
      if (query.startDate) where.createdAt.gte = new Date(query.startDate);
      if (query.endDate) where.createdAt.lte = new Date(query.endDate);
    }

    const [transactions, total] = await Promise.all([
      prisma.transaction.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (query.page - 1) * query.limit,
        take: query.limit,
      }),
      prisma.transaction.count({ where }),
    ]);

    return {
      transactions,
      meta: {
        page: query.page,
        limit: query.limit,
        totalItems: total,
        totalPages: Math.ceil(total / query.limit),
        hasNextPage: query.page * query.limit < total,
        hasPrevPage: query.page > 1,
      },
    };
  }

  static async transferFunds(fromUserId: string, toUserId: string, amount: number) {
    return prisma.$transaction(async (tx) => {
      const fromWallet = await tx.wallet.findFirst({ where: { userId: fromUserId } });
      if (!fromWallet) throw ApiError.notFound('Sender wallet not found');
      if (fromWallet.balance.toNumber() < amount) throw ApiError.badRequest('Insufficient balance');

      const toWallet = await tx.wallet.findFirst({ where: { userId: toUserId } });
      if (!toWallet) throw ApiError.notFound('Recipient wallet not found');

      const fromBalanceBefore = fromWallet.balance;
      const toBalanceBefore = toWallet.balance;

      await tx.wallet.update({ where: { id: fromWallet.id }, data: { balance: { decrement: amount } } });
      await tx.wallet.update({ where: { id: toWallet.id }, data: { balance: { increment: amount } } });

      await tx.transaction.create({
        data: {
          walletId: fromWallet.id,
          userId: fromUserId,
          type: 'ADMIN_DEBIT' as any,
          amount: -amount,
          status: 'SUCCESS' as any,
          balanceBefore: fromBalanceBefore,
          balanceAfter: fromBalanceBefore.toNumber() - amount,
          description: `Transfer to user ${toUserId}`,
        },
      });

      await tx.transaction.create({
        data: {
          walletId: toWallet.id,
          userId: toUserId,
          type: 'ADMIN_CREDIT' as any,
          amount,
          status: 'SUCCESS' as any,
          balanceBefore: toBalanceBefore,
          balanceAfter: toBalanceBefore.toNumber() + amount,
          description: `Transfer from user ${fromUserId}`,
        },
      });
    });
  }
}
