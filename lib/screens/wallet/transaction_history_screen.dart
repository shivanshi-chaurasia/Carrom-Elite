import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_models.dart';
import '../../providers/wallet_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/state_views.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionHistoryProvider);

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(
            title: 'TRANSACTIONS',
            subtitle: 'Transaction ledger',
            onBack: context.pop,
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (err, stack) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(transactionHistoryProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const AppEmptyView(subtitle: 'No transactions found.');
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemBuilder: (ctx, i) => _buildTransactionCard(ctx, items[i]),
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                  itemCount: items.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionModel tx) {
    var isDeposit = tx.type == 'deposit';
    var isWithdraw = tx.type == 'withdraw';
    var isWin = tx.type == 'win';

    Color amtColor;
    String sign;

    if (isWin || isDeposit || tx.type == 'referral' || tx.type == 'bonus') {
      amtColor = AppColors.teal;
      sign = '+';
    } else {
      amtColor = AppColors.red;
      sign = '-';
    }

    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.line),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        iconColor: AppColors.textSoft,
        collapsedIconColor: AppColors.textSoft,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tx.description,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            Text(
              '$sign ${AppFormatters.money(tx.amount)}',
              style: AppTypography.h3.copyWith(color: amtColor),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tx.time, style: AppTypography.small),
              Text(
                tx.status.toUpperCase(),
                style: AppTypography.small.copyWith(
                  color: tx.status == 'completed' ? AppColors.teal : AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppColors.line),
                const SizedBox(height: 8),
                _detailRow('Transaction ID', tx.id),
                _detailRow('Payment Gateway', tx.gateway),
                
                // GST Breakdown for deposits
                if (isDeposit && tx.gstPaid > 0) ...[
                  const SizedBox(height: 6),
                  const Divider(color: AppColors.line, thickness: 0.5),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GST INVOICE DETAILS',
                        style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _showInvoiceDetails(context, tx),
                        icon: const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.gold),
                        label: Text(
                          'VIEW FULL INVOICE',
                          style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _detailRow('HSN Code', '998439 (Online Games)'),
                  _detailRow('Balance credited', AppFormatters.money(tx.amount - tx.gstPaid)),
                  _detailRow('GST Paid (28% included)', AppFormatters.money(tx.gstPaid)),
                ],
                
                if (isWithdraw) ...[
                  const SizedBox(height: 6),
                  _detailRow('Destination UPI', 'UPI Bank Transfer'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.small),
          Text(
            val,
            style: AppTypography.small.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, TransactionModel tx) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.line),
      ),
      builder: (ctx) {
        var netAmt = tx.amount - tx.gstPaid;
        var cgst = tx.gstPaid / 2;
        var sgst = tx.gstPaid / 2;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TAX INVOICE', style: AppTypography.h2.copyWith(color: AppColors.gold)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: AppColors.textSoft),
                  ),
                ],
              ),
              const Divider(color: AppColors.line),
              const SizedBox(height: 12),
              _invoiceRow('Invoice No:', 'INV-${tx.id.toUpperCase()}'),
              _invoiceRow('Date & Time:', tx.time),
              _invoiceRow('SAC Code:', '998439 (Online Games)'),
              _invoiceRow('GSTIN Status:', 'Paid (28% Inclusive)'),
              const Divider(color: AppColors.line, height: 24),
              _invoiceRow('Subtotal (Taxable):', AppFormatters.money(netAmt)),
              _invoiceRow('CGST (14%):', AppFormatters.money(cgst)),
              _invoiceRow('SGST (14%):', AppFormatters.money(sgst)),
              const Divider(color: AppColors.line, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount Paid', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                  Text(AppFormatters.money(tx.amount), style: AppTypography.h2.copyWith(color: AppColors.teal)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GST Invoice downloaded to your device!'),
                      backgroundColor: AppColors.teal,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('DOWNLOAD INVOICE PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: AppColors.text,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _invoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
