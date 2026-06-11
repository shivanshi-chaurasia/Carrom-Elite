class TournamentDetailModel {
  final String id;
  final String title;
  final String subtitle;
  final num prizePool;
  final num entryFee;
  final String startsIn;
  final int totalSeats;
  final int registeredSeats;
  final String status; // upcoming, live, completed
  final List<String> rules;
  final List<PrizeDistributionModel> prizes;
  final List<TournamentMatchModel> matches;

  TournamentDetailModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.prizePool,
    required this.entryFee,
    required this.startsIn,
    required this.totalSeats,
    required this.registeredSeats,
    required this.status,
    required this.rules,
    required this.prizes,
    required this.matches,
  });

  bool get isRegistered => id == 'mega_sunday'; // mock registered state for Sunday clash

  factory TournamentDetailModel.fromJson(Map<String, dynamic> json) {
    return TournamentDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      prizePool: num.tryParse('${json['prizePool'] ?? 0}') ?? 0,
      entryFee: num.tryParse('${json['entryFee'] ?? 0}') ?? 0,
      startsIn: json['startsIn']?.toString() ?? '',
      totalSeats: int.tryParse('${json['totalSeats'] ?? 0}') ?? 0,
      registeredSeats: int.tryParse('${json['registeredSeats'] ?? 0}') ?? 0,
      status: json['status']?.toString() ?? 'upcoming',
      rules: List<String>.from(json['rules'] ?? const []),
      prizes: (json['prizes'] as List?)
              ?.map((e) => PrizeDistributionModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      matches: (json['matches'] as List?)
              ?.map((e) => TournamentMatchModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'prizePool': prizePool,
        'entryFee': entryFee,
        'startsIn': startsIn,
        'totalSeats': totalSeats,
        'registeredSeats': registeredSeats,
        'status': status,
        'rules': rules,
        'prizes': prizes.map((e) => e.toJson()).toList(),
        'matches': matches.map((e) => e.toJson()).toList(),
      };

  factory TournamentDetailModel.mock(String id) {
    return TournamentDetailModel(
      id: id,
      title: id == 'mega_sunday' ? 'Mega Sunday Clash' : 'Rookie Cup',
      subtitle: id == 'mega_sunday' ? '128 players, knockout format' : 'Low entry, fast games',
      prizePool: id == 'mega_sunday' ? 50000 : 8000,
      entryFee: id == 'mega_sunday' ? 99 : 19,
      startsIn: id == 'mega_sunday' ? '02h 18m' : '48m',
      totalSeats: id == 'mega_sunday' ? 128 : 32,
      registeredSeats: id == 'mega_sunday' ? 87 : 19,
      status: 'upcoming',
      rules: [
        'Each match has a 10-minute time limit.',
        'First player to pocket all their coins + queen wins.',
        'Using cheats or double accounts results in a ban.',
        'Refunds are only issued if the tournament is cancelled.',
      ],
      prizes: [
        PrizeDistributionModel(rank: '1st Place', prize: id == 'mega_sunday' ? 25000 : 4000),
        PrizeDistributionModel(rank: '2nd Place', prize: id == 'mega_sunday' ? 12000 : 2000),
        PrizeDistributionModel(rank: '3rd - 4th', prize: id == 'mega_sunday' ? 4000 : 600),
        PrizeDistributionModel(rank: '5th - 8th', prize: id == 'mega_sunday' ? 1250 : 200),
      ],
      matches: [
        TournamentMatchModel(
          id: 'm1',
          player1Name: 'Shiva (You)',
          player1Avatar: '',
          player2Name: 'Viper_99',
          player2Avatar: '',
          player1Score: 0,
          player2Score: 0,
          status: 'upcoming',
          matchTime: 'Starts in 10m',
          roundName: 'Round of 16',
        ),
        TournamentMatchModel(
          id: 'm2',
          player1Name: 'Ace_Gamer',
          player1Avatar: '',
          player2Name: 'StrikerKing',
          player2Avatar: '',
          player1Score: 12,
          player2Score: 8,
          status: 'completed',
          matchTime: 'Finished',
          roundName: 'Round of 16',
        ),
        TournamentMatchModel(
          id: 'm3',
          player1Name: 'ShadowBolt',
          player1Avatar: '',
          player2Name: 'ZenCarrom',
          player2Avatar: '',
          player1Score: 4,
          player2Score: 5,
          status: 'live',
          matchTime: 'Live',
          roundName: 'Round of 16',
        ),
      ],
    );
  }
}

class PrizeDistributionModel {
  final String rank;
  final num prize;

  PrizeDistributionModel({required this.rank, required this.prize});

  factory PrizeDistributionModel.fromJson(Map<String, dynamic> json) => PrizeDistributionModel(
        rank: json['rank']?.toString() ?? '',
        prize: num.tryParse('${json['prize'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {'rank': rank, 'prize': prize};
}

class TournamentMatchModel {
  final String id;
  final String player1Name;
  final String player1Avatar;
  final String player2Name;
  final String player2Avatar;
  final int player1Score;
  final int player2Score;
  final String status; // upcoming, live, completed
  final String matchTime;
  final String roundName;

  TournamentMatchModel({
    required this.id,
    required this.player1Name,
    required this.player1Avatar,
    required this.player2Name,
    required this.player2Avatar,
    required this.player1Score,
    required this.player2Score,
    required this.status,
    required this.matchTime,
    required this.roundName,
  });

  factory TournamentMatchModel.fromJson(Map<String, dynamic> json) {
    return TournamentMatchModel(
      id: json['id']?.toString() ?? '',
      player1Name: json['player1Name']?.toString() ?? '',
      player1Avatar: json['player1Avatar']?.toString() ?? '',
      player2Name: json['player2Name']?.toString() ?? '',
      player2Avatar: json['player2Avatar']?.toString() ?? '',
      player1Score: int.tryParse('${json['player1Score'] ?? 0}') ?? 0,
      player2Score: int.tryParse('${json['player2Score'] ?? 0}') ?? 0,
      status: json['status']?.toString() ?? 'upcoming',
      matchTime: json['matchTime']?.toString() ?? '',
      roundName: json['roundName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'player1Name': player1Name,
        'player1Avatar': player1Avatar,
        'player2Name': player2Name,
        'player2Avatar': player2Avatar,
        'player1Score': player1Score,
        'player2Score': player2Score,
        'status': status,
        'matchTime': matchTime,
        'roundName': roundName,
      };
}

class TournamentLeaderboardModel {
  final int rank;
  final String playerName;
  final String avatar;
  final int score;
  final String prize;

  TournamentLeaderboardModel({
    required this.rank,
    required this.playerName,
    required this.avatar,
    required this.score,
    required this.prize,
  });

  factory TournamentLeaderboardModel.fromJson(Map<String, dynamic> json) => TournamentLeaderboardModel(
        rank: int.tryParse('${json['rank'] ?? 0}') ?? 0,
        playerName: json['playerName']?.toString() ?? '',
        avatar: json['avatar']?.toString() ?? '',
        score: int.tryParse('${json['score'] ?? 0}') ?? 0,
        prize: json['prize']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'playerName': playerName,
        'avatar': avatar,
        'score': score,
        'prize': prize,
      };

  static List<TournamentLeaderboardModel> mockList() {
    return [
      TournamentLeaderboardModel(rank: 1, playerName: 'StrikerKing', avatar: '', score: 120, prize: '₹25,000'),
      TournamentLeaderboardModel(rank: 2, playerName: 'Viper_99', avatar: '', score: 95, prize: '₹12,000'),
      TournamentLeaderboardModel(rank: 3, playerName: 'Shiva (You)', avatar: '', score: 90, prize: '₹4,000'),
      TournamentLeaderboardModel(rank: 4, playerName: 'Ace_Gamer', avatar: '', score: 85, prize: '₹4,000'),
      TournamentLeaderboardModel(rank: 5, playerName: 'ShadowBolt', avatar: '', score: 70, prize: '₹1,250'),
      TournamentLeaderboardModel(rank: 6, playerName: 'ZenCarrom', avatar: '', score: 68, prize: '₹1,250'),
      TournamentLeaderboardModel(rank: 7, playerName: 'AlphaPlr', avatar: '', score: 50, prize: '₹1,250'),
      TournamentLeaderboardModel(rank: 8, playerName: 'PuckMaster', avatar: '', score: 45, prize: '₹1,250'),
    ];
  }
}

class TournamentBracketNodeModel {
  final String id;
  final String round;
  final String player1Name;
  final String player2Name;
  final int player1Score;
  final int player2Score;
  final String winnerName;
  final bool isLive;

  TournamentBracketNodeModel({
    required this.id,
    required this.round,
    required this.player1Name,
    required this.player2Name,
    required this.player1Score,
    required this.player2Score,
    required this.winnerName,
    required this.isLive,
  });

  factory TournamentBracketNodeModel.fromJson(Map<String, dynamic> json) => TournamentBracketNodeModel(
        id: json['id']?.toString() ?? '',
        round: json['round']?.toString() ?? '',
        player1Name: json['player1Name']?.toString() ?? '',
        player2Name: json['player2Name']?.toString() ?? '',
        player1Score: int.tryParse('${json['player1Score'] ?? 0}') ?? 0,
        player2Score: int.tryParse('${json['player2Score'] ?? 0}') ?? 0,
        winnerName: json['winnerName']?.toString() ?? '',
        isLive: json['isLive'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'round': round,
        'player1Name': player1Name,
        'player2Name': player2Name,
        'player1Score': player1Score,
        'player2Score': player2Score,
        'winnerName': winnerName,
        'isLive': isLive,
      };

  static List<TournamentBracketNodeModel> mockNodes() {
    return [
      // Quarter Finals
      TournamentBracketNodeModel(id: 'q1', round: 'Quarterfinals', player1Name: 'StrikerKing', player2Name: 'ProPlr12', player1Score: 10, player2Score: 4, winnerName: 'StrikerKing', isLive: false),
      TournamentBracketNodeModel(id: 'q2', round: 'Quarterfinals', player1Name: 'Shiva (You)', player2Name: 'PuckMaster', player1Score: 10, player2Score: 8, winnerName: 'Shiva (You)', isLive: false),
      TournamentBracketNodeModel(id: 'q3', round: 'Quarterfinals', player1Name: 'Viper_99', player2Name: 'AlphaPlr', player1Score: 10, player2Score: 6, winnerName: 'Viper_99', isLive: false),
      TournamentBracketNodeModel(id: 'q4', round: 'Quarterfinals', player1Name: 'Ace_Gamer', player2Name: 'ShadowBolt', player1Score: 10, player2Score: 9, winnerName: 'Ace_Gamer', isLive: false),

      // Semi Finals
      TournamentBracketNodeModel(id: 's1', round: 'Semifinals', player1Name: 'StrikerKing', player2Name: 'Shiva (You)', player1Score: 10, player2Score: 9, winnerName: 'StrikerKing', isLive: false),
      TournamentBracketNodeModel(id: 's2', round: 'Semifinals', player1Name: 'Viper_99', player2Name: 'Ace_Gamer', player1Score: 8, player2Score: 10, winnerName: 'Ace_Gamer', isLive: false),

      // Finals
      TournamentBracketNodeModel(id: 'f1', round: 'Finals', player1Name: 'StrikerKing', player2Name: 'Ace_Gamer', player1Score: 0, player2Score: 0, winnerName: '', isLive: true),
    ];
  }
}
