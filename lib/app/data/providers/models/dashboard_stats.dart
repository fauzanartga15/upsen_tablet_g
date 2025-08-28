class DashboardStats {
  final int totalEmployees;
  final int checkedIn;
  final int checkedOut;
  final double onTimePercentage;
  final int lateCount;
  final DateTime lastUpdated;

  DashboardStats({
    required this.totalEmployees,
    required this.checkedIn,
    required this.checkedOut,
    required this.onTimePercentage,
    required this.lateCount,
    required this.lastUpdated,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEmployees: json['total_employees'] ?? 0,
      checkedIn: json['checked_in'] ?? 0,
      checkedOut: json['checked_out'] ?? 0,
      onTimePercentage: (json['on_time_percentage'] ?? 0.0).toDouble(),
      lateCount: json['late_count'] ?? 0,
      lastUpdated: DateTime.now(),
    );
  }
}
