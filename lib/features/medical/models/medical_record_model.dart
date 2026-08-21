import 'prescription_model.dart';

class _AnimalInfo {
  const _AnimalInfo({
    required this.animalId,
    required this.officialTagId,
    required this.type,
    required this.breed,
    required this.gender,
    this.birthDate,
  });

  final int animalId;
  final String officialTagId;
  final String type;
  final String breed;
  final String gender;
  final DateTime? birthDate;

  factory _AnimalInfo.fromJson(Map<String, dynamic> j) => _AnimalInfo(
        animalId:      (j['animalId'] as num?)?.toInt() ?? 0,
        officialTagId: j['officialTagId'] as String? ?? '',
        type:          j['type']          as String? ?? '',
        breed:         j['breed']         as String? ?? '',
        gender:        j['gender']        as String? ?? '',
        birthDate:     j['birthDate'] != null
            ? DateTime.tryParse(j['birthDate'] as String)
            : null,
      );
}

class _VetInfo {
  const _VetInfo({required this.vetId, required this.fullName});

  final int vetId;
  final String fullName;

  factory _VetInfo.fromJson(Map<String, dynamic> j) => _VetInfo(
        vetId:    (j['vetId'] as num?)?.toInt() ?? 0,
        fullName: j['fullName'] as String? ?? '',
      );
}

class MedicalRecordModel {
  const MedicalRecordModel({
    required this.recordId,
    required this.visitType,
    this.symptoms,
    this.diagnosis,
    this.notes,
    required this.createdAt,
    required this.animalId,
    required this.animalTagId,
    required this.animalType,
    required this.vetId,
    required this.vetName,
    required this.prescriptions,
  });

  final int recordId;
  final String visitType;
  final String? symptoms;
  final String? diagnosis;
  final String? notes;
  final DateTime createdAt;
  final int animalId;
  final String animalTagId;
  final String animalType;
  final int vetId;
  final String vetName;
  final List<PrescriptionModel> prescriptions;

  factory MedicalRecordModel.fromJson(Map<String, dynamic> j) {
    final animal = j['animal'] is Map
        ? _AnimalInfo.fromJson(Map<String, dynamic>.from(j['animal'] as Map))
        : null;
    final vet = j['veterinarian'] is Map
        ? _VetInfo.fromJson(Map<String, dynamic>.from(j['veterinarian'] as Map))
        : null;

    final prescriptions = (j['prescriptions'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PrescriptionModel.fromJson)
        .toList();

    return MedicalRecordModel(
      recordId:    (j['recordId'] as num?)?.toInt() ?? 0,
      visitType:   j['visitType']  as String? ?? '',
      symptoms:    j['symptoms']   as String?,
      diagnosis:   j['diagnosis']  as String?,
      notes:       j['notes']      as String?,
      createdAt:   DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      animalId:    animal?.animalId    ?? 0,
      animalTagId: animal?.officialTagId ?? '',
      animalType:  animal?.type         ?? '',
      vetId:       vet?.vetId    ?? 0,
      vetName:     vet?.fullName ?? '',
      prescriptions: prescriptions,
    );
  }
}
