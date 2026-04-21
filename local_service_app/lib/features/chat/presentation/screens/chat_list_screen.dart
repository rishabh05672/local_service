import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:badges/badges.dart' as badges;
import 'package:local_service_app/core/widgets/app_widgets.dart';
import 'package:local_service_app/core/widgets/state_widgets.dart';
import 'package:local_service_app/core/widgets/shimmer_widgets.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'package:local_service_app/features/chat/presentation/logic/chat_providers.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatListNotifierProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: state.isLoading
          ? const ShimmerList(itemCount: 6)
          : state.conversations.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No conversations yet',
                  subtitle: 'Book a service to start chatting with providers.',
                )
              : ListView.separated(
                  itemCount: state.conversations.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder,
                    indent: 80,
                  ),
                  itemBuilder: (_, i) {
                    final conv = state.conversations[i];
                    return _ConversationTile(
                      conversation: conv,
                      onTap: () =>
                          context.push('/chats/${conv.roomId}'),
                    );
                  },
                ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});
  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingH, vertical: AppSpacing.md),
        child: Row(
          children: [
            badges.Badge(
              showBadge: conversation.isOnline,
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppColors.success,
                padding: EdgeInsets.all(4),
              ),
              position: badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
              child: AppAvatar(
                name: conversation.participantName,
                imageUrl: conversation.participantAvatar,
                size: AppSpacing.avatarLg,
                isOnline: conversation.isOnline,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          style: AppTypography.labelLarge(
                            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeago.format(conversation.lastMessageAt),
                        style: AppTypography.caption(
                          color: hasUnread
                              ? AppColors.primary
                              : AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: AppTypography.bodySmall(
                            color: hasUnread
                                ? ((Theme.of(context).brightness == Brightness.dark) ? Colors.white70 : AppColors.grey700)
                                : AppColors.grey400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.chip,
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: AppTypography.labelSmall(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
