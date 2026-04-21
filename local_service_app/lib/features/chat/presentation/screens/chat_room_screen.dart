import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_service_app/core/widgets/app_widgets.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'package:local_service_app/features/auth/presentation/logic/auth_providers.dart';
import 'package:local_service_app/features/chat/presentation/logic/chat_providers.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showSend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomNotifierProvider(widget.roomId).notifier).connect();
    });
    _messageController.addListener(() {
      setState(() => _showSend = _messageController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    ref
        .read(chatRoomNotifierProvider(widget.roomId).notifier)
        .sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: AppDurations.normal,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomNotifierProvider(widget.roomId));
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        title: Row(
          children: [
            const AppAvatar(name: 'Rahul Kumar', size: 36),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rahul Kumar',
                    style: AppTypography.labelLarge(
                        color: (Theme.of(context).brightness == Brightness.dark)
                            ? Colors.white
                            : AppColors.grey900)),
                Text(
                  state.isConnected ? '● Online' : '○ Offline',
                  style: AppTypography.caption(
                    color: state.isConnected
                        ? AppColors.success
                        : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Connection banner
          if (!state.isConnected && !state.isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              color: AppColors.warning,
              child: Text(
                '⚠ Reconnecting...',
                textAlign: TextAlign.center,
                style: AppTypography.labelSmall(color: Colors.white),
              ),
            ),

          // Messages
          Expanded(
            child: Container(
              color: (Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.chatBackgroundDark
                  : AppColors.chatBackground,
              child: state.messages.isEmpty
                  ? Center(
                      child: Text('Say hello 👋',
                          style: AppTypography.bodyMedium(
                              color: AppColors.grey400)),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.md),
                      itemCount:
                          state.messages.length + (state.isTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (state.isTyping && i == state.messages.length) {
                          return _TypingIndicator();
                        }
                        final msg = state.messages[i];
                        final isMine = msg.senderId == currentUserId;
                        return _ChatBubble(message: msg, isMine: isMine);
                      },
                    ),
            ),
          ),

          // Input bar
          Container(
            decoration: BoxDecoration(
              color: (Theme.of(context).brightness == Brightness.dark)
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: (Theme.of(context).brightness == Brightness.dark)
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded,
                        color: AppColors.grey500),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: (Theme.of(context).brightness == Brightness.dark)
                            ? AppColors.darkSurface2
                            : AppColors.grey100,
                        borderRadius: AppRadius.r24,
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onChanged: (_) => ref
                            .read(chatRoomNotifierProvider(widget.roomId)
                                .notifier)
                            .sendTyping(),
                        style: AppTypography.chatMessage(
                          color:
                              (Theme.of(context).brightness == Brightness.dark)
                                  ? Colors.white
                                  : AppColors.grey900,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.bodyMedium(
                              color: AppColors.grey400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedContainer(
                    duration: AppDurations.normal,
                    child: _showSend
                        ? InkWell(
                            onTap: _sendMessage,
                            borderRadius: AppRadius.circle,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.md,
                              ),
                              child: const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.mic_rounded,
                                color: AppColors.primary, size: 28),
                            onPressed: () {},
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isMine});
  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: isMine ? 60 : 0,
        right: isMine ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            AppAvatar(name: message.senderName, size: 28),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.chatBubblePaddingH,
                    vertical: AppSpacing.chatBubblePaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? AppColors.chatBubbleSent
                        : (Theme.of(context).brightness == Brightness.dark)
                            ? AppColors.chatBubbleReceivedDark
                            : AppColors.chatBubbleReceived,
                    borderRadius: isMine
                        ? AppRadius.chatBubbleSent
                        : AppRadius.chatBubbleReceived,
                    boxShadow: AppShadows.sm,
                  ),
                  child: Text(
                    message.content,
                    style: AppTypography.chatMessage(
                      color: isMine
                          ? Colors.white
                          : (Theme.of(context).brightness == Brightness.dark)
                              ? Colors.white
                              : AppColors.grey900,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('h:mm a').format(message.createdAt),
                  style: AppTypography.caption(color: AppColors.grey400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          const AppAvatar(name: 'P', size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.grey200,
              borderRadius: AppRadius.chatBubbleReceived,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                SizedBox(width: 4),
                _Dot(delay: 150),
                SizedBox(width: 4),
                _Dot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.grey500,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
