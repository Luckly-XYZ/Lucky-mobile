import 'dart:convert';

import 'package:flutter_im/app/api/api_service.dart';
import 'package:flutter_im/app/api/event_bus_service.dart';
import 'package:flutter_im/app/models/friend.dart';
import 'package:flutter_im/constants/app_message.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../database/app_database.dart';
import '../models/chats.dart';
import '../models/message_receive.dart';
import '../routes/app_routes.dart';
import '../ui/widgets/video/video_call_snackbar.dart';

class ChatController extends GetxController {
  // 会话列表 - 用于显示所有聊天会话
  final RxList<Chats> chatList = <Chats>[].obs;

  // 消息列表 - 用于显示当前会话的所有消息
  final RxList<MessageReceiveDto> messageList = <MessageReceiveDto>[].obs;

  // 当前选中的会话
  final Rx<Chats?> currentChat = Rx<Chats?>(null);

  // 加载状态标志 - 用于显示加载动画
  final RxBool isLoading = false.obs;

  // 错误信息 - 用于显示错误提示
  final Rx<String?> errorMessage = Rx<String?>(null);

  // 数据库实例
  final db = GetIt.instance<AppDatabase>();
  final ApiService _apiService = Get.find<ApiService>();

  // 当前用户ID
  var userId = ''.obs;

  // 分页相关属性
  final int pageSize = 20; // 每页加载的消息数量
  final RxBool isLoadingMore = false.obs; // 是否正在加载更多
  final RxBool hasMoreMessages = true.obs; // 是否还有更多消息
  int currentPage = 0; // 当前页码

