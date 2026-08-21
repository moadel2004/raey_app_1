class _ReviewVet {
  const _ReviewVet({required this.vetId, required this.fullName});
  final int vetId;
  final String fullName;

  factory _ReviewVet.fromJson(Map<String, dynamic> j) => _ReviewVet(
        vetId:    (j['vetId'] as num?)?.toInt() ?? 0,
        fullName: j['fullName'] as String? ?? '',
      );
}

class _ReviewUser {
  const _ReviewUser({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
  });
  final int userId;
  final String fullName;
  final String phoneNumber;

  factory _ReviewUser.fromJson(Map<String, dynamic> j) => _ReviewUser(
        userId:      (j['userId'] as num?)?.toInt() ?? 0,
        fullName:    j['fullName']    as String? ?? '',
        phoneNumber: j['phoneNumber'] as String? ?? '',
      );
}

class ReviewModel {
  const ReviewModel({
    required this.reviewId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.vetId,
    required this.vetName,
    required this.userId,
    required this.userFullName,
    required this.userPhone,
  });

  final int reviewId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final int vetId;
  final String vetName;
  final int userId;
  final String userFullName;
  final String userPhone;

  factory ReviewModel.fromJson(Map<String, dynamic> j) {
    final vet  = j['veterinarian'] is Map
        ? _ReviewVet.fromJson(Map<String, dynamic>.from(j['veterinarian'] as Map))
        : null;
    final user = j['user'] is Map
        ? _ReviewUser.fromJson(Map<String, dynamic>.from(j['user'] as Map))
        : null;

    return ReviewModel(
      reviewId:     (j['reviewId'] as num?)?.toInt() ?? 0,
      rating:       (j['rating']   as num?)?.toInt() ?? 0,
      comment:      j['comment'] as String?,
      createdAt:    DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      vetId:        vet?.vetId    ?? 0,
      vetName:      vet?.fullName ?? '',
      userId:       user?.userId      ?? 0,
      userFullName: user?.fullName    ?? '',
      userPhone:    user?.phoneNumber ?? '',
    );
  }
}
