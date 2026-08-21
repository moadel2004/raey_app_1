import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/chat_cubit.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.consultationId,
    required this.currentUserId,
    required this.otherPartyName,
    required this.subject,
  });

  final int consultationId;
  final int currentUserId;
  final String otherPartyName;
  final String subject;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl   = TextEditingController();
  final _scrollCtrl  = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().openChat(widget.consultationId);
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      context.read<ChatCubit>().refreshMessages();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    context.read<ChatCubit>().sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherPartyName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(widget.subject,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            _scrollToBottom();
          }
          if (state is ChatSendError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ));
          }
        },
        builder: (context, state) {
          // ── Full-screen loading ─────────────────────────────────────────
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // ── Full-screen error ───────────────────────────────────────────
          if (state is ChatError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 15)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<ChatCubit>()
                          .openChat(widget.consultationId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('حاول تاني'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Resolve loaded state (ChatLoaded or ChatSendError carries loaded)
          final loaded = state is ChatLoaded
              ? state
              : state is ChatSendError
                  ? state.loaded
                  : null;

          if (loaded == null) return const SizedBox.shrink();

          final messages   = loaded.messages;
          final isSending  = loaded.isSending;

          return Column(
            children: [
              // ── Messages list ──────────────────────────────────────────
              Expanded(
                child: messages.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => _MessageBubble(
                          message: messages[i],
                          isMe: messages[i].senderId == widget.currentUserId,
                        ),
                      ),
              ),

              // ── Input bar ──────────────────────────────────────────────
              _buildInputBar(isSending),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        AppStrings.chatEmpty,
        style: TextStyle(
          color: AppColors.textMedium,
          fontFamily: 'Cairo',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isSending) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: AppStrings.chatInputHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            isSending
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    tooltip: AppStrings.chatSend,
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final d = message.createdAt.toLocal();
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primarySurface,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textDark,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white70
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 6),
        ],
      ),
    );
  }
}
