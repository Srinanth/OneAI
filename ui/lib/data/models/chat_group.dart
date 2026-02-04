class ChatGroup {
  final String id;
  final String name;
  final DateTime updatedAt;

  ChatGroup({
    required this.id, 
    required this.name, 
    required this.updatedAt
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'],
      name: json['name'],
      updatedAt: DateTime.parse(json['updated_at'])
    );
  }
}