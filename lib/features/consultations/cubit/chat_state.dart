import 'package:equatable/equatable.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.session,
    required this.messages,
    this.isSending = false,
  });

  final ChatSessionModel session;
  final List<MessageModel> messages;
  final bool isSending;

  ChatLoaded copyWith({
    List<MessageModel>? messages,
    bool? isSending,
  }) =>
      ChatLoaded(
        session:   session,
        messages:  messages  ?? this.messages,
        isSending: isSending ?? this.isSending,
      );

  @override
  List<Object?> get props => [session, messages, isSending];
}

class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ChatSendError extends ChatState {
  const ChatSendError(this.message, this.loaded);
  final String message;
  final ChatLoaded loaded;
  @override
  List<Object?> get props => [message, loaded];
}
