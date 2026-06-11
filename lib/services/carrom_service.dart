import 'dart:math';
import '../models/carrom_models.dart';
import 'api_service.dart';

class CarromService {
  CarromService(this.api);

  final ApiService api;

  Future<CarromRoomModel> createRoom() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // generate random 6 digit code
    var code = (100000 + Random().nextInt(900000)).toString();
    return CarromRoomModel(code: code, isHost: true, opponentJoined: false, status: 'waiting');
  }

  Future<CarromRoomModel> joinRoom(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return CarromRoomModel(code: code, isHost: false, opponentJoined: true, status: 'playing');
  }

  Future<CarromMatchModel> findPublicMatch(num entryFee) async {
    await Future<void>.delayed(const Duration(seconds: 2)); // simulate matchmaking delay
    return CarromMatchModel(
      id: 'm_${1000 + Random().nextInt(9000)}',
      entryFee: entryFee,
      prizePool: entryFee * 1.8,
      mode: '1v1',
      player1Name: 'Shiva (You)',
      player2Name: 'Viper_99',
      status: 'live',
    );
  }

  void sendEmoji(String emoji) {
    // In a production app, this would emit a Socket.IO event
    // e.g. socket.emit('match_emoji', {'emoji': emoji});
    print('Broadcasting emoji to opponent: $emoji');
  }
}
