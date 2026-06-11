import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/theme/typography.dart';
import '../../providers/settings_providers.dart';

class TicketHistoryScreen extends ConsumerStatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  ConsumerState<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends ConsumerState<TicketHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsProvider);

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
          'TICKET HISTORY',
          style: AppTypography.h3.copyWith(color: AppColors.text, letterSpacing: 1.1),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.line, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: ticketsState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error loading tickets: $err',
              style: AppTypography.body.copyWith(color: AppColors.red),
            ),
          ),
          data: (tickets) {
            if (tickets.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (ctx, idx) {
                final ticket = tickets[idx];
                return _buildTicketCard(ticket);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in_rounded, color: AppColors.textSoft, size: 54),
            const SizedBox(height: 16),
            Text(
              'No active tickets found',
              style: AppTypography.h3.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'If you have any questions or account issues, raise a ticket and our team will get right on it.',
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.push('/raise-ticket'),
              child: Text(
                'RAISE A TICKET NOW',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(var ticket) {
    Color statusColor;
    String statusText = ticket.status.replaceAll('_', ' ').toUpperCase();

    switch (ticket.status.toLowerCase()) {
      case 'open':
        statusColor = AppColors.gold;
        break;
      case 'in_progress':
        statusColor = AppColors.blue;
        break;
      case 'resolved':
        statusColor = AppColors.green;
        break;
      default:
        statusColor = AppColors.textSoft;
    }

    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: () => _showTicketTimelineSheet(ticket),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.id,
                    style: AppTypography.body.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor, width: 0.8),
                    ),
                    child: Text(
                      statusText,
                      style: AppTypography.small.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ticket.subject,
                style: AppTypography.body.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                style: AppTypography.small.copyWith(color: AppColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(color: AppColors.line, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.category,
                    style: AppTypography.small.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Updated: ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                    style: AppTypography.small.copyWith(color: AppColors.textSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketTimelineSheet(var ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _TicketTimelineSheet(ticket: ticket);
      },
    );
  }
}

class _TicketTimelineSheet extends StatefulWidget {
  final dynamic ticket;
  const _TicketTimelineSheet({required this.ticket});

  @override
  State<_TicketTimelineSheet> createState() => _TicketTimelineSheetState();
}

class _TicketTimelineSheetState extends State<_TicketTimelineSheet> {
  final _messageCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add default messages/timeline nodes
    _messages.add({
      'sender': 'user',
      'text': widget.ticket.description,
      'time': 'Just now',
    });

    if (widget.ticket.status.toLowerCase() != 'open') {
      _messages.add({
        'sender': 'agent',
        'text': 'We are looking into this issue. Please hold on while we run tests on our backend systems.',
        'time': '10m ago',
      });
    }

    if (widget.ticket.status.toLowerCase() == 'resolved') {
      _messages.add({
        'sender': 'agent',
        'text': 'This issue has been resolved. The credit balance adjustments are updated in your wallet. Feel free to re-open if there is any issue.',
        'time': '2m ago',
      });
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.id,
                      style: AppTypography.h3.copyWith(color: AppColors.teal),
                    ),
                    Text(
                      t.category,
                      style: AppTypography.small.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSoft),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(color: AppColors.line, height: 24),
            Text(
              t.subject,
              style: AppTypography.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = _messages[idx];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.purple.withOpacity(0.15) : AppColors.bg,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isUser ? 12 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 12),
                        ),
                        border: Border.all(
                          color: isUser ? AppColors.purple.withOpacity(0.3) : AppColors.line,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUser ? 'YOU' : 'SUPPORT AGENT',
                            style: AppTypography.small.copyWith(
                              color: isUser ? AppColors.purple : AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['text'] as String,
                            style: AppTypography.body.copyWith(color: AppColors.text, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              msg['time'] as String,
                              style: AppTypography.small.copyWith(
                                color: AppColors.textSoft,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (t.status.toLowerCase() != 'resolved')
              _buildReplyInput()
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.green.withOpacity(0.2)),
                  ),
                  child: Text(
                    'This ticket is resolved. Re-open by sending a message.',
                    style: AppTypography.small.copyWith(color: AppColors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageCtrl,
            style: AppTypography.body.copyWith(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Type follow-up response...',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textSoft),
              filled: true,
              fillColor: AppColors.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.purple),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.white),
            onPressed: () {
              final text = _messageCtrl.text.trim();
              if (text.isEmpty) return;
              setState(() {
                _messages.add({
                  'sender': 'user',
                  'text': text,
                  'time': 'Just now',
                });
                _messageCtrl.clear();
              });
              // Simulate agent auto-reply
              Future.delayed(const Duration(seconds: 1), () {
                if (!mounted) return;
                setState(() {
                  _messages.add({
                    'sender': 'agent',
                    'text': 'Thank you for updating. An agent has been notified of your response.',
                    'time': 'Just now',
                  });
                });
              });
            },
          ),
        ),
      ],
    );
  }
}
