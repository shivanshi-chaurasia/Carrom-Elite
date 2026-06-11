class HomeDashboardModel {
  final PlayerSummaryModel player;
  final WalletSummaryModel wallet;
  final List<GameCardModel> featuredGames;
  final List<TournamentBannerModel> tournaments;
  final List<LotteryHighlightModel> lotteryHighlights;
  final List<RewardModel> dailyRewards;
  final List<PromoBannerModel> promos;
  final List<EventModel> events;
  final List<NewsModel> news;

  HomeDashboardModel({
    required this.player,
    required this.wallet,
    required this.featuredGames,
    required this.tournaments,
    required this.lotteryHighlights,
    required this.dailyRewards,
    required this.promos,
    required this.events,
    required this.news,
  });

  HomeDashboardModel copyWith({
    PlayerSummaryModel? player,
    WalletSummaryModel? wallet,
    List<GameCardModel>? featuredGames,
    List<TournamentBannerModel>? tournaments,
    List<LotteryHighlightModel>? lotteryHighlights,
    List<RewardModel>? dailyRewards,
    List<PromoBannerModel>? promos,
    List<EventModel>? events,
    List<NewsModel>? news,
  }) {
    return HomeDashboardModel(
      player: player ?? this.player,
      wallet: wallet ?? this.wallet,
      featuredGames: featuredGames ?? this.featuredGames,
      tournaments: tournaments ?? this.tournaments,
      lotteryHighlights: lotteryHighlights ?? this.lotteryHighlights,
      dailyRewards: dailyRewards ?? this.dailyRewards,
      promos: promos ?? this.promos,
      events: events ?? this.events,
      news: news ?? this.news,
    );
  }


  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      player: PlayerSummaryModel.fromJson(json['player'] ?? {}),
      wallet: WalletSummaryModel.fromJson(json['wallet'] ?? {}),
      featuredGames: _list(json['featuredGames'], GameCardModel.fromJson),
      tournaments: _list(json['tournaments'], TournamentBannerModel.fromJson),
      lotteryHighlights: _list(json['lotteryHighlights'], LotteryHighlightModel.fromJson),
      dailyRewards: _list(json['dailyRewards'], RewardModel.fromJson),
      promos: _list(json['promos'], PromoBannerModel.fromJson),
      events: _list(json['events'], EventModel.fromJson),
      news: _list(json['news'], NewsModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'player': player.toJson(),
        'wallet': wallet.toJson(),
        'featuredGames': featuredGames.map((e) => e.toJson()).toList(),
        'tournaments': tournaments.map((e) => e.toJson()).toList(),
        'lotteryHighlights': lotteryHighlights.map((e) => e.toJson()).toList(),
        'dailyRewards': dailyRewards.map((e) => e.toJson()).toList(),
        'promos': promos.map((e) => e.toJson()).toList(),
        'events': events.map((e) => e.toJson()).toList(),
        'news': news.map((e) => e.toJson()).toList(),
      };

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) map) {
    final items = raw is List ? raw : const [];
    return items.map((e) => map(Map<String, dynamic>.from(e as Map))).toList();
  }

  factory HomeDashboardModel.mock() {
    return HomeDashboardModel(
      player: PlayerSummaryModel(
        id: 'u_1001',
        name: 'Guest Player',
        level: 12,
        avatar: '',
        winRate: 68,
      ),
      wallet: WalletSummaryModel(
        deposit: 1200,
        winnings: 840,
        bonus: 150,
      ),
      featuredGames: [
        GameCardModel(
          id: 'quick_1v1',
          title: 'Carrom 1v1',
          subtitle: 'Real players online',
          entryFee: 25,
          prize: 45,
          onlinePlayers: 1820,
          accent: 'gold',
          icon: 'sports_esports',
        ),
        GameCardModel(
          id: 'practice',
          title: 'Practice',
          subtitle: 'Warm up with bot',
          entryFee: 0,
          prize: 0,
          onlinePlayers: 0,
          accent: 'teal',
          icon: 'psychology',
        ),
        GameCardModel(
          id: 'lottery_daily',
          title: 'Daily Lottery',
          subtitle: 'Draw closes tonight',
          entryFee: 10,
          prize: 25000,
          onlinePlayers: 6250,
          accent: 'purple',
          icon: 'confirmation_number',
        ),
      ],
      tournaments: [
        TournamentBannerModel(
          id: 'mega_sunday',
          title: 'Mega Sunday Clash',
          subtitle: '128 players, knockout format',
          prizePool: 50000,
          entryFee: 99,
          startsIn: '02h 18m',
          seatsLeft: 41,
        ),
        TournamentBannerModel(
          id: 'rookie_cup',
          title: 'Rookie Cup',
          subtitle: 'Low entry, fast games',
          prizePool: 8000,
          entryFee: 19,
          startsIn: '48m',
          seatsLeft: 13,
        ),
      ],
      lotteryHighlights: [
        LotteryHighlightModel(
          id: 'daily_8pm',
          title: '8 PM Jackpot',
          jackpot: 100000,
          ticketPrice: 20,
          drawTime: '8:00 PM',
          soldPercent: .72,
        ),
        LotteryHighlightModel(
          id: 'bonus_spin',
          title: 'Bonus Spin Draw',
          jackpot: 15000,
          ticketPrice: 5,
          drawTime: '10:30 PM',
          soldPercent: .44,
        ),
      ],
      dailyRewards: [
        RewardModel(day: 1, title: 'Coins', value: '100', claimed: true),
        RewardModel(day: 2, title: 'Bonus cash', value: '₹10', claimed: false),
        RewardModel(day: 3, title: 'Ticket', value: '1x', claimed: false),
        RewardModel(day: 4, title: 'Coins', value: '250', claimed: false),
        RewardModel(day: 5, title: 'Mega ticket', value: '1x', claimed: false),
      ],
      promos: [
        PromoBannerModel(
          id: 'first_deposit',
          title: '100% Deposit Bonus',
          subtitle: 'Add ₹100 or more and double your first play balance.',
          cta: 'View offer',
        ),
      ],
      events: [
        EventModel(
          id: 'queen_rule',
          title: 'Queen Challenge',
          body: 'Pocket queen twice today and unlock a free lottery ticket.',
          tag: 'Live',
        ),
        EventModel(
          id: 'maintenance',
          title: 'Server upgrade',
          body: 'Realtime rooms may restart at 3:00 AM.',
          tag: 'Notice',
        ),
      ],
      news: [
        NewsModel(title: 'Cashfree withdrawals are being prepared.', time: 'Today'),
        NewsModel(title: 'New weekend tournament brackets will open soon.', time: '2h ago'),
      ],
    );
  }
}

