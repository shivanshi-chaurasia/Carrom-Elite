class VipTierModel {
  final int level;
  final String title;
  final double cashbackPct;
  final List<String> benefits;
  final int pointsRequired;

  VipTierModel({
    required this.level,
    required this.title,
    required this.cashbackPct,
    required this.benefits,
    required this.pointsRequired,
  });

  static List<VipTierModel> mockTiers() {
    return [
      VipTierModel(
        level: 1,
        title: 'Bronze Star',
        cashbackPct: 0.0,
        benefits: ['Standard game entries', 'Standard deposits', 'Daily basic login rewards'],
        pointsRequired: 0,
      ),
      VipTierModel(
        level: 2,
        title: 'Silver Elite',
        cashbackPct: 2.0,
        benefits: ['2% instant cashback on deposits', 'Priority chat support', 'Exclusive Silver weekly tournaments'],
        pointsRequired: 500,
      ),
      VipTierModel(
        level: 3,
        title: 'Gold VIP',
        cashbackPct: 5.0,
        benefits: ['5% instant cashback on deposits', 'Zero withdrawal fee', 'Personalized account assistant', 'Gold lobby access'],
        pointsRequired: 2000,
      ),
      VipTierModel(
        level: 4,
        title: 'Platinum Legend',
        cashbackPct: 10.0,
        benefits: ['10% instant cashback on deposits', 'Express bank withdrawal (within 1 min)', 'Special birthday gifts', 'Platinum tournament access'],
        pointsRequired: 5000,
      ),
    ];
  }
}

class RewardMilestoneModel {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final num rewardCash;
  final int progress;
  final int target;
  final bool isClaimed;

  RewardMilestoneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.rewardCash,
    required this.progress,
    required this.target,
    required this.isClaimed,
  });

  bool get isCompleted => progress >= target;

  RewardMilestoneModel copyWith({
    String? id,
    String? title,
    String? description,
    int? rewardCoins,
    num? rewardCash,
    int? progress,
    int? target,
    bool? isClaimed,
  }) {
    return RewardMilestoneModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardCash: rewardCash ?? this.rewardCash,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  static List<RewardMilestoneModel> mockList() {
    return [
      RewardMilestoneModel(
        id: 'ms_1',
        title: 'First Win of the Day',
        description: 'Win any 1v1 match in public lobby',
        rewardCoins: 50,
        rewardCash: 5,
        progress: 1,
        target: 1,
        isClaimed: false,
      ),
      RewardMilestoneModel(
        id: 'ms_2',
        title: 'Lucky Striker',
        description: 'Buy 2 ticket entries in the Mega Lottery',
        rewardCoins: 120,
        rewardCash: 0,
        progress: 1,
        target: 2,
        isClaimed: false,
      ),
      RewardMilestoneModel(
        id: 'ms_3',
        title: 'Social Circle',
        description: 'Refer 3 friends who successfully complete KYC',
        rewardCoins: 300,
        rewardCash: 25,
        progress: 1,
        target: 3,
        isClaimed: false,
      ),
      RewardMilestoneModel(
        id: 'ms_4',
        title: 'Arena Dominator',
        description: 'Play 5 public matches in Carrom King',
        rewardCoins: 150,
        rewardCash: 10,
        progress: 3,
        target: 5,
        isClaimed: false,
      ),
    ];
  }
}
