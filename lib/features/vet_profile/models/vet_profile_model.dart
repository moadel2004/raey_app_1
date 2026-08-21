import '../../farms/models/region_model.dart';

class VetProfileModel {
  const VetProfileModel({
    required this.vetId,
    required this.fullName,
    required this.phoneNumber,
    this.bio,
    required this.experienceYears,
    required this.consultationFee,
    this.profileImageUrl,
    required this.averageRating,
    required this.totalReviews,
    required this.regions,
  });

  final int vetId;
  final String fullName;
  final String phoneNumber;
  final String? bio;
  final int experienceYears;
  final double consultationFee;
  final String? profileImageUrl;
  final double averageRating;
  final int totalReviews;
  final List<RegionModel> regions;

  Map<String, dynamic> toUpdateJson() => {
        'bio': bio,
        'experienceYears': experienceYears,
        'consultationFee': consultationFee,
        'profileImageUrl': profileImageUrl,
      };

  VetProfileModel copyWith({
    String? bio,
    int? experienceYears,
    double? consultationFee,
    String? profileImageUrl,
    List<RegionModel>? regions,
    double? averageRating,
    int? totalReviews,
  }) =>
      VetProfileModel(
        vetId: vetId,
        fullName: fullName,
        phoneNumber: phoneNumber,
        bio: bio ?? this.bio,
        experienceYears: experienceYears ?? this.experienceYears,
        consultationFee: consultationFee ?? this.consultationFee,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        averageRating: averageRating ?? this.averageRating,
        totalReviews: totalReviews ?? this.totalReviews,
        regions: regions ?? this.regions,
      );

  factory VetProfileModel.fromJson(Map<String, dynamic> j) {
    final rawRegions = j['regions'];
    final regions = rawRegions is List
        ? rawRegions
            .whereType<Map<String, dynamic>>()
            .map(RegionModel.fromJson)
            .toList()
        : <RegionModel>[];

    return VetProfileModel(
      vetId: (j['vetId'] as num?)?.toInt() ?? 0,
      fullName: j['fullName'] as String? ?? '',
      phoneNumber: j['phoneNumber'] as String? ?? '',
      bio: j['bio'] as String?,
      experienceYears: (j['experienceYears'] as num?)?.toInt() ?? 0,
      consultationFee: (j['consultationFee'] as num?)?.toDouble() ?? 0,
      profileImageUrl: j['profileImageUrl'] as String?,
      averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
      regions: regions,
    );
  }
}
