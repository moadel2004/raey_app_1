class PrescriptionModel {
  const PrescriptionModel({
    this.prescriptionId,
    required this.medicationName,
    required this.dosage,
    required this.duration,
  });

  final int? prescriptionId; // present in response, absent in create payload
  final String medicationName;
  final String dosage;
  final String duration;

  factory PrescriptionModel.fromJson(Map<String, dynamic> j) => PrescriptionModel(
        prescriptionId: (j['prescriptionId'] as num?)?.toInt(),
        medicationName: j['medicationName'] as String? ?? '',
        dosage:         j['dosage']         as String? ?? '',
        duration:       j['duration']       as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'medicationName': medicationName,
        'dosage':         dosage,
        'duration':       duration,
      };
}
