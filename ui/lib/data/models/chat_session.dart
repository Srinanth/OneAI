// Represents a conversation in the history list. Contains 'id', 'modelId', and a mutable 'title' field first its auto-generated from the first message's context,
// but updatable by the user
class ChatSession {
  final String id;
  final String title;
  final String modelId;
  final DateTime lastUpdated;

  ChatSession({
    required this.id,
    required this.title,
    required this.modelId,
    required this.lastUpdated,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      title: (json['title'] == null || json['title'].toString().isEmpty) 
          ? 'New Chat' 
          : json['title'],
      modelId: json['model_id'] ?? 'gemini-2.5-flash',
      lastUpdated: json['created_at'] != null 
          ? DateTime.parse(json['created_at']).toLocal() 
          : DateTime.now(),
    );
  }
}