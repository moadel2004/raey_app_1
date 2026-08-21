class DashboardModel {
  const DashboardModel({
    required this.totalBookings,
    required this.upcomingBookings,
    required this.completedBookings,
    required this.averageRating,
    required this.totalReviews,
  });

  final int totalBookings;
  final int upcomingBookings;
  final int completedBookings;
  final double averageRating;
  final int totalReviews;

  factory DashboardModel.fromJson(Map<String, dynamic> j) => DashboardModel(
        totalBookings:     (j['totalBookings']     as num?)?.toInt()    ?? 0,
        upcomingBookings:  (j['upcomingBookings']  as num?)?.toInt()    ?? 0,
        completedBookings: (j['completedBookings'] as num?)?.toInt()    ?? 0,
        averageRating:     (j['averageRating']     as num?)?.toDouble() ?? 0.0,
        totalReviews:      (j['totalReviews']      as num?)?.toInt()    ?? 0,
      );
}
