import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/carrom_models.dart';
import 'service_providers.dart';

class MatchmakerState {
  final bool isSearching;
  final CarromMatchModel? match;
  final String? error;

  MatchmakerState({this.isSearching = false, this.match, this.error});
}

final matchmakerProvider = NotifierProvider<MatchmakerNotifier, MatchmakerState>(MatchmakerNotifier.new);

class MatchmakerNotifier extends Notifier<MatchmakerState> {
  @override
  MatchmakerState build() => MatchmakerState();

  Future<void> findMatch(num entryFee) async {
    state = MatchmakerState(isSearching: true);
    try {
      var match = await ref.read(carromServiceProvider).findPublicMatch(entryFee);
      state = MatchmakerState(match: match);
    } catch (e) {
      state = MatchmakerState(error: e.toString());
    }
  }

  void reset() => state = MatchmakerState();
}

class PrivateRoomState {
  final bool isLoading;
  final CarromRoomModel? room;
  final String? error;

  PrivateRoomState({this.isLoading = false, this.room, this.error});
}

final privateRoomProvider = NotifierProvider<PrivateRoomNotifier, PrivateRoomState>(PrivateRoomNotifier.new);

class PrivateRoomNotifier extends Notifier<PrivateRoomState> {
  @override
  PrivateRoomState build() => PrivateRoomState();

  Future<void> create() async {
    state = PrivateRoomState(isLoading: true);
    try {
      var room = await ref.read(carromServiceProvider).createRoom();
      state = PrivateRoomState(room: room);
    } catch (e) {
      state = PrivateRoomState(error: e.toString());
    }
  }

  Future<void> join(String code) async {
    state = PrivateRoomState(isLoading: true);
    try {
      var room = await ref.read(carromServiceProvider).joinRoom(code);
      state = PrivateRoomState(room: room);
    } catch (e) {
      state = PrivateRoomState(error: e.toString());
    }
  }

  void reset() => state = PrivateRoomState();
}

class VoiceChatState {
  final bool isMuted;
  final bool isSpeaking;
  final String device; // 'speaker' or 'headphone'

  VoiceChatState({
    required this.isMuted,
    required this.isSpeaking,
    required this.device,
  });

  VoiceChatState copyWith({
    bool? isMuted,
    bool? isSpeaking,
    String? device,
  }) {
    return VoiceChatState(
      isMuted: isMuted ?? this.isMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      device: device ?? this.device,
    );
  }
}

class VoiceChatNotifier extends Notifier<VoiceChatState> {
  @override
  VoiceChatState build() {
    return VoiceChatState(
      isMuted: false,
      isSpeaking: false,
      device: 'speaker',
    );
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted, isSpeaking: false);
  }

  void setSpeaking(bool speaking) {
    if (state.isMuted) return;
    state = state.copyWith(isSpeaking: speaking);
  }

  void toggleDevice() {
    state = state.copyWith(
      device: state.device == 'speaker' ? 'headphone' : 'speaker',
    );
  }
}

final voiceChatProvider =
    NotifierProvider<VoiceChatNotifier, VoiceChatState>(VoiceChatNotifier.new);
