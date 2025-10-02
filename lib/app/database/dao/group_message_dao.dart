import 'package:floor/floor.dart';

import '../../models/group_message.dart';

@dao
abstract class GroupMessageDao {
  @Query('SELECT * FROM group_message WHERE ownerId = :ownerId')
  Future<List<GroupMessage>?> getAllMessages(String ownerId);

  @insert
  Future<void> insertMessage(GroupMessage message);

  @Query('''
    SELECT * FROM group_message 
    WHERE ownerId = :ownerId
    ORDER BY messageTime DESC 
    LIMIT :limit OFFSET :offset
  ''')
  Future<List<GroupMessage>?> getMessagesByPage(
      String ownerId, int limit, int offset);

  @Query('''
    SELECT * FROM group_message 
    WHERE ownerId = :ownerId
    ORDER BY messageTime DESC 
    LIMIT 1
  ''')
  Future<GroupMessage?> getLastMessage(String ownerId);

  @Query('''
    SELECT * FROM group_message 
    WHERE messageBody LIKE '%' || :keyword || '%'
    AND ownerId = :ownerId
    ORDER BY messageTime DESC
  ''')
  Future<List<GroupMessage>> searchMessages(String keyword, String ownerId);
}
