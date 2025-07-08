class StampActivation {
  final String username;
  final int activeStamps;
  final int totalStamps;
  final String timeAgo;

  StampActivation({
    required this.username,
    required this.activeStamps,
    required this.totalStamps,
    required this.timeAgo,
  });

  factory StampActivation.fromJson(Map<String, dynamic> json) {
    return StampActivation(
      username: json['username'] ?? 'Unknown User',
      activeStamps: json['active_stamps'] ?? 0,
      totalStamps: json['total_stamps'] ?? 0,
      timeAgo: json['time_ago'] ?? 'Just now',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': _truncateName(username),
      'active_stamps': activeStamps,
      'total_stamps': totalStamps,
      'time_ago': timeAgo,
    };
  }

  String _truncateName(String name) {
    if (name.length > 6) {
      return '${name.substring(0, 5)}...';
    }
    return name;
  }
}