class PlayerSummaryModel {
  final String id;
  final String name;
  final String avatar;
  final int level;
  final num winRate;

  PlayerSummaryModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
    required this.winRate,
  });

  factory PlayerSummaryModel.fromJson(Map<String, dynamic> json) => PlayerSummaryModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        avatar: json['avatar']?.toString() ?? '',
        level: int.tryParse('${json['level'] ?? 1}') ?? 1,
        winRate: num.tryParse('${json['winRate'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'level': level,
        'winRate': winRate,
      };
}

class WalletSummaryModel {
  final num deposit;
  final num winnings;
  final num bonus;

  WalletSummaryModel({required this.deposit, required this.winnings, required this.bonus});

  num get total => deposit + winnings + bonus;

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) => WalletSummaryModel(
        deposit: num.tryParse('${json['deposit'] ?? 0}') ?? 0,
        winnings: num.tryParse('${json['winnings'] ?? 0}') ?? 0,
        bonus: num.tryParse('${json['bonus'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'deposit': deposit,
        'winnings': winnings,
        'bonus': bonus,
      };
}

class GameCardModel {
  final String id, title, subtitle, accent, icon;
  final num entryFee, prize;
  final int onlinePlayers;

  GameCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.entryFee,
    required this.prize,
    required this.onlinePlayers,
    required this.accent,
    required this.icon,
  });

  factory GameCardModel.fromJson(Map<String, dynamic> json) => GameCardModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        entryFee: num.tryParse('${json['entryFee'] ?? 0}') ?? 0,
        prize: num.tryParse('${json['prize'] ?? 0}') ?? 0,
        onlinePlayers: int.tryParse('${json['onlinePlayers'] ?? 0}') ?? 0,
        accent: json['accent']?.toString() ?? 'gold',
        icon: json['icon']?.toString() ?? 'sports_esports',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'entryFee': entryFee,
        'prize': prize,
        'onlinePlayers': onlinePlayers,
        'accent': accent,
        'icon': icon,
      };
}

class TournamentBannerModel {
  final String id, title, subtitle, startsIn;
  final num prizePool, entryFee;
  final int seatsLeft;

  TournamentBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.prizePool,
    required this.entryFee,
    required this.startsIn,
    required this.seatsLeft,
  });

  factory TournamentBannerModel.fromJson(Map<String, dynamic> json) => TournamentBannerModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        prizePool: num.tryParse('${json['prizePool'] ?? 0}') ?? 0,
        entryFee: num.tryParse('${json['entryFee'] ?? 0}') ?? 0,
        startsIn: json['startsIn']?.toString() ?? '',
        seatsLeft: int.tryParse('${json['seatsLeft'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'prizePool': prizePool,
        'entryFee': entryFee,
        'startsIn': startsIn,
        'seatsLeft': seatsLeft,
      };
}

class LotteryHighlightModel {
  final String id, title, drawTime;
  final num jackpot, ticketPrice;
  final double soldPercent;

  LotteryHighlightModel({
    required this.id,
    required this.title,
    required this.jackpot,
    required this.ticketPrice,
    required this.drawTime,
    required this.soldPercent,
  });

  factory LotteryHighlightModel.fromJson(Map<String, dynamic> json) => LotteryHighlightModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        jackpot: num.tryParse('${json['jackpot'] ?? 0}') ?? 0,
        ticketPrice: num.tryParse('${json['ticketPrice'] ?? 0}') ?? 0,
        drawTime: json['drawTime']?.toString() ?? '',
        soldPercent: double.tryParse('${json['soldPercent'] ?? 0}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'jackpot': jackpot,
        'ticketPrice': ticketPrice,
        'drawTime': drawTime,
        'soldPercent': soldPercent,
      };
}

class RewardModel {
  final int day;
  final String title, value;
  final bool claimed;

  RewardModel({
    required this.day,
    required this.title,
    required this.value,
    required this.claimed,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
        day: int.tryParse('${json['day'] ?? 1}') ?? 1,
        title: json['title']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        claimed: json['claimed'] == true,
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'title': title,
        'value': value,
        'claimed': claimed,
      };
}

class PromoBannerModel {
  final String id, title, subtitle, cta;

  PromoBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) => PromoBannerModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        cta: json['cta']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'cta': cta,
      };
}

class EventModel {
  final String id, title, body, tag;

  EventModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        tag: json['tag']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body, 'tag': tag};
}

class NewsModel {
  final String title, time;

  NewsModel({required this.title, required this.time});

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        title: json['title']?.toString() ?? '',
        time: json['time']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'title': title, 'time': time};
}
