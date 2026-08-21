class ConsultationModel {
  const ConsultationModel({
    required this.consultationId,
    required this.farmerId,
    required this.farmerName,
    required this.vetId,
    required this.vetName,
    required this.subject,
    this.description,
    required this.status,
    required this.createdAt,
  });

  final int consultationId;
  final int farmerId;
  final String farmerName;
  final int vetId;
  final String vetName;
  final String subject;
  final String? description;
  final String status; // Pending / Accepted / Rejected / Closed
  final DateTime createdAt;

  // ── Status helpers ────────────────────────────────────────────────────────

  String get statusAr {
    switch (status) {
      case 'Pending':  return 'قيد الانتظار';
      case 'Accepted': return 'مقبولة';
      case 'Rejected': return 'مرفوضة';
      case 'Closed':   return 'مقفولة';
      default:         return status;
    }
  }

  bool get isPending  => status == 'Pending';
  bool get isAccepted => status == 'Accepted';
  bool get isRejected => status == 'Rejected';
  bool get isClosed   => status == 'Closed';
  bool get isActive   => isPending || isAccepted;

  // ── fromJson ─────────────────────────────────────────────────────────────

  factory ConsultationModel.fromJson(Map<String, dynamic> j) =>
      ConsultationModel(
        consultationId: (j['consultationId'] as num?)?.toInt() ?? 0,
        farmerId:       (j['farmerId']       as num?)?.toInt() ?? 0,
        farmerName:     j['farmerName']  as String? ?? '',
        vetId:          (j['vetId']          as num?)?.toInt() ?? 0,
        vetName:        j['vetName']     as String? ?? '',
        subject:        j['subject']     as String? ?? '',
        description:    j['description'] as String?,
        status:         j['status']      as String? ?? 'Pending',
        createdAt:      DateTime.tryParse(j['createdAt'] as String? ?? '') ??
                        DateTime.now(),
      );
}
