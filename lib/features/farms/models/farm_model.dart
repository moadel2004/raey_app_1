class FarmModel {
  const FarmModel({
    required this.id,
    required this.name,
    required this.location,
    required this.regionId,
    required this.regionName,
    required this.ownerId,
    required this.ownerName,
    required this.animalCount,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String location;
  final int regionId;
  final String regionName;
  final int ownerId;
  final String ownerName;
  final int animalCount;
  final DateTime createdAt;

  factory FarmModel.fromJson(Map<String, dynamic> j) => FarmModel(
        id:          (j['id']          as num?)?.toInt() ?? 0,
        name:        j['name']         as String? ?? '',
        location:    j['location']     as String? ?? '',
        regionId:    (j['regionId']    as num?)?.toInt() ?? 0,
        regionName:  j['regionName']   as String? ?? '',
        ownerId:     (j['ownerId']     as num?)?.toInt() ?? 0,
        ownerName:   j['ownerName']    as String? ?? '',
        animalCount: (j['animalCount'] as num?)?.toInt() ?? 0,
        createdAt:   DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toCreateJson() => {
        'name':     name,
        'location': location,
        'regionId': regionId,
      };
}
