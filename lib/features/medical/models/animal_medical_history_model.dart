import 'prescription_model.dart';

// Separate from DashboardModel's MedicalRecordSummaryModel — different shape
class AnimalRecordSummary {
  const AnimalRecordSummary({
    required this.recordId,
    required this.visitType,
    this.symptoms,
    this.diagnosis,
    required this.createdAt,
    required this.veterinarianName,
    required this.prescriptions,
  });

  final int recordId;
  final String visitType;
  final String? symptoms;
  final String? diagnosis;
  final DateTime createdAt;
  final String veterinarianName;
  final List<PrescriptionModel> prescriptions;

  factory AnimalRecordSummary.fromJson(Map<String, dynamic> j) =>
      AnimalRecordSummary(
        recordId:         (j['recordId'] as num?)?.toInt() ?? 0,
        visitType:        j['visitType']  as String? ?? '',
        symptoms:         j['symptoms']   as String?,
        diagnosis:        j['diagnosis']  as String?,
        createdAt:        DateTime.tryParse(j['createdAt'] as String? ?? '') ??
                          DateTime.now(),
        veterinarianName: j['veterinarianName'] as String? ?? '',
        prescriptions:    (j['prescriptions'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(PrescriptionModel.fromJson)
            .toList(),
      );
}

class AnimalMedicalHistoryModel {
  const AnimalMedicalHistoryModel({
    required this.animalId,
    required this.officialTagId,
    required this.type,
    required this.breed,
    required this.records,
  });

  final int animalId;
  final String officialTagId;
  final String type;
  final String breed;
  final List<AnimalRecordSummary> records;

  factory AnimalMedicalHistoryModel.fromJson(Map<String, dynamic> j) =>
      AnimalMedicalHistoryModel(
        animalId:      (j['animalId'] as num?)?.toInt() ?? 0,
        officialTagId: j['officialTagId'] as String? ?? '',
        type:          j['type']          as String? ?? '',
        breed:         j['breed']         as String? ?? '',
        records:       (j['medicalRecords'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(AnimalRecordSummary.fromJson)
            .toList(),
      );
}
