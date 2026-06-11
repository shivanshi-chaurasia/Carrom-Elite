import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rewards_models.dart';
import 'wallet_providers.dart';

class RewardsState {
  final int coins;
  final int vipPoints;
  final List<RewardMilestoneModel> milestones;
  final List<int> claimedDays; 

  RewardsState({
    required this.coins,
    required this.vipPoints,
    required this.milestones,
    required this.claimedDays,
  });

  RewardsState copyWith({
    int? coins,
    int? vipPoints,
    List<RewardMilestoneModel>? milestones,
    List<int>? claimedDays,
  }) {
    return RewardsState(
      coins: coins ?? this.coins,
      vipPoints: vipPoints ?? this.vipPoints,
      milestones: milestones ?? this.milestones,
      claimedDays: claimedDays ?? this.claimedDays,
    );
  }
}

class RewardsNotifier extends Notifier<RewardsState> {
  @override
  RewardsState build() {
    return RewardsState(
      coins: 450,
      vipPoints: 350,
      milestones: RewardMilestoneModel.mockList(),
      claimedDays: [1, 2],
    );
  }

  void claimMilestone(String id) async {
    var list = state.milestones;
    var idx = list.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    
    var m = list[idx];
    if (!m.isCompleted || m.isClaimed) return;

    var updatedMilestone = m.copyWith(isClaimed: true);
    var newMilestones = List<RewardMilestoneModel>.from(list);
    newMilestones[idx] = updatedMilestone;

    var addCoins = m.rewardCoins;
    var addCash = m.rewardCash;

    state = state.copyWith(
      coins: state.coins + addCoins,
      vipPoints: state.vipPoints + (addCoins ~/ 5), 
      milestones: newMilestones,
    );

    if (addCash > 0) {
      await ref.read(walletDetailsProvider.notifier).awardBonus(addCash);
    }
  }

  Future<bool> convertCoins(int coinAmount) async {
    if (coinAmount <= 0 || state.coins < coinAmount) return false;

    var conversionRate = 0.1; 
    var cashAward = coinAmount * conversionRate;

    state = state.copyWith(
      coins: state.coins - coinAmount,
    );

    await ref.read(walletDetailsProvider.notifier).awardBonus(cashAward);
    return true;
  }

  Future<bool> claimDailyBonus(int day, int coinsReward, num cashReward) async {
    if (state.claimedDays.contains(day)) return false;

    var newClaimed = List<int>.from(state.claimedDays)..add(day);

    state = state.copyWith(
      coins: state.coins + coinsReward,
      vipPoints: state.vipPoints + (coinsReward ~/ 5),
      claimedDays: newClaimed,
    );

    if (cashReward > 0) {
      await ref.read(walletDetailsProvider.notifier).awardBonus(cashReward);
    }
    return true;
  }
}

final rewardsProvider = NotifierProvider<RewardsNotifier, RewardsState>(RewardsNotifier.new);
