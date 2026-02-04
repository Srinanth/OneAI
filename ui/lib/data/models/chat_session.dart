class ChatSession {
  final String id;
  final String title;
  final String modelId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? groupId;

  ChatSession({
    required this.id,
    required this.title,
    required this.modelId,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
  });
  ChatSession copyWith({String? title, String? modelId}) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      modelId: modelId ?? this.modelId,
      groupId: groupId,
      createdAt: createdAt,
      updatedAt:updatedAt 
    );
  }
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
          id: json['id'],
          title: json['title'] ?? 'New Chat',
          modelId: json['model_id'],
          groupId: json['group_id'],
          createdAt: DateTime.parse(json['created_at']).toLocal(),
          updatedAt: json['updated_at'] != null 
              ? DateTime.parse(json['updated_at']).toLocal() 
              : DateTime.parse(json['created_at']).toLocal(),
        );
  }

}