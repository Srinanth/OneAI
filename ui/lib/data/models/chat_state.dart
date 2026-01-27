import 'message.dart';

class ChatState {
  final String? chatId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? lastUsedModel; 
  final int currentUsage;
  final int maxLimit;

  ChatState({
    this.chatId,
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.lastUsedModel,
    this.currentUsage = 0,
    this.maxLimit = 100000,
  });

  ChatState copyWith({
    String? chatId,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? lastUsedModel,
    int? currentUsage,
    int? maxLimit,
  }) {
    return ChatState(
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUsedModel: lastUsedModel ?? this.lastUsedModel,
      currentUsage: currentUsage ?? this.currentUsage,
      maxLimit: maxLimit ?? this.maxLimit,
    );
  }
}