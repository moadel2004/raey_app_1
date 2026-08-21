class AnimalModel {
  const AnimalModel({
    required this.id,
    required this.officialTagId,
    required this.type,
    required this.breed,
    required this.gender,
    this.birthDate,
    required this.farmId,
    required this.farmName,
    required this.medicalRecordCount,
    required this.createdAt,
  });

  final int id;
  final String officialTagId;
  final String type;
  final String breed;
  final String gender;
  final DateTime? birthDate;
  final int farmId;
  final String farmName;
  final int medicalRecordCount;
  final DateTime createdAt;

  /// العرض بالعربي
  String get genderAr {
    switch (gender) {
      case 'Male':
        return 'ذكر';
      case 'Female':
        return 'أنثى';
      default:
        return 'غير محدد';
    }
  }

  Map<String, dynamic> toCreateJson() => {
        'officialTagId': officialTagId,
        'type': type,
        'breed': breed,
        'gender': gender,
        if (birthDate != null)
          'birthDate': birthDate!.toIso8601String().substring(0, 10),
        'farmId': farmId,
      };

  Map<String, dynamic> toUpdateJson() => {
        'type': type,
        'breed': breed,
        'gender': gender,
        if (birthDate != null)
          'birthDate': birthDate!.toIso8601String().substring(0, 10),
      };

  factory AnimalModel.fromJson(Map<String, dynamic> j) {
    // gender دفاعي: قيم غير معروفة (زي "أنثى" القديمة) تتحوّل لـ Unknown
    final rawGender = j['gender'] as String? ?? '';
    final gender = const {'Male', 'Female', 'Unknown'}.contains(rawGender)
        ? rawGender
        : 'Unknown';

    return AnimalModel(
      id: (j['id'] as num?)?.toInt() ?? 0,
      officialTagId: j['officialTagId'] as String? ?? '',
      type: j['type'] as String? ?? '',
      breed: j['breed'] as String? ?? '',
      gender: gender,
      birthDate: j['birthDate'] == null
          ? null
          : DateTime.tryParse(j['birthDate'] as String),
      farmId: (j['farmId'] as num?)?.toInt() ?? 0,
      farmName: j['farmName'] as String? ?? '',
      medicalRecordCount: (j['medicalRecordCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
