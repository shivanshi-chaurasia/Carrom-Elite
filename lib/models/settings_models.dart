class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String type; // system, match, reward

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        isRead: json['isRead'] == true,
        type: json['type']?.toString() ?? 'system',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'type': type,
      };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  static List<NotificationModel> mocks() => [
        NotificationModel(
          id: '1',
          title: 'Tournament Starting Soon!',
          body: 'Your match in "Mega Carrom Cup" starts in 10 minutes. Get ready!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
          type: 'match',
        ),
        NotificationModel(
          id: '2',
          title: 'Daily Reward Claimed',
          body: 'You successfully claimed 100 free coins. Come back tomorrow!',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
          type: 'reward',
        ),
        NotificationModel(
          id: '3',
          title: 'System Maintenance',
          body: 'Server maintenance scheduled for June 15th, 02:00 AM UTC.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          type: 'system',
        ),
      ];
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String category;
  final String description;
  final String status; // open, in_progress, resolved
  final DateTime createdAt;
  final String? screenshotUrl;

  SupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.screenshotUrl,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) => SupportTicketModel(
        id: json['id']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        category: json['category']?.toString() ?? 'General',
        description: json['description']?.toString() ?? '',
        status: json['status']?.toString() ?? 'open',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        screenshotUrl: json['screenshotUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'category': category,
        'description': description,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'screenshotUrl': screenshotUrl,
      };

  static List<SupportTicketModel> mocks() => [
        SupportTicketModel(
          id: 'TKT-782',
          subject: 'Wallet withdrawal failed',
          category: 'Wallet & Payments',
          description: 'Tried to withdraw 500 INR, amount got debited but bank transaction failed.',
          status: 'in_progress',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        SupportTicketModel(
          id: 'TKT-103',
          subject: 'Stuck on match result screen',
          category: 'Game bug',
          description: 'Match ended but result screen was loading forever. Had to restart app.',
          status: 'resolved',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];
}

class FaqModel {
  final String question;
  final String answer;
  final String category;

  FaqModel({
    required this.question,
    required this.answer,
    required this.category,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
        question: json['question']?.toString() ?? '',
        answer: json['answer']?.toString() ?? '',
        category: json['category']?.toString() ?? 'General',
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'category': category,
      };

  static List<FaqModel> mocks() => [
        FaqModel(
          category: 'Gameplay',
          question: 'How do I aim my striker?',
          answer: 'Drag the slider at the bottom of the board to position your striker, then drag back on the striker itself to aim and set the shooting force.',
        ),
        FaqModel(
          category: 'Wallet & Withdrawals',
          question: 'How long do withdrawals take?',
          answer: 'Withdrawals are typically processed within 2-4 hours, but can take up to 24 hours depending on your bank and KYC verification status.',
        ),
        FaqModel(
          category: 'Account & Security',
          question: 'What is 2FA and how do I enable it?',
          answer: 'Two-Factor Authentication adds an extra layer of security. Go to Settings > Security Settings > Two-Factor Authentication and follow the steps to bind your Google Authenticator app.',
        ),
        FaqModel(
          category: 'Tournaments',
          question: 'Can I cancel my tournament registration?',
          answer: 'You can cancel your registration and receive a refund of your entry fee anytime before the tournament matchmaking bracket starts (usually 15 minutes before the start time).',
        ),
      ];
}
