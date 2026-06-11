import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_models.dart';
import 'service_providers.dart';

// --- User Preferences Model & Provider ---
class UserPreferences {
  final double sfxVolume;
  final double musicVolume;
  final bool hapticsEnabled;
  final String graphicsQuality;
  final bool twoFactorEnabled;

  UserPreferences({
    required this.sfxVolume,
    required this.musicVolume,
    required this.hapticsEnabled,
    required this.graphicsQuality,
    required this.twoFactorEnabled,
  });

  UserPreferences copyWith({
    double? sfxVolume,
    double? musicVolume,
    bool? hapticsEnabled,
    String? graphicsQuality,
    bool? twoFactorEnabled,
  }) {
    return UserPreferences(
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      graphicsQuality: graphicsQuality ?? this.graphicsQuality,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    _load();
    return UserPreferences(
      sfxVolume: 0.8,
      musicVolume: 0.5,
      hapticsEnabled: true,
      graphicsQuality: 'High',
      twoFactorEnabled: false,
    );
  }

  Future<void> _load() async {
    final service = ref.read(settingsServiceProvider);
    final prefs = await service.loadPreferences();
    final tfa = await service.isTwoFactorEnabled();
    state = UserPreferences(
      sfxVolume: prefs['sfx'] as double? ?? 0.8,
      musicVolume: prefs['music'] as double? ?? 0.5,
      hapticsEnabled: prefs['haptics'] as bool? ?? true,
      graphicsQuality: prefs['graphics'] as String? ?? 'High',
      twoFactorEnabled: tfa,
    );
  }

  Future<void> setSFXVolume(double val) async {
    state = state.copyWith(sfxVolume: val);
    await ref.read(settingsServiceProvider).savePreference('sfx_volume', val);
  }

  Future<void> setMusicVolume(double val) async {
    state = state.copyWith(musicVolume: val);
    await ref.read(settingsServiceProvider).savePreference('music_volume', val);
  }

  Future<void> setHaptics(bool val) async {
    state = state.copyWith(hapticsEnabled: val);
    await ref.read(settingsServiceProvider).savePreference('haptics_enabled', val);
  }

  Future<void> setGraphics(String quality) async {
    state = state.copyWith(graphicsQuality: quality);
    await ref.read(settingsServiceProvider).savePreference('graphics_quality', quality);
  }

  Future<void> setTwoFactorEnabled(bool enabled) async {
    state = state.copyWith(twoFactorEnabled: enabled);
    await ref.read(settingsServiceProvider).setTwoFactorEnabled(enabled);
  }
}

final userPreferencesProvider = NotifierProvider<UserPreferencesNotifier, UserPreferences>(UserPreferencesNotifier.new);

// --- Notifications List Provider ---
class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    return ref.watch(settingsServiceProvider).fetchNotifications();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(settingsServiceProvider).fetchNotifications());
  }

  void markAsRead(String id) {
    if (state.hasValue) {
      final old = state.value!;
      state = AsyncData(old.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList());
    }
  }

  void markAllAsRead() {
    if (state.hasValue) {
      final old = state.value!;
      state = AsyncData(old.map((n) => n.copyWith(isRead: true)).toList());
    }
  }

  void delete(String id) {
    if (state.hasValue) {
      final old = state.value!;
      state = AsyncData(old.where((n) => n.id != id).toList());
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(NotificationsNotifier.new);

// --- FAQs Provider ---
class FaqsNotifier extends AsyncNotifier<List<FaqModel>> {
  @override
  Future<List<FaqModel>> build() async {
    return ref.watch(settingsServiceProvider).fetchFAQs();
  }
}

final faqsProvider = AsyncNotifierProvider<FaqsNotifier, List<FaqModel>>(FaqsNotifier.new);

// --- Support Tickets Provider ---
class TicketsNotifier extends AsyncNotifier<List<SupportTicketModel>> {
  @override
  Future<List<SupportTicketModel>> build() async {
    return ref.watch(settingsServiceProvider).fetchTickets();
  }

  Future<void> raiseTicket({
    required String subject,
    required String category,
    required String description,
    File? screenshot,
  }) async {
    final newT = await ref.read(settingsServiceProvider).createTicket(
          subject: subject,
          category: category,
          description: description,
          screenshot: screenshot,
        );
    if (state.hasValue) {
      state = AsyncData([newT, ...state.value!]);
    } else {
      state = AsyncData([newT]);
    }
  }
}

final ticketsProvider = AsyncNotifierProvider<TicketsNotifier, List<SupportTicketModel>>(TicketsNotifier.new);

// --- Live Chat Message Model ---
class ChatMessage {
  final String id;
  final String text;
  final String sender; // 'user' or 'agent'
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatState({required this.messages, required this.isTyping});
}

// --- Live Chat Support Provider ---
class LiveChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(
      messages: [
        ChatMessage(
          id: '1',
          text: 'Hello! Welcome to Carrom Pro Live Support. How can we help you today?',
          sender: 'agent',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        )
      ],
      isTyping: false,
    );
  }

  final List<String> _botReplies = [
    'I understand your concern. Let me look into that transaction for you right now.',
    'Could you please share the transaction reference ID or your registered email/phone number?',
    'This is typically resolved within 2 hours. I have escalated this issue to our technical support team.',
    'Is there anything else I can assist you with regarding your Carrom Pro account?',
    'Thank you for contacting us. Have a great day and happy gaming!',
  ];

  int _replyIndex = 0;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      sender: 'user',
      createdAt: DateTime.now(),
    );

    final updatedMsgs = [...state.messages, userMsg];
    state = ChatState(messages: updatedMsgs, isTyping: true);

    Future.delayed(const Duration(seconds: 2), () {
      final replyText = _botReplies[_replyIndex % _botReplies.length];
      _replyIndex++;

      final botMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: replyText,
        sender: 'agent',
        createdAt: DateTime.now(),
      );

      state = ChatState(messages: [...state.messages, botMsg], isTyping: false);
    });
  }
}

final liveChatProvider = NotifierProvider<LiveChatNotifier, ChatState>(LiveChatNotifier.new);
