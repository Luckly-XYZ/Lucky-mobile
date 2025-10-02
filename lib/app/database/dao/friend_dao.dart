import 'package:floor/floor.dart';

import '../../models/friend.dart';

@dao
abstract class FriendDao {
  @Query('SELECT * FROM Friend WHERE user_id =:userId')
  Future<Friend?> getFriendById(String userId);

  @insert
  Future<void> insertFriend(Friend friend);

  @update
  Future<void> updateFriend(Friend friend);

  @Query('DELETE FROM Friend WHERE user_id =:userId')
  Future<void> deleteFriend(String userId);
}
