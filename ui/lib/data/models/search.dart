class SearchResult {
  final String messageId;
  final String chatId;
  final String chatTitle;
  final String content;
  final DateTime createdAt;
  final double rank;

  SearchResult({
    required this.messageId,
    required this.chatId,
    required this.chatTitle,
    required this.content,
    required this.createdAt,
    required this.rank,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      messageId: json['message_id'],
      chatId: json['chat_id'],
      chatTitle: json['chat_title'] ?? 'Untitled Chat',
      content: json['content'],                     // add truncation if this returns so much  unnecessary stuff
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      rank: (json['rank'] as num).toDouble(),
    );
  }
}