class VetSummaryModel {
  const VetSummaryModel({
    required this.vetId,
    required this.fullName,
    this.bio,
    required this.experienceYears,
    required this.consultationFee,
    required this.averageRating,
    required this.totalReviews,
  });

  final int vetId;
  final String fullName;
  final String? bio;
  final int experienceYears;
  final double consultationFee;
  final double averageRating;
  final int totalReviews;

  factory VetSummaryModel.fromJson(Map<String, dynamic> j) => VetSummaryModel(
        vetId:           (j['vetId'] as num?)?.toInt() ?? 0,
        fullName:        j['fullName'] as String? ?? '',
        bio:             j['bio'] as String?,
        experienceYears: (j['experienceYears'] as num?)?.toInt() ?? 0,
        consultationFee: (j['consultationFee'] as num?)?.toDouble() ?? 0.0,
        averageRating:   (j['averageRating'] as num?)?.toDouble() ?? 0.0,
        totalReviews:    (j['totalReviews'] as num?)?.toInt() ?? 0,
      );
}
