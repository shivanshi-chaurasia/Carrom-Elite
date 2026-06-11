class CarromMatchModel {
  final String id;
  final num entryFee;
  final num prizePool;
  final String mode; // 1v1, private, bot
  final String player1Name;
  final String player2Name;
  final String status; // upcoming, live, completed

  CarromMatchModel({
    required this.id,
    required this.entryFee,
    required this.prizePool,
    required this.mode,
    required this.player1Name,
    required this.player2Name,
    required this.status,
  });

  factory CarromMatchModel.fromJson(Map<String, dynamic> json) {
    return CarromMatchModel(
      id: json['id']?.toString() ?? '',
      entryFee: num.tryParse('${json['entryFee'] ?? 0}') ?? 0,
      prizePool: num.tryParse('${json['prizePool'] ?? 0}') ?? 0,
      mode: json['mode']?.toString() ?? '1v1',
      player1Name: json['player1Name']?.toString() ?? '',
      player2Name: json['player2Name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'upcoming',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'entryFee': entryFee,
        'prizePool': prizePool,
        'mode': mode,
        'player1Name': player1Name,
        'player2Name': player2Name,
        'status': status,
      };

  factory CarromMatchModel.mock(String id, {String mode = '1v1'}) {
    return CarromMatchModel(
      id: id,
      entryFee: mode == 'bot' ? 0 : 50,
      prizePool: mode == 'bot' ? 0 : 90,
      mode: mode,
      player1Name: 'Shiva (You)',
      player2Name: mode == 'bot' ? 'CarromBot' : 'StrikerKing',
      status: 'upcoming',
    );
  }
}

class CarromRoomModel {
  final String code;
  final bool isHost;
  final bool opponentJoined;
  final String status; // waiting, playing, finished

  CarromRoomModel({
    required this.code,
    required this.isHost,
    required this.opponentJoined,
    required this.status,
  });

  factory CarromRoomModel.fromJson(Map<String, dynamic> json) => CarromRoomModel(
        code: json['code']?.toString() ?? '',
        isHost: json['isHost'] == true,
        opponentJoined: json['opponentJoined'] == true,
        status: json['status']?.toString() ?? 'waiting',
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'isHost': isHost,
        'opponentJoined': opponentJoined,
        'status': status,
      };
}
