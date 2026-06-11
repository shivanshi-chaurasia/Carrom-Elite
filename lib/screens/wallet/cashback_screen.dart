import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class CashbackScreen extends StatefulWidget {
  const CashbackScreen({super.key});

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  final List<Map<String, dynamic>> _offers = [
    {
      'id': 'o1',
      'value': '2%',
      'title': 'First Deposit Match',
      'desc': 'Get 2% instant cashback on your very first money addition.',
      'minDeposit': 100,
      'active': false,
    },
    {
      'id': 'o2',
      'value': '5%',
      'title': 'Mid-Tier Bonus Pack',
      'desc': 'Earn 5% cashback on deposits of ₹500 or more.',
      'minDeposit': 500,
      'active': false,
    },
    {
      'id': 'o3',
      'value': '10%',
      'title': 'Elite High Roller',
      'desc': 'Unlock a massive 10% cashback bonus on additions exceeding ₹1000.',
      'minDeposit': 1000,
      'active': false,
    },
  ];

  final List<Map<String, dynamic>> _history = [
    {
      'offer': 'Mid-Tier Bonus Pack (5%)',
      'deposit': 500,
      'earned': 25,
      'date': '06 June 2026',
    },
    {
      'offer': 'First Deposit Match (2%)',
      'deposit': 200,
      'earned': 4,
      'date': '12 May 2026',
    },
  ];

  void _activateOffer(int index) {
    setState(() {
      for (int i = 0; i < _offers.length; i++) {
        _offers[i]['active'] = (i == index);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Offer "${_offers[index]['title']}" activated successfully!')),
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
          'CASHBACK OFFERS',
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
            _buildSectionHeader('ACTIVE CAMPAIGNS'),
            const SizedBox(height: 10),
            _buildOffersList(),
            const SizedBox(height: 24),
            _buildSectionHeader('CASHBACK TRANSACTION HISTORY'),
            const SizedBox(height: 10),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.small.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildOffersList() {
    return Column(
      children: List.generate(_offers.length, (idx) {
        final offer = _offers[idx];
        final active = offer['active'] as bool;
        final minD = offer['minDeposit'] as int;

        return Card(
          color: active ? AppColors.surface2 : AppColors.surface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: active ? AppColors.gold : AppColors.line, width: active ? 1.5 : 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Cashback large % text
                Container(
                  width: 70,
                  alignment: Alignment.center,
                  child: Text(
                    offer['value'] as String,
                    style: AppTypography.h1.copyWith(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title'] as String,
                        style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offer['desc'] as String,
                        style: AppTypography.small.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Min deposit: ₹$minD',
                        style: AppTypography.small.copyWith(color: AppColors.textSoft, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Activate button
                ElevatedButton(
                  onPressed: active ? null : () => _activateOffer(idx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: active ? AppColors.surface : AppColors.purple,
                    disabledBackgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: active ? AppColors.teal : Colors.transparent),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: Text(
                    active ? 'ACTIVE' : 'ACTIVATE',
                    style: AppTypography.small.copyWith(
                      color: active ? AppColors.teal : AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('No cashback transactions yet.', style: AppTypography.body.copyWith(color: AppColors.textSoft)),
        ),
      );
    }

    return Column(
      children: _history.map((h) {
        final earned = h['earned'] as int;
        return Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.line),
          ),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.stars_rounded, color: AppColors.gold),
            title: Text(
              h['offer'] as String,
              style: AppTypography.body.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Deposited ₹${h['deposit']} • ${h['date']}', style: AppTypography.small),
            trailing: Text(
              '+ ₹$earned',
              style: AppTypography.body.copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }
}
