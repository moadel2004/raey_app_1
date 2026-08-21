import 'review_model.dart';

class VetReviewsModel {
  const VetReviewsModel({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  factory VetReviewsModel.fromJson(Map<String, dynamic> j) {
    // ⚠️ Pagination is nested: data['reviews']['items'] — not data['items']
    final reviewsMap = j['reviews'] is Map
        ? j['reviews'] as Map<String, dynamic>
        : <String, dynamic>{};
    final items = reviewsMap['items'] is List
        ? reviewsMap['items'] as List
        : <dynamic>[];

    return VetReviewsModel(
      averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews:  (j['totalReviews']  as num?)?.toInt()    ?? 0,
      reviews:       items
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList(),
    );
  }
}
