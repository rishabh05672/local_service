import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:local_service_app/core/config/app_config.dart';
import 'package:local_service_app/core/security/secure_storage_service.dart';
import 'package:local_service_app/core/services/providers.dart';
import 'package:local_service_app/core/constants/app_constants.dart';
import 'package:local_service_app/core/utils/app_logger.dart';

// ─── Chat Message Entity ───────────────────────────────────────────────────────

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.senderAvatar,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        roomId: json['roomId'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String? ?? '',
        senderAvatar: json['senderAvatar'] as String?,
        content: json['content'] as String,
        type: json['type'] as String? ?? AppConstants.msgTypeText,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };
}

// ─── Chat Conversation Entity ──────────────────────────────────────────────────

class ChatConversation {
  const ChatConversation({
    required this.roomId,
    required this.participantName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.participantAvatar,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String roomId;
  final String participantName;
  final String? participantAvatar;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool isOnline;
}

// ─── Chat State ───────────────────────────────────────────────────────────────

class ChatRoomState {
  const ChatRoomState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.isConnected = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final bool isConnected;
  final String? errorMessage;

  ChatRoomState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    bool? isConnected,
    String? errorMessage,
  }) =>
      ChatRoomState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isTyping: isTyping ?? this.isTyping,
        isConnected: isConnected ?? this.isConnected,
        errorMessage: errorMessage,
      );
}

// ─── Chat Notifier ────────────────────────────────────────────────────────────

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  ChatRoomNotifier({
    required this.roomId,
    required this.tokenManager,
    required this.currentUserId,
  }) : super(const ChatRoomState());

  final String roomId;
  final TokenManager tokenManager;
  final String currentUserId;
  io.Socket? _socket;
  Timer? _typingTimer;

  Future<void> connect() async {
    state = state.copyWith(isLoading: true);
    final token = await tokenManager.getAccessToken();
    if (token == null) return;

    _socket = io.io(AppConfig.wsUrl, {
      'transports': ['websocket'],
      'auth': {'token': token},
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      AppLogger.info('Chat socket connected for room $roomId');
      _socket!.emit(AppConstants.wsEventJoinRoom, {'roomId': roomId});
      state = state.copyWith(isConnected: true, isLoading: false);
    });

    _socket!.onDisconnect((_) {
      state = state.copyWith(isConnected: false);
    });

    _socket!.on(AppConstants.wsEventMessage, (data) {
      final msg = ChatMessage.fromJson(data as Map<String, dynamic>);
      state = state.copyWith(messages: [...state.messages, msg]);
      // Send read receipt
      _socket!.emit(AppConstants.wsEventRead, {
        'roomId': roomId,
        'messageId': msg.id,
      });
    });

    _socket!.on(AppConstants.wsEventTyping, (data) {
      final senderId = (data as Map<String, dynamic>)['senderId'];
      if (senderId != currentUserId) {
        state = state.copyWith(isTyping: true);
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) state = state.copyWith(isTyping: false);
        });
      }
    });

    _socket!.onConnectError((e) {
      AppLogger.error('Socket connect error', error: e);
      state = state.copyWith(isLoading: false, errorMessage: 'Connection failed');
    });
  }

  void sendMessage(String content, {String type = AppConstants.msgTypeText}) {
    if (_socket == null || !state.isConnected) return;
    _socket!.emit(AppConstants.wsEventMessage, {
      'roomId': roomId,
      'content': content,
      'type': type,
    });
  }

  void sendTyping() {
    _socket?.emit(AppConstants.wsEventTyping, {'roomId': roomId});
  }

  void disconnect() {
    _socket?.emit(AppConstants.wsEventLeaveRoom, {'roomId': roomId});
    _socket?.disconnect();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

// ─── Chat Conversations State ─────────────────────────────────────────────────

class ChatListState {
  const ChatListState({
    this.conversations = const [],
    this.isLoading = false,
  });
  final List<ChatConversation> conversations;
  final bool isLoading;
}

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier({required this.apiClient}) : super(const ChatListState());
  final dynamic apiClient;

  Future<void> loadConversations() async {
    state = const ChatListState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    // Replace with real API call
    state = ChatListState(
      isLoading: false,
      conversations: [
        ChatConversation(
          roomId: 'room1',
          participantName: 'Rahul Kumar',
          lastMessage: 'I will arrive in 15 minutes.',
          lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatConversation(
          roomId: 'room2',
          participantName: 'Priya Sharma',
          lastMessage: 'Service completed. Thank you!',
          lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
          unreadCount: 0,
          isOnline: false,
        ),
      ],
    );
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final chatListNotifierProvider =
    StateNotifierProvider<ChatListNotifier, ChatListState>((ref) {
  return ChatListNotifier(apiClient: ref.watch(apiClientProvider));
});

final chatRoomNotifierProvider = StateNotifierProvider.family<
    ChatRoomNotifier, ChatRoomState, String>((ref, roomId) {
  return ChatRoomNotifier(
    roomId: roomId,
    tokenManager: ref.watch(tokenManagerProvider),
    currentUserId: '',
  );
});
