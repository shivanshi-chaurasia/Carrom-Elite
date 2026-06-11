import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_providers.dart';
import '../../widgets/app_bar/gaming_app_bar.dart';
import '../../widgets/common/app_scaffold.dart';

class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyState();
}

class _AddMoneyState extends ConsumerState<AddMoneyScreen> {
  final TextEditingController amountController = TextEditingController(text: '500');
  final List<int> quickAmounts = [100, 500, 1000, 2000];
  String selectedGateway = 'UPI';
  bool isDepositing = false;

  // Form controllers
  final TextEditingController _cardNumberCtrl = TextEditingController();
  final TextEditingController _cardHolderCtrl = TextEditingController();
  final TextEditingController _cardExpiryCtrl = TextEditingController();
  final TextEditingController _cardCvvCtrl = TextEditingController();
  final TextEditingController _bankSearchCtrl = TextEditingController();

  String _bankSearchQuery = '';
  String? _selectedBankName;

  final List<Map<String, String>> _popularBanks = const [
    {'name': 'State Bank of India', 'code': 'SBI', 'color': '0xFF00BFFF'},
    {'name': 'HDFC Bank', 'code': 'HDFC', 'color': '0xFF000080'},
    {'name': 'ICICI Bank', 'code': 'ICICI', 'color': '0xFFFF8C00'},
    {'name': 'Axis Bank', 'code': 'AXIS', 'color': '0xFF800000'},
    {'name': 'Kotak Mahindra', 'code': 'KOTAK', 'color': '0xFFB22222'},
    {'name': 'Punjab National Bank', 'code': 'PNB', 'color': '0xFFD2691E'},
  ];

  @override
  void dispose() {
    amountController.dispose();
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    _bankSearchCtrl.dispose();
    super.dispose();
  }

  void _onQuickAmountTap(int amt) {
    setState(() {
      amountController.text = amt.toString();
    });
  }

