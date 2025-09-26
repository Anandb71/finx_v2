// lib/models/leaderboard_entry.dart

class LeaderboardEntry {
  final String name;
  final int level;
  final double value;
  final double change;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.name,
    required this.level,
    required this.value,
    required this.change,
    required this.isCurrentUser,
  });
}
