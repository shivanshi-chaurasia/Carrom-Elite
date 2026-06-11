import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class GSTInvoiceScreen extends StatefulWidget {
  const GSTInvoiceScreen({super.key});

  @override
  State<GSTInvoiceScreen> createState() => _GSTInvoiceScreenState();
}

class _GSTInvoiceScreenState extends State<GSTInvoiceScreen> {
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-2026-9041',
      'date': '11 June 2026, 04:30 PM',
      'battleId': 'BAT-99214-X',
      'mode': 'Carrom Cash Battle (2v2)',
      'entryFee': 1000.00,
      'platformCommission': 100.00, // 10%
      'gstRate': 18.0, // 18% on commission
      'gstAmount': 18.00,
      'totalPaid': 1018.00,
      'status': 'Paid',
    },
    {
      'id': 'INV-2026-8794',
      'date': '09 June 2026, 11:15 AM',
      'battleId': 'BAT-98711-P',
      'mode': 'Carrom Cash Battle (1v1)',
      'entryFee': 500.00,
      'platformCommission': 50.00,
      'gstRate': 18.0,
      'gstAmount': 9.00,
      'totalPaid': 509.00,
      'status': 'Paid',
    },
    {
      'id': 'INV-2026-8402',
      'date': '04 June 2026, 08:45 PM',
      'battleId': 'BAT-96403-Q',
      'mode': 'Elite Pro Tournament Pool',
      'entryFee': 2500.00,
      'platformCommission': 250.00,
      'gstRate': 18.0,
      'gstAmount': 45.00,
      'totalPaid': 2545.00,
      'status': 'Paid',
    },
  ];

  late Map<String, dynamic> _selectedInvoice;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _selectedInvoice = _invoices.first;
  }

  void _simulateDownload() {
    setState(() => _isDownloading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.teal,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.surface),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Invoice ${_selectedInvoice['id']} downloaded successfully to /Downloads!',
                  style: AppTypography.body.copyWith(color: AppColors.surface, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _simulateShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.purple,
        content: Text(
          'Sharing Link for ${_selectedInvoice['id']} generated & copied to clipboard.',
          style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'GST & COMMISSION INVOICES',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInvoiceSelector(),
            const SizedBox(height: 20),
            _buildInvoiceReceiptCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildTaxGuidelinesAlert(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT INVOICE',
          style: AppTypography.small.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              value: _selectedInvoice,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gold),
              isExpanded: true,
              items: _invoices.map((inv) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: inv,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        inv['id'] as String,
                        style: AppTypography.body.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${(inv['totalPaid'] as double).toStringAsFixed(2)}',
                        style: AppTypography.body.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedInvoice = val;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceReceiptCard() {
    final inv = _selectedInvoice;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARROM ELITE',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Tax Invoice Receipt',
                    style: AppTypography.small.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.green.withOpacity(0.4)),
                ),
                child: Text(
                  inv['status'] as String,
                  style: AppTypography.small.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.line, thickness: 1),
          const SizedBox(height: 16),
          _buildInfoRow('Invoice ID', inv['id'] as String),
          _buildInfoRow('Invoice Date', inv['date'] as String),
          _buildInfoRow('Battle ID', inv['battleId'] as String),
          _buildInfoRow('Game Mode', inv['mode'] as String),
          const SizedBox(height: 16),
          Divider(color: AppColors.line, thickness: 1),
          const SizedBox(height: 16),
          Text(
            'BILLING BREAKDOWN',
            style: AppTypography.small.copyWith(
              color: AppColors.textSoft,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow('Entry Fee (Net Value)', inv['entryFee'] as double),
          _buildBillRow(
            'Platform Commission (10%)',
            inv['platformCommission'] as double,
          ),
          _buildBillRow(
            'GST on Commission (${inv['gstRate']}%)',
            inv['gstAmount'] as double,
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.line, thickness: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL CHARGED',
                style: AppTypography.body.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${(inv['totalPaid'] as double).toStringAsFixed(2)}',
                style: AppTypography.h2.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          Text(
            '₹${val.toStringAsFixed(2)}',
            style: AppTypography.body.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: AppColors.purple.withOpacity(0.4),
            ),
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(
              _isDownloading ? 'DOWNLOADING...' : 'DOWNLOAD PDF',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
            ),
            onPressed: _isDownloading ? null : _simulateDownload,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.teal),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onPressed: _simulateShare,
          ),
        )
      ],
    );
  }

  Widget _buildTaxGuidelinesAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.purple.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.purple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tax & Commission Policy Notice',
                  style: AppTypography.body.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'In compliance with government regulations, a 18% Goods and Services Tax (GST) is levied on the platform service fee (commission) charged by Carrom Elite. This invoice represents the full tax breakdown for your digital cash matches.',
                  style: AppTypography.small.copyWith(
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
