class RegionModel {
  const RegionModel({required this.regionId, required this.name});

  final int regionId;
  final String name;

  factory RegionModel.fromJson(Map<String, dynamic> j) => RegionModel(
        regionId: (j['regionId'] as num?)?.toInt() ?? 0,
        name:     j['name'] as String? ?? '',
      );
}
