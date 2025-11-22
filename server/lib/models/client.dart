import 'dart:io';

class UserConn {
  final WebSocket socket;
  final String userId;
  final String name;
  final String role;

  UserConn({
    required this.socket,
    required this.userId,
    required this.name,
    required this.role,
  });
}
