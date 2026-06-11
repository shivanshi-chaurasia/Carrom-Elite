class FriendModel {
  final String id;
  final String name;
  final String avatar;
  final String status; // online, offline, playing
  final String lastSeen;
  final bool isChallenged;

  FriendModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.status,
    required this.lastSeen,
    this.isChallenged = false,
  });

  FriendModel copyWith({
    String? id,
    String? name,
    String? avatar,
    String? status,
    String? lastSeen,
    bool? isChallenged,
  }) {
    return FriendModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      isChallenged: isChallenged ?? this.isChallenged,
    );
  }

  static List<FriendModel> mockList() {
    return [
      FriendModel(id: 'fr_1', name: 'StrikerKing', avatar: 'SK', status: 'online', lastSeen: 'Active now'),
      FriendModel(id: 'fr_2', name: 'PocketPro', avatar: 'PP', status: 'playing', lastSeen: 'Playing Carrom'),
      FriendModel(id: 'fr_3', name: 'AimMaster', avatar: 'AM', status: 'offline', lastSeen: '3 hrs ago'),
      FriendModel(id: 'fr_4', name: 'CoinCollector', avatar: 'CC', status: 'online', lastSeen: 'Active now'),
      FriendModel(id: 'fr_5', name: 'RaniHunter', avatar: 'RH', status: 'offline', lastSeen: '1 day ago'),
    ];
  }
}

class ChatMessageModel {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final String? challengeRoomCode;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.challengeRoomCode,
  });

  static List<ChatMessageModel> mockDirectChat(String friendId) {
    if (friendId == 'fr_1') {
      return [
        ChatMessageModel(id: 'm1', text: 'Hey man! Ready for a quick Carrom duel?', time: '02:30 PM', isMe: false),
        ChatMessageModel(id: 'm2', text: 'Yeah, sure! What is the entry fee?', time: '02:31 PM', isMe: true),
        ChatMessageModel(id: 'm3', text: 'Let us do a ₹50 custom room table.', time: '02:32 PM', isMe: false),
        ChatMessageModel(id: 'm4', text: 'Send the challenge room invite', time: '02:32 PM', isMe: true),
        ChatMessageModel(
          id: 'm5',
          text: 'Custom room created! Join fast.',
          time: '02:33 PM',
          isMe: false,
          challengeRoomCode: 'CARROM50X',
        ),
      ];
    } else {
      return [
        ChatMessageModel(id: 'm1', text: 'GG! You played really well in that tournament.', time: 'Yesterday', isMe: false),
        ChatMessageModel(id: 'm2', text: 'Thanks! That micro angle shot was lucky though.', time: 'Yesterday', isMe: true),
        ChatMessageModel(id: 'm3', text: 'Haha, let us practice again soon.', time: 'Yesterday', isMe: false),
      ];
    }
  }
}

class FeedItemModel {
  final String id;
  final String playerName;
  final String playerAvatar;
  final String time;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String tag;

  FeedItemModel({
    required this.id,
    required this.playerName,
    required this.playerAvatar,
    required this.time,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.tag,
  });

  FeedItemModel copyWith({
    String? id,
    String? playerName,
    String? playerAvatar,
    String? time,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    String? tag,
  }) {
    return FeedItemModel(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      playerAvatar: playerAvatar ?? this.playerAvatar,
      time: time ?? this.time,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      tag: tag ?? this.tag,
    );
  }

  static List<FeedItemModel> mockFeed() {
    return [
      FeedItemModel(
        id: 'post_1',
        playerName: 'StrikerKing',
        playerAvatar: 'SK',
        time: '2 hrs ago',
        content: 'Just won the ₹10,000 Saturday Mega Carrom Showdown! The last white coin rebound shot was insane! Thanks for the support guys. 🏆🎉',
        likesCount: 42,
        commentsCount: 9,
        isLiked: false,
        tag: 'Tournament Win',
      ),
      FeedItemModel(
        id: 'post_2',
        playerName: 'PocketPro',
        playerAvatar: 'PP',
        time: '5 hrs ago',
        content: 'Check out the new VIP Platinum perks! The 10% instant deposit cashback is paying off big time. highly recommend upgrading if you play regularly.',
        likesCount: 15,
        commentsCount: 3,
        isLiked: true,
        tag: 'VIP Lounge',
      ),
      FeedItemModel(
        id: 'post_3',
        playerName: 'Carrom Official',
        playerAvatar: 'AD',
        time: 'Yesterday',
        content: '📢 Maintenance Notice: Server upgrade scheduled for Tuesday at 03:00 AM IST. Matchmaking will be paused for 30 minutes. Practice mode will remain offline.',
        likesCount: 89,
        commentsCount: 14,
        isLiked: false,
        tag: 'Announcements',
      ),
    ];
  }
}
