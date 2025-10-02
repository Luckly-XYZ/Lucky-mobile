import 'package:floor/floor.dart';

import '../../models/single_message.dart';

@dao
abstract class SingleMessageDao {
  @Query(
      'SELECT * FROM single_message WHERE ( (fromId = :fromId AND toId = :toId ) OR ( fromId = :toId AND toId = :fromId )) ')
  Future<List<SingleMessage>?> getAllMessages(String fromId, String toId);

// @Query('SELECT COUNT(*) FROM single_messages WHERE chatId = :chatId')
// Future<int> getMessageCount(int chatId);

  @insert
  Future<void> insertMessage(SingleMessage message);

  @Query('''
    SELECT * FROM single_message 
    WHERE ((fromId = :fromId AND toId = :toId) OR (fromId = :toId AND toId = :fromId))
    ORDER BY messageTime DESC 
    LIMIT :limit OFFSET :offset
  ''')
  Future<List<SingleMessage>?> getMessagesByPage(
      String fromId, String toId, int limit, int offset);

  @Query('''
    SELECT * FROM single_message 
    WHERE ownerId = :ownerId
    ORDER BY messageTime DESC 
    LIMIT 1
  ''')
  Future<SingleMessage?> getLastMessage(String ownerId);

  @Query('''
    SELECT * FROM single_message 
    WHERE messageBody LIKE '%' || :keyword || '%'
    AND ((fromId = :userId) OR (toId = :userId))
    ORDER BY messageTime DESC
  ''')
  Future<List<SingleMessage>> searchMessages(String keyword, String userId);
}

// @Insert(onConflict: OnConflictStrategy.replace)
// Future<List<int>> insertMessages(List<SingleMessage> messages);
//
// @Query(
//     'SELECT * FROM single_messages WHERE chatId = :chatId ORDER BY createdAt DESC LIMIT :limit OFFSET :offset')

// Future<List<SingleMessage>> getMessagesByChatId(int chatId,
//     {int limit = 20, int offset = 0});
//
// @Query(
//     'SELECT * FROM single_messages WHERE content LIKE :keyword ORDER BY createdAt DESC')
// Future<List<SingleMessage>> searchMessages(String keyword);
//
// @Query('SELECT COUNT(*) FROM single_messages WHERE chatId = :chatId')
// Future<int> getMessageCount(int chatId);