  @override
  void onInit() {
    super.onInit();
    // 在初始化时自动加载聊天列表
    // _initializeChats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 创建或更新聊天会话
  /// @param dto 消息数据传输对象
  /// @param isMe 是否是自己发送的消息
  handleCreateOrUpdateChat(MessageReceiveDto dto, bool isMe) async {
    // id 必须为自己
    String? id = dto.fromId == userId.value ? dto.fromId : userId.value;
    // targetId 必须为会话的对象
    String? targetId = dto.targetId == userId.value ? dto.fromId : dto.targetId;

    // 查询数据库
    List<Chats>? chats =
        await db.chatsDao.getChatByOwnerIdAndToId(id!, targetId!);

    if (chats != null && chats.isNotEmpty) {
      await _updateExistingChat(chats.first, dto, isMe);
    } else {
      await _createNewChat(id!, targetId!, dto);
    }
  }

  /// 更新已存在的会话
  Future<void> _updateExistingChat(
      Chats chat, MessageReceiveDto dto, bool isMe) async {
    // 会话消息转换
    chat.message = Chats.toChatMessage(dto);
    // 如果不是当前会话用户则 消息未读数加1
    if (!isMe && currentChat.value?.toId != chat.toId) {
      chat.unread += 1;
    }
    // 会话时间更新
    chat.messageTime = dto.messageTime!;

    // 更新数据库会话信息
    await db.chatsDao.updateChat(chat);

    // 移除并添加会话
    chatList
        .removeWhere((c) => c.ownerId == chat.ownerId && c.toId == chat.toId);
    chatList.add(chat);

    // 增加消息
    await addMessage(dto, chat);

    _sortChatList();
  }

  /// 创建新会话
  Future<void> _createNewChat(
      String id, String targetId, MessageReceiveDto dto) async {
    // 从服务器拉取会话信息
    final res = await _apiService.getChat({'fromId': id, 'toId': targetId});
    if (res?['status'] == 200) {
      // 数据转换
      Chats chat = Chats.fromJson(res?['data'])
        ..message = Chats.toChatMessage(dto)
        ..messageTime = dto.messageTime!;

      // 更新数据库会话信息
      if (chat.ownerId == userId.value) {
        await db.chatsDao.insertChat(chat);
        chatList.add(chat);
      }
      // 增加消息
      await addMessage(dto, chat);

      _sortChatList();
    }
  }

  /// 添加消息到数据库和消息列表
  /// @param dto 消息数据传输对象
  /// @param chat 关联的会话对象
  Future<void> addMessage(MessageReceiveDto dto, Chats chat) async {
    if (dto.isSingleMessage) {
      await db.singleMessageDao
          .insertMessage(MessageReceiveDto.toSingleMessage(dto, userId.value));
    } else if (dto.isGroupMessage) {
      await db.groupMessageDao
          .insertMessage(MessageReceiveDto.toGroupMessage(dto, userId.value));
    }

    if (currentChat.value?.id == chat.id) {
      messageList.add(dto);
      messageList
          .sort((a, b) => (b.messageTime ?? 0).compareTo(a.messageTime ?? 0));
      messageList.refresh();
    }
  }

  /// 对会话列表按时间戳进行降序排序
  void _sortChatList() {
    chatList.sort((a, b) => b.messageTime.compareTo(a.messageTime));
    chatList.refresh();
  }

  /// 初始化会话列表
  /// @param ownerId 用户ID
  Future<void> initializeChats(String ownerId) async {
    try {
      if (userId.isEmpty || userId.value != ownerId) {
        userId.value = ownerId;
      }
      isLoading.value = true;
      chatList.clear(); // 清空现有列表，避免重复
      List<Chats>? chats = await db.chatsDao.getAllChats(ownerId);
      if (chats != null && chats.isNotEmpty) {
        chatList.addAll(chats);
        // 加载后也进行排序
        _sortChatList();
      }
    } catch (e) {
      errorMessage.value = '加载聊天列表失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 设置消息列表，支持分页加载
  /// @param chat 当前会话
  /// @param loadMore 是否加载更多
  handleSetMessageList(Chats chat, {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        messageList.clear();
        currentPage = 0;
        hasMoreMessages.value = true;
      }

      if (!hasMoreMessages.value) return;

      isLoadingMore.value = true;

      MessageType? messageType = MessageType.fromCode(chat.chatType);
      List<MessageReceiveDto> newMessages = [];

      if (messageType == MessageType.singleMessage) {
        final messages = await db.singleMessageDao.getMessagesByPage(
            chat.id, chat.ownerId, pageSize, currentPage * pageSize);

        if (messages != null) {
          newMessages = messages
              .map((message) => MessageReceiveDto.fromSingleMessage(message))
              .toList();
        }
      } else if (messageType == MessageType.groupMessage) {
        final messages = await db.groupMessageDao
            .getMessagesByPage(userId.value, pageSize, currentPage * pageSize);

        if (messages != null) {
          newMessages = messages
              .map((message) => MessageReceiveDto.fromGroupMessage(message))
              .toList();
        }
      }

      if (newMessages.length < pageSize) {
        hasMoreMessages.value = false;
      }

      messageList.addAll(newMessages);
      currentPage++;

      // 按时间排序消息列表
      //messageList.sort((a, b) => (b.messageTime ?? 0).compareTo(a.messageTime ?? 0));
      messageList.refresh();
    } catch (e) {
      errorMessage.value = '加载消息列表失败: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  // 获取消息列表
  Future<void> getMessageList() async {
    // messageList.clear(); // 清空现有列表，避免重复
    // List<MessageReceiveDto>? messages = await db.singleMessageDao.getAllMessages(userId.value);
    // if (messages != null && messages.isNotEmpty) {
    //   messageList.addAll(messages);
    // }
  }

  // Future<void> addChat(Chats chat) async {
  //   try {
  //     await db.chatsDao.insertChat(chat);
  //     chatList.add(chat);
  //     Get.log('添加聊天成功: ${chat.chatId}');
  //   } catch (e) {
  //     errorMessage.value = '添加聊天失败: $e';
  //   } finally {
  //     await _initializeChats();
  //   }
  // }

  // Future<void> updateChatById(Chats newChat) async {
  //   try {
  //     //await db.chatsDao.updateChat(chat);
  //     int index =
  //         chatList.indexWhere((chat) => chat.chatId == newChat.chatId);
  //     if (index != -1) {
  //       chatList[index] = newChat;
  //     }
  //     Get.log('更新聊天成功: ${newChat.chatId}');
  //   } catch (e) {
  //     errorMessage.value = '更新聊天失败: $e';
  //   } finally {
  //     await _initializeChats();
  //   }
  // }

  Future<void> removeChat(Chats chat) async {
    try {
      //await db.chatsDao.deleteChat(chat);
      chatList.remove(chat);
      Get.log('移除聊天成功: ${chat.chatId}');
    } catch (e) {
      errorMessage.value = '删除聊天失败: $e';
    } finally {
      await initializeChats(userId.value);
    }
  }

  /// 发送文本消息
  /// @param text 消息内容
  void sendMessage(String text) async {
    if (text.isEmpty || currentChat.value == null) return;

    try {
      final messageTime = DateTime.now().millisecondsSinceEpoch;

      // 构建消息体
      Map<String, dynamic> messageBody = {'message': text};

      // 根据聊天类型构建不同的请求参数
      Map<String, dynamic> params;

      if (currentChat.value?.chatType == MessageType.singleMessage.code) {
        // 单聊消息
        params = {
          'fromId': userId.value,
          'toId': currentChat.value?.id,
          'messageBody': messageBody,
          'messageContentType': 1,
          'messageTime': messageTime.toString(),
          'messageType': MessageType.singleMessage.code
        };
      } else if (currentChat.value?.chatType == MessageType.groupMessage.code) {
        // 群聊消息
        params = {
          'fromId': userId.value,
          'groupId': currentChat.value?.id,
          'messageBody': messageBody,
          'messageContentType': 1,
          'messageTime': messageTime.toString(),
          'messageType': MessageType.groupMessage.code
        };
      } else {
        throw Exception('不支持的消息类型');
      }

      // 调用API发送消息
      final res = await _apiService.sendSingleMessage(params);

      if (res?['status'] == 200) {
        // 构建MessageReceiveDto对象
        MessageReceiveDto dto = MessageReceiveDto.fromJson(res?['data']);

        // 更新消息列表和会话列表
        await handleCreateOrUpdateChat(dto, true);
      } else {
        throw Exception(res?['message'] ?? '发送消息失败');
      }
    } catch (e) {
      errorMessage.value = '发送消息失败: $e';
    }
  }

  /// 设置当前会话并标记消息已读
  /// @param chat 要设置的会话
  void setCurrentChat(Chats chat) async {
    currentChat.value = chat;

    // 重置未读消息数
    chat.unread = 0;

    // 更新数据库
    await db.chatsDao.updateChat(chat);

    // 更新会话列表
    // messageList.clear();
    chatList.refresh();

    // 调用后台API标记消息已读
    try {
      final res = await _apiService.readChat(
          {'chatType': chat.chatType, 'fromId': chat.ownerId, 'toId': chat.id});

      if (res?['status'] == 200) {
        Get.log('标记消息已读成功');
      } else {
        Get.log('标记消息已读失败: ${res?['message']}');
      }
    } catch (e) {
      Get.log('标记消息已读失败: $e');
    }

    // 加载消息列表
    handleSetMessageList(chat);
  }

  /// 处理视频通话请求
  /// @param friend 好友信息
  /// @return 是否成功发起通话
  Future<bool> handleCallVideo(Friend friend) async {
    bool isSuccess = false;
    // 视频通话请求
    final res = await _apiService.sendCallMessage({
      'fromId': userId.value,
      'toId': friend.userId,
      'type': MessageContentType.rtcCall.code
    });

    if (res?['status'] == 200) {
      // 发起通话后跳转到视频页面
      Get.toNamed("${Routes.HOME}${Routes.VIDEO_CALL}", arguments: {
        'userId': userId.value,
        'friendId': friend.userId,
        'isInitiator': true
      });
      isSuccess = true;
    }
    return isSuccess;
  }

  /// 处理视频通话相关消息
  /// @param dto 视频通话消息数据
  void handleCallMessage(MessageVideoCallDto dto) async {
    if (dto.type == MessageContentType.rtcCall.code) {
      // 获取好友信息
      final response = await _apiService
          .getFriendInfo({'fromId': userId.value, 'toId': dto.fromId});

      Friend friend = Friend.fromJson(response?['data']);

      // 显示呼叫弹窗
      VideoCallSnackbar.show(
        avatar: friend.avatar ?? '',
        username: friend.name ?? '',
        onAccept: () async {
          // 处理接通逻辑
          final res = await _apiService.sendCallMessage({
            'fromId': userId.value,
            'toId': dto.fromId,
            'type': MessageContentType.rtcAccept.code
          });

          if (res?['status'] == 200) {
            Get.toNamed("${Routes.HOME}${Routes.VIDEO_CALL}", arguments: {
              'userId': userId.value,
              'friendId': dto.fromId,
              'isInitiator': false
            });
            // 发送接受通话事件
            // Get.find<EventBus>().emit(
            //     'call_accepted', {'fromId': dto.fromId, 'toId': userId.value});
          }
        },
        onReject: () async {
          // 发送拒绝消息
          await _apiService.sendCallMessage({
            'fromId': userId.value,
            'toId': dto.fromId,
            'type': MessageContentType.rtcReject.code
          });
        },
      );
    }

    if (dto.type == MessageContentType.rtcAccept.code) {
      //Get.snackbar('通话提示', '对方已接受通话');
      // 发送接受通话事件
      Get.find<EventBus>()
          .emit('call_accept', {'fromId': dto.fromId, 'toId': userId.value});
    }

    // 拒绝通话
    if (dto.type == MessageContentType.rtcReject.code) {
      Get.snackbar('通话提示', '对方已拒绝通话');
      Get.find<EventBus>().emit('call_reject', dto);
      //Get.back(); // 关闭视频页面
    }

    // 取消通话
    if (dto.type == MessageContentType.rtcCancel.code) {
      Get.snackbar('通话提示', '对方已取消通话');
      Get.find<EventBus>().emit('call_cancel', dto);
      //Get.back(); // 关闭视频页面
    }

    // 挂断通话
    if (dto.type == MessageContentType.rtcHangup.code) {
      Get.snackbar('通话提示', '通话已结束');
      Get.find<EventBus>().emit('call_hangup', dto);
      //Get.back(); // 关闭视频页面
    }
  }

  /// 同步会话和消息
  /// 从服务器获取最新的消息并更新本地数据库
  Future<void> syncChatsAndMessages() async {
    try {
      // 获取最后一条消息的时间戳
      final lastMessageTime = await _getLastMessageTimestamp();

      // 同步消息列表
      final messagesResponse = await _apiService.getMessageList(
          {'fromId': userId.value, 'sequence': lastMessageTime});

      if (messagesResponse != null && messagesResponse['status'] == 200) {
        final Map<String, dynamic> newMessages = messagesResponse['data'] ?? [];

        // 处理单聊和群聊消息
        _processSyncedMessages(newMessages, MessageType.singleMessage.code);
        _processSyncedMessages(newMessages, MessageType.groupMessage.code);
      }
    } catch (e) {
      Get.log('同步会话和消息失败: $e');
    }
  }

// 新增辅助方法处理消息同步
  void _processSyncedMessages(
      Map<String, dynamic> newMessages, int messageType) {
    if (newMessages.isNotEmpty &&
        (newMessages.containsKey(messageType) ||
            newMessages.containsKey(messageType.toString()))) {
      List<dynamic> messagesList =
          newMessages[messageType] ?? newMessages[messageType.toString()];
      for (Map<String, dynamic> message in messagesList) {
        message.putIfAbsent('messageType', () => messageType);
        message['messageBody'] = json.decode(message['messageBody']);
        MessageReceiveDto dto = MessageReceiveDto.fromJson(message);
        // TODO: 处理消息更新
        handleCreateOrUpdateChat(dto, false);
      }
    }
  }

  // 获取最后一条消息的时间戳
  Future<int> _getLastMessageTimestamp() async {
    // 获取最后一条会话消息时间
    // final lastChat = await db.chatsDao.getLastChat(userId.value);

    // 获取最后一条消息时间
    final lastMessage = await db.singleMessageDao.getLastMessage(userId.value);

    // 获取最后一条群聊消息时间
    final lastGroupMessage =
        await db.groupMessageDao.getLastMessage(userId.value);

    // 返回最新的时间戳
    if (lastMessage?.messageTime != null ||
        lastGroupMessage?.messageTime != null) {
      return (lastMessage?.messageTime ?? 0) >
              (lastGroupMessage?.messageTime ?? 0)
          ? lastMessage!.messageTime
          : lastGroupMessage!.messageTime;
    }

    // // 返回最新的时间戳
    // return lastChat?.sequence ?? 0;
    return 0;
  }

  /// 根据好友信息设置当前会话
  /// @param friend 好友信息
  /// @return 是否成功设置
  Future<bool> setCurrentChatByFriend(Friend friend) async {
    bool isSuccess = false;

    // 查找会话
    final chats = chatList
        .where((chats) =>
            chats.ownerId == userId.value && chats.toId == friend.userId)
        .toList();

    // 如果找到会话，设置当前会话
    if (chats.isNotEmpty) {
      currentChat.value = chats.first;

      // 设置会话列表
      setCurrentChat(currentChat.value!);

      isSuccess = true;
    } else {
      final res = await _apiService.createChat({
        'fromId': userId.value,
        'toId': friend.userId,
        'chatType': MessageType.singleMessage.code
      });

      if (res?['status'] == 200) {
        Chats chat = Chats.fromJson(res?['data']);

        await db.chatsDao.insertChat(chat);

        chatList.add(chat);

        setCurrentChat(chat);

        isSuccess = true;
      }
    }

    return isSuccess;
  }
}

// Future<void> insertOrUpdateChat(Chats chat) async {
//   try {
//     // 检查是否存在相同id的聊天
//     final existingChat =
//         chatList.firstWhereOrNull((c) => c.chatId == chat.chatId);

//     if (existingChat != null) {
//       // 如果存在，更新聊天
//       await updateChatById(chat);
//     } else {
//       // 如果不存在，添加聊天
//       await addChat(chat);
//     }
//   } catch (e) {
//     errorMessage.value = '添加或更新聊天失败: $e';
//   } finally {
//     //await _initializeChats();
//   }
// }
