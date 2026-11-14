class DashboardModel {
  final int totalUsers;

  // Today
  final double todaySales;
  final double todayCollected;
  final double todayPending;
  final double todayCash;
  final double todayUpi;

  // Month
  final double monthSales;
  final double monthCollected;
  final double monthPending;

  // Year
  final double yearSales;
  final double yearCollected;
  final double yearPending;

  // Overall
  final double totalSales;
  final double totalCollected;
  final double totalPending;

  final int totalBills;

  DashboardModel({
    required this.totalUsers,

    required this.todaySales,
    required this.todayCollected,
    required this.todayPending,
    required this.todayCash,
    required this.todayUpi,

    required this.monthSales,
    required this.monthCollected,
    required this.monthPending,

    required this.yearSales,
    required this.yearCollected,
    required this.yearPending,

    required this.totalSales,
    required this.totalCollected,
    required this.totalPending,

    required this.totalBills,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalUsers: json["totalUsers"] ?? 0,

      todaySales: (json["todaySales"] ?? 0).toDouble(),
      todayCollected: (json["todayCollected"] ?? 0).toDouble(),
      todayPending: (json["todayPending"] ?? 0).toDouble(),
      todayCash: (json["todayCash"] ?? 0).toDouble(),
      todayUpi: (json["todayUpi"] ?? 0).toDouble(),

      monthSales: (json["monthSales"] ?? 0).toDouble(),
      monthCollected: (json["monthCollected"] ?? 0).toDouble(),
      monthPending: (json["monthPending"] ?? 0).toDouble(),

      yearSales: (json["yearSales"] ?? 0).toDouble(),
      yearCollected: (json["yearCollected"] ?? 0).toDouble(),
      yearPending: (json["yearPending"] ?? 0).toDouble(),

      totalSales: (json["totalSales"] ?? 0).toDouble(),
      totalCollected: (json["totalCollected"] ?? 0).toDouble(),
      totalPending: (json["totalPending"] ?? 0).toDouble(),

      totalBills: json["totalBills"] ?? 0,
    );
  }
}