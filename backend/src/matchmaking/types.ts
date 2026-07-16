export interface QueueEntryData {
  userId: string;
  entryFee: number;
  joinedAt: number;
  rating?: number;
}

export interface MatchCandidate {
  entries: QueueEntryData[];
  entryFee: number;
  prizePool: number;
}

export interface MatchmakingConfig {
  minPlayersPerMatch: number;
  maxPlayersPerMatch: number;
  searchTimeoutMs: number;
  ratingRange: number;
  ratingRangeExpansionMs: number;
  maxRatingRange: number;
}

export interface MatchResult {
  matchId: string;
  winnerId: string;
  winnerPrize: number;
  runnerUpId?: string;
  runnerUpPrize?: number;
  scores: Record<string, number>;
  duration: number;
  totalTurns: number;
}
