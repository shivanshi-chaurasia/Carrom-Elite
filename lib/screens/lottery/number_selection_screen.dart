import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';

class NumberSelectionScreen extends StatefulWidget {
  const NumberSelectionScreen({super.key});

  @override
  State<NumberSelectionScreen> createState() => _NumberSelectionScreenState();
}

class _NumberSelectionScreenState extends State<NumberSelectionScreen> {
  final List<int> _selectedNumbers = [];
  bool _isAutoPicking = false;

  void _toggleNumber(int number) {
    if (_isAutoPicking) return;
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        if (_selectedNumbers.length < 6) {
          _selectedNumbers.add(number);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only select up to 6 numbers.')),
          );
        }
      }
    });
  }

  void _runAutoPickAnimation() {
    setState(() {
      _isAutoPicking = true;
      _selectedNumbers.clear();
    });

    final random = Random();
    int count = 0;
    
    // Simulate animated selection
    Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      int select;
      do {
        select = random.nextInt(49) + 1;
      } while (_selectedNumbers.contains(select));
      
      setState(() {
        _selectedNumbers.add(select);
        count++;
      });

      if (count == 6) {
        timer.cancel();
        setState(() => _isAutoPicking = false);
      }
    });
  }

  void _confirmSelection() {
    if (_selectedNumbers.length != 6) return;
    context.pop(_selectedNumbers); // Return the selected numbers back
  }

  @override
  Widget build(BuildContext context) {
    var ready = _selectedNumbers.length == 6 && !_isAutoPicking;

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
          'CHOOSE 6 NUMBERS',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSelectionHeader(),
            
            // 7x7 numbers grid (1-49)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 49,
                itemBuilder: (ctx, idx) {
                  final numVal = idx + 1;
                  final isSelected = _selectedNumbers.contains(numVal);
                  return _buildNumberCell(numVal, isSelected);
                },
              ),
            ),

            // Bottom bar
            _buildConfirmFooter(ready),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'LUCKY BALLS: ${_selectedNumbers.length}/6',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
          ),
          OutlinedButton.icon(
            onPressed: _isAutoPicking ? null : _runAutoPickAnimation,
            icon: const Icon(Icons.casino_rounded, color: AppColors.gold, size: 16),
            label: Text(
              'AUTO PICK',
              style: AppTypography.small.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCell(int val, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleNumber(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.white : AppColors.line,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.purple.withOpacity(0.4),
                blurRadius: 8,
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$val',
          style: AppTypography.body.copyWith(
            color: isSelected ? Colors.white : AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmFooter(bool ready) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected chips row
          SizedBox(
            height: 42,
            child: _selectedNumbers.isEmpty
                ? Center(
                    child: Text(
                      'No numbers selected yet',
                      style: AppTypography.small.copyWith(color: AppColors.textSoft),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedNumbers.length,
                    itemBuilder: (ctx, idx) {
                      final numVal = _selectedNumbers[idx];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.purple),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: AppColors.purple,
                              child: Text(
                                '$numVal',
                                style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _toggleNumber(numVal),
                              child: const Icon(Icons.close_rounded, size: 12, color: AppColors.red),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: ready ? _confirmSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                disabledBackgroundColor: AppColors.line,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'CONFIRM & BUY TICKET',
                style: AppTypography.button.copyWith(
                  color: ready ? Colors.black : AppColors.textSoft,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
