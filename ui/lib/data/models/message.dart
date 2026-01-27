class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final String? modelUsed;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.modelUsed,
  });

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      role: json['role'],
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['created_at']),
      modelUsed: json['model_id'] as String? ?? 'gemini-2.5-flash', 
    );
  }
}