  void _onCardNumberChanged(String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    final formatted = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(clean[i]);
    }
    final text = formatted.toString();
    _cardNumberCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  void _onCardExpiryChanged(String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    var text = clean;
    if (clean.length > 2) {
      text = '${clean.substring(0, 2)}/${clean.substring(2, min(4, clean.length))}';
    }
    _cardExpiryCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  Widget _getCardBrandBadge() {
    final numText = _cardNumberCtrl.text.replaceAll(' ', '');
    if (numText.startsWith('4')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF0F1B5F), borderRadius: BorderRadius.circular(4)),
        child: const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
      );
    } else if (numText.startsWith('5')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFE65C00), borderRadius: BorderRadius.circular(4)),
        child: const Text('MC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
      );
    }
    return const Icon(Icons.credit_card_rounded, color: AppColors.textSoft, size: 20);
  }

  List<Map<String, String>> _getFilteredBanks() {
    if (_bankSearchQuery.isEmpty) return _popularBanks;
    return _popularBanks
        .where((bank) => bank['name']!.toLowerCase().contains(_bankSearchQuery.toLowerCase()))
        .toList();
  }

  bool _isFormValid() {
    final amtVal = num.tryParse(amountController.text.trim()) ?? 0;
    if (amtVal <= 0) return false;

    if (selectedGateway == 'UPI') {
      return true;
    } else if (selectedGateway == 'Card') {
      final cardNo = _cardNumberCtrl.text.replaceAll(' ', '');
      final expiry = _cardExpiryCtrl.text;
      final cvv = _cardCvvCtrl.text;
      final holder = _cardHolderCtrl.text.trim();
      return cardNo.length == 16 && expiry.length == 5 && cvv.length == 3 && holder.isNotEmpty;
    } else if (selectedGateway == 'NetBanking') {
      return _selectedBankName != null;
    }
    return false;
  }

  Future<void> _handleDeposit() async {
    var amt = num.tryParse(amountController.text.trim()) ?? 0;
    if (amt <= 0) return;

    setState(() => isDepositing = true);
    
    var ok = await ref.read(walletDetailsProvider.notifier).deposit(amt, selectedGateway);
    
    if (ok) {
      ref.invalidate(transactionHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₹$amt deposited successfully!'),
            backgroundColor: AppColors.teal,
          ),
        );
        context.pop();
      }
    } else {
      setState(() => isDepositing = false);
    }
  }

  void _onConfirmPaymentPressed() {
    if (selectedGateway == 'NetBanking') {
      _showBankRedirectSheet(_selectedBankName!);
    } else {
      _handleDeposit();
    }
  }

  void _showBankRedirectSheet(String bankName) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            border: const Border(top: BorderSide(color: AppColors.line)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 24),
              Text(
                'REDIRECTING TO BANK...',
                style: AppTypography.small.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                'We are establishing a secure connection to $bankName portal. Please do not close this window or hit back.',
                style: AppTypography.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _handleDeposit();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'SIMULATE SUCCESSFUL LOGIN',
                    style: AppTypography.button.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var amtVal = num.tryParse(amountController.text.trim()) ?? 0;
    var gstRate = 0.28;
    var netDeposit = amtVal / (1 + gstRate);
    var gstAmount = amtVal - netDeposit;

    return AppScaffold(
      child: Column(
        children: [
          GamingAppBar(
            title: 'ADD DEPOSIT CASH',
            subtitle: 'Instant secure payments',
            onBack: context.pop,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildAmountInput(),
                const SizedBox(height: 14),
                _buildQuickSelectors(),
                const SizedBox(height: 24),
                if (amtVal > 0) ...[
                  _buildGSTBreakdown(netDeposit, gstAmount, amtVal),
                  const SizedBox(height: 24),
                ],
                _buildSegmentTabs(),
                const SizedBox(height: 20),
                _buildPaymentGatewayForm(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _buildConfirmFooter(amtVal),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter Amount (₹)', style: AppTypography.small),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: AppTypography.h1.copyWith(fontSize: 32, color: AppColors.gold),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTypography.h1.copyWith(fontSize: 32, color: AppColors.textSoft),
              border: InputBorder.none,
              prefixText: '₹ ',
              prefixStyle: AppTypography.h1.copyWith(fontSize: 32, color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: quickAmounts.map((amt) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _onQuickAmountTap(amt),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.line),
              ),
              child: Center(
                child: Text(
                  '+ ₹$amt',
                  style: AppTypography.small.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGSTBreakdown(double netDeposit, double gstAmount, num total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GST INVOICE BREAKDOWN',
            style: AppTypography.small.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _breakdownRow('Game balance credited', netDeposit),
          const SizedBox(height: 8),
          _breakdownRow('Govt GST paid (28%)', gstAmount),
          const Divider(color: AppColors.line, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Paid', style: AppTypography.body),
              Text(
                AppFormatters.money(total),
                style: AppTypography.h3.copyWith(color: AppColors.gold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.small),
        Text(AppFormatters.money(val), style: AppTypography.small.copyWith(color: AppColors.text)),
      ],
    );
  }

  Widget _buildSegmentTabs() {
    final tabs = [
      {'key': 'UPI', 'label': 'UPI', 'icon': Icons.bolt_rounded},
      {'key': 'Card', 'label': 'CARD', 'icon': Icons.credit_card_rounded},
      {'key': 'NetBanking', 'label': 'NET BANKING', 'icon': Icons.account_balance_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: tabs.map((t) {
          final isSel = selectedGateway == t['key'];
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedGateway = t['key'] as String;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      t['icon'] as IconData,
                      size: 16,
                      color: isSel ? Colors.white : AppColors.textSoft,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t['label'] as String,
                      style: AppTypography.small.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : AppColors.textSoft,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentGatewayForm() {
    if (selectedGateway == 'UPI') {
      return _buildUpiForm();
    } else if (selectedGateway == 'Card') {
      return _buildCardForm();
    } else {
      return _buildNetBankingForm();
    }
  }

  Widget _buildUpiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POPULAR UPI APPS',
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _upiAppButton('GPay', 'Google Pay', Colors.blue),
            _upiAppButton('PhonePe', 'PhonePe', Colors.deepPurple),
            _upiAppButton('Paytm', 'Paytm', Colors.lightBlue),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'OR ENTER UPI ID',
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: TextField(
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'username@upi',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _upiAppButton(String name, String label, Color bg) {
    return Expanded(
      child: InkWell(
        onTap: _handleDeposit,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: bg.withValues(alpha: 0.12),
                child: Icon(Icons.account_balance_wallet_rounded, color: bg, size: 16),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CARD DETAILS',
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cardNumberCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  style: AppTypography.body,
                  onChanged: _onCardNumberChanged,
                  decoration: InputDecoration(
                    hintText: '0000 0000 0000 0000',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
              _getCardBrandBadge(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: TextField(
                  controller: _cardExpiryCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  style: AppTypography.body,
                  onChanged: _onCardExpiryChanged,
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line),
                ),
                child: TextField(
                  controller: _cardCvvCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  style: AppTypography.body,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'CVV',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: TextField(
            controller: _cardHolderCtrl,
            keyboardType: TextInputType.name,
            style: AppTypography.body,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'CARDHOLDER NAME',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetBankingForm() {
    final filteredBanks = _getFilteredBanks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH YOUR BANK',
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textSoft, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _bankSearchCtrl,
                  style: AppTypography.body,
                  onChanged: (val) {
                    setState(() {
                      _bankSearchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Type bank name...',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_bankSearchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _bankSearchCtrl.clear();
                      _bankSearchQuery = '';
                    });
                  },
                  child: const Icon(Icons.clear_rounded, color: AppColors.textSoft, size: 18),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'POPULAR BANKS',
          style: AppTypography.small.copyWith(color: AppColors.textSoft, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (filteredBanks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No banks match your search',
                style: AppTypography.body.copyWith(color: AppColors.textSoft),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredBanks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (ctx, i) {
              final bank = filteredBanks[i];
              final code = bank['code']!;
              final name = bank['name']!;
              final color = Color(int.parse(bank['color']!));
              final isSelBank = _selectedBankName == name;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedBankName = name;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelBank ? AppColors.gold : AppColors.line, width: isSelBank ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Text(
                          code.substring(0, min(code.length, 2)),
                          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        code,
                        style: AppTypography.small.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildConfirmFooter(num total) {
    var disabled = !_isFormValid() || isDepositing;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : _onConfirmPaymentPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isDepositing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg),
              )
            : Text(
                'PAY ₹${total.toString()}',
                style: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
