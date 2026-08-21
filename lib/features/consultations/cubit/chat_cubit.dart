import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../repository/chat_repository.dart';
import 'chat_state.dart';

export 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatInitial());

  final ChatRepository _repository;

  // ── Open chat ─────────────────────────────────────────────────────────────

  Future<void> openChat(int consultationId) async {
    emit(const ChatLoading());
    try {
      final session  = await _repository.getSession(consultationId);
      if (isClosed) return;
      final messages = await _repository.getMessages(session.sessionId);
      if (isClosed) return;
      emit(ChatLoaded(session: session, messages: messages));
    } on ApiException catch (e) {
      if (isClosed) return;
      emit(ChatError(e.message));
    } catch (_) {
      if (isClosed) return;
      emit(const ChatError('تعذّر فتح الشات، حاول تاني.'));
    }
  }

  // ── Silent refresh (polling) ──────────────────────────────────────────────

  Future<void> refreshMessages() async {
    final current = state;
    if (current is! ChatLoaded) return;
    try {
      final messages = await _repository.getMessages(current.session.sessionId);
      if (isClosed) return;
      if (state is! ChatLoaded) return;
      emit((state as ChatLoaded).copyWith(messages: messages));
    } catch (_) {
      // Silent — polling errors don't show UI error
    }
  }

  // ── Send ──────────────────────────────────────────────────────────────────

  bool _isSending = false;

  Future<void> sendMessage(String content) async {
    final current = state;
    if (current is! ChatLoaded) return;
    if (_isSending) return;
    if (content.trim().isEmpty) return;

    _isSending = true;
    emit(current.copyWith(isSending: true));
    try {
      await _repository.sendMessage(
        chatSessionId: current.session.sessionId,
        content: content.trim(),
      );
      if (isClosed) return;
      final messages = await _repository.getMessages(current.session.sessionId);
      if (isClosed) return;
      if (state is! ChatLoaded) return;
      emit((state as ChatLoaded).copyWith(messages: messages, isSending: false));
    } on ApiException catch (e) {
      if (isClosed) return;
      if (state is! ChatLoaded) return;
      emit(ChatSendError(e.message, (state as ChatLoaded).copyWith(isSending: false)));
    } catch (_) {
      if (isClosed) return;
      if (state is! ChatLoaded) return;
      emit(ChatSendError('فشل إرسال الرسالة', (state as ChatLoaded).copyWith(isSending: false)));
    } finally {
      _isSending = false;
    }
  }
}
