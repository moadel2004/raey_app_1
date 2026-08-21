class MessageModel {
  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  final int messageId;
  final int senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final DateTime createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
        messageId:  (j['messageId']  as num?)?.toInt() ?? 0,
        senderId:   (j['senderId']   as num?)?.toInt() ?? 0,
        senderName: j['senderName']  as String? ?? '',
        senderRole: j['senderRole']  as String? ?? '',
        content:    j['content']     as String? ?? '',
        createdAt:  DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
