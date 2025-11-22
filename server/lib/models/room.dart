import 'client.dart';

class RoomState {
  final String roomId;
  final Map<String, UserConn> users = {}; // userId -> conn
  final List<Map<String, dynamic>> history = []; // [{userId,name,at}]

  RoomState(this.roomId);
}
