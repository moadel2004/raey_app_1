class ChatSessionModel {
  const ChatSessionModel({
    required this.sessionId,
    required this.consultationId,
  });

  final int sessionId;
  final int consultationId;

  factory ChatSessionModel.fromJson(Map<String, dynamic> j) => ChatSessionModel(
        sessionId:      (j['sessionId']      as num?)?.toInt() ?? 0,
        consultationId: (j['consultationId'] as num?)?.toInt() ?? 0,
      );
}
