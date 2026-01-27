import 'message.dart';

class ChatState {
  final String? chatId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? lastUsedModel; 

  ChatState({
    this.chatId,
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.lastUsedModel,
  });

  ChatState copyWith({
    String? chatId,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? lastUsedModel,
  }) {
    return ChatState(
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUsedModel: lastUsedModel ?? this.lastUsedModel,
    );
  }
}