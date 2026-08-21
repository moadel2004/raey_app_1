class RecordChangeModel {
  const RecordChangeModel({
    required this.id,
    this.previousDiagnosis,
    this.previousTreatment,
    this.previousNotes,
    required this.modifiedAt,
    required this.modifiedBy,
  });

  final int id;
  final String? previousDiagnosis;
  final String? previousTreatment;
  final String? previousNotes;
  final DateTime modifiedAt;
  final String modifiedBy;

  factory RecordChangeModel.fromJson(Map<String, dynamic> j) =>
      RecordChangeModel(
        id:                  (j['id'] as num?)?.toInt() ?? 0,
        previousDiagnosis:   j['previousDiagnosis'] as String?,
        previousTreatment:   j['previousTreatment'] as String?,
        previousNotes:       j['previousNotes']     as String?,
        modifiedAt:          DateTime.tryParse(j['modifiedAt'] as String? ?? '') ??
                             DateTime.now(),
        modifiedBy:          j['modifiedBy'] as String? ?? '',
      );
}
