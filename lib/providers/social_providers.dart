import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_models.dart';

class FriendsNotifier extends Notifier<List<FriendModel>> {
  @override
  List<FriendModel> build() {
    return FriendModel.mockList();
  }

  void searchFriends(String query) {
    if (query.isEmpty) {
      state = FriendModel.mockList();
      return;
    }
    state = FriendModel.mockList()
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void addFriend(String name) {
    if (name.isEmpty) return;
    var newFriend = FriendModel(
      id: 'fr_${state.length + 1}',
      name: name,
      avatar: name.substring(0, 2).toUpperCase(),
      status: 'offline',
      lastSeen: 'Just now',
    );
    state = [...state, newFriend];
  }

  void challengeFriend(String id, String roomCode) {
    state = state.map((f) {
      if (f.id == id) {
        return f.copyWith(isChallenged: true, status: 'playing');
      }
      return f;
    }).toList();
  }
}

final friendsProvider = NotifierProvider<FriendsNotifier, List<FriendModel>>(FriendsNotifier.new);

class ChatState {
  final Map<String, List<ChatMessageModel>> chatLogs;

  ChatState({required this.chatLogs});

  ChatState copyWith({Map<String, List<ChatMessageModel>>? chatLogs}) {
    return ChatState(
      chatLogs: chatLogs ?? this.chatLogs,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(chatLogs: {});
  }

  List<ChatMessageModel> getMessagesFor(String friendId) {
    if (!state.chatLogs.containsKey(friendId)) {
      var initial = ChatMessageModel.mockDirectChat(friendId);
      state.chatLogs[friendId] = initial;
    }
    return state.chatLogs[friendId] ?? [];
  }

  void sendMessage(String friendId, String text, {String? challengeCode}) {
    var logs = Map<String, List<ChatMessageModel>>.from(state.chatLogs);
    var current = logs[friendId] ?? ChatMessageModel.mockDirectChat(friendId);
    
    var newMessage = ChatMessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      time: 'Just now',
      isMe: true,
      challengeRoomCode: challengeCode,
    );

    logs[friendId] = [...current, newMessage];
    state = state.copyWith(chatLogs: logs);

    if (challengeCode == null) {
      Timer(const Duration(milliseconds: 1500), () {
        var logsAfter = Map<String, List<ChatMessageModel>>.from(state.chatLogs);
        var currentAfter = logsAfter[friendId] ?? [];
        
        var reply = ChatMessageModel(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          text: _getMockReply(text),
          time: 'Just now',
          isMe: false,
        );

        logsAfter[friendId] = [...currentAfter, reply];
        state = state.copyWith(chatLogs: logsAfter);
      });
    }
  }

  String _getMockReply(String userMsg) {
    var lower = userMsg.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Yo! What is up? Want to play some Carrom? 🎯';
    } else if (lower.contains('play') || lower.contains('game')) {
      return 'Send me an invite link! Ready to win some coins.';
    } else if (lower.contains('win') || lower.contains('lose')) {
      return 'Haha, we will see who wins! Let us go.';
    } else {
      return 'Nice! Talk to you in a bit, let us catch up in the lobby. ⚡';
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class CommunityFeedNotifier extends Notifier<List<FeedItemModel>> {
  @override
  List<FeedItemModel> build() {
    return FeedItemModel.mockFeed();
  }

  void likePost(String id) {
    state = state.map((item) {
      if (item.id == id) {
        var isLikedNow = !item.isLiked;
        return item.copyWith(
          isLiked: isLikedNow,
          likesCount: item.likesCount + (isLikedNow ? 1 : -1),
        );
      }
      return item;
    }).toList();
  }

  void addPost(String content) {
    if (content.isEmpty) return;
    var newPost = FeedItemModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      playerName: 'You',
      playerAvatar: 'ME',
      time: 'Just now',
      content: content,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      tag: 'General',
    );
    state = [newPost, ...state];
  }
}

final communityFeedProvider = NotifierProvider<CommunityFeedNotifier, List<FeedItemModel>>(CommunityFeedNotifier.new);
