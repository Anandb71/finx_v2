enum ChallengeType { daily, weekly, monthly, special }

enum ChallengeStatus { locked, available, inProgress, completed, expired }

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeStatus status;
  final int xpReward;
  final int coinReward; // Virtual currency for customization
  final Map<String, dynamic> requirements;
  final Map<String, dynamic> progress;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? icon;
  final String? mascotMessage;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.xpReward,
    this.coinReward = 0,
    required this.requirements,
    required this.progress,
    this.startDate,
    this.endDate,
    this.icon,
    this.mascotMessage,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeStatus? status,
    int? xpReward,
    int? coinReward,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? progress,
    DateTime? startDate,
    DateTime? endDate,
    String? icon,
    String? mascotMessage,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      requirements: requirements ?? this.requirements,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      icon: icon ?? this.icon,
      mascotMessage: mascotMessage ?? this.mascotMessage,
    );
  }

  // Calculate completion percentage
  double get completionPercentage {
    if (requirements.isEmpty) return 0.0;

    double totalProgress = 0.0;
    requirements.forEach((key, requiredValue) {
      final currentValue = progress[key] ?? 0;
      final required = requiredValue as num;
      totalProgress += (currentValue / required).clamp(0.0, 1.0);
    });

    return totalProgress / requirements.length;
  }

  // Check if challenge is completed
  bool get isCompleted {
    if (requirements.isEmpty) return false;

    for (final entry in requirements.entries) {
      final currentValue = progress[entry.key] ?? 0;
      final requiredValue = entry.value as num;
      if (currentValue < requiredValue) return false;
    }

    return true;
  }

  // Check if challenge is expired
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  // Get time remaining
  Duration? get timeRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return Duration.zero;
    return endDate!.difference(now);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'requirements': requirements,
      'progress': progress,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'icon': icon,
      'mascotMessage': mascotMessage,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.daily,
      ),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChallengeStatus.locked,
      ),
      xpReward: json['xpReward'],
      coinReward: json['coinReward'] ?? 0,
      requirements: Map<String, dynamic>.from(json['requirements']),
      progress: Map<String, dynamic>.from(json['progress']),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      icon: json['icon'],
      mascotMessage: json['mascotMessage'],
    );
  }
}
