import 'dart:convert';
import 'dart:io';
import '../models/client.dart';
import '../models/room.dart';

class GameController {
  final Map<String, RoomState> rooms = {};
  static const String adminSecret = 'CHANGE_ME_ADMIN_KEY';

  void handleSocket(WebSocket socket) {
    print('Client connected');
    UserConn? me;
    RoomState? room;

    socket.listen((data) async {
      try {
        final msg = jsonDecode(data as String) as Map<String, dynamic>;
        final type = msg['type'] as String? ?? '';
        final payload = (msg['payload'] ?? {}) as Map<String, dynamic>;

        if (type == 'join') {
          final roomId = payload['roomId'] as String? ?? 'default';
          final userId = payload['userId'] as String? ?? _rid();
          final name = payload['name'] as String? ?? 'Player';
          final role = (payload['role'] as String? ?? 'player').toLowerCase();
          final key = payload['adminKey'] as String?;

          final effectiveRole = (role == 'admin')
              ? (key == adminSecret ? 'admin' : 'player')
              : 'player';

          room = rooms.putIfAbsent(roomId, () => RoomState(roomId));
          me = UserConn(
              socket: socket, userId: userId, name: name, role: effectiveRole);
          room!.users[userId] = me!;

          _send(socket, 'joined', {
            'you': {'userId': userId, 'name': name, 'role': effectiveRole}
          });

          if (effectiveRole == 'admin') {
            _sendAdminState(
                room!, socket); // opcional, el broadcast igual lo cubrirá
          }
          _broadcastAdmins(room!);
        } else if (type == 'select.random') {
          if (!_ensureAdmin(me, socket)) return;
          final r = room;
          if (r == null) return _err(socket, 'No room');
          final candidates =
              r.users.values.where((u) => u.role == 'player').toList();
          if (candidates.isEmpty) return _err(socket, 'No hay jugadores.');

          // Broadcast countdown
          for (final u in r.users.values) {
            _send(u.socket, 'countdown', {'seconds': 3});
          }

          // Wait for countdown
          await Future.delayed(const Duration(seconds: 3));

          // Re-check candidates (someone might have left)
          final freshCandidates =
              r.users.values.where((u) => u.role == 'player').toList();
          if (freshCandidates.isEmpty)
            return _err(socket, 'Todos se fueron...');

          freshCandidates.shuffle();
          final pick = freshCandidates.first;
          _registerSelection(r, pick);
        } else if (type == 'select.user') {
          if (!_ensureAdmin(me, socket)) return;
          final r = room;
          if (r == null) return _err(socket, 'No room');
          final targetId = payload['userId'] as String?;
          if (targetId == null) return _err(socket, 'userId requerido.');
          final pick = r.users[targetId];
          if (pick == null || pick.role != 'player')
            return _err(socket, 'Jugador no encontrado.');
          _registerSelection(r, pick);
        } else if (type == 'reset') {
          if (!_ensureAdmin(me, socket)) return;
          final r = room;
          if (r == null) return _err(socket, 'No room');

          r.history.clear();
          _broadcastAdmins(r);
          for (final u in r.users.values) {
            _send(u.socket, 'reset', {});
          }
        } else if (type == 'admin.message') {
          if (!_ensureAdmin(me, socket)) return;
          final r = room;
          if (r == null) return _err(socket, 'No room');

          final targetId = payload['targetUserId'] as String?;
          final message = payload['message'] as String?;

          if (targetId == null || message == null) {
            return _err(socket, 'Faltan datos (targetUserId, message).');
          }

          final target = r.users[targetId];
          if (target == null) return _err(socket, 'Usuario no encontrado.');

          _send(target.socket, 'admin.message', {'message': message});
        }
      } catch (e) {
        _err(socket, 'JSON inválido: $e');
      }
    }, onDone: () {
      final r = room;
      final u = me;
      if (r != null && u != null) {
        r.users.remove(u.userId);
        print('Client ${u.userId} disconnected');
        _broadcastAdmins(r);
      }
    }, onError: (err) {
      print('Socket error: $err');
    });
  }

  bool _ensureAdmin(UserConn? me, WebSocket s) {
    if (me == null || me.role != 'admin') {
      _err(s, 'Solo admin.');
      return false;
    }
    return true;
  }

  void _registerSelection(RoomState r, UserConn pick) {
    final at = DateTime.now().millisecondsSinceEpoch;

    // 1) Notificación PRIVADA al jugador seleccionado
    _send(pick.socket, 'you.selected', {'at': at});

    // 2) Notificación a todos los admins
    for (final u in r.users.values.where((u) => u.role == 'admin')) {
      _send(u.socket, 'admin.selected', {
        'userId': pick.userId,
        'name': pick.name,
        'at': at,
      });
    }

    // 3) Notificación genérica a jugadores NO seleccionados
    for (final u in r.users.values
        .where((u) => u.role == 'player' && u.userId != pick.userId)) {
      _send(u.socket, 'round.update', {'at': at});
    }

    // 4) Guardar en historial
    r.history.add({'userId': pick.userId, 'name': pick.name, 'at': at});

    // 5) Actualizar estado a admins (lista + historial)
    _broadcastAdmins(r);
  }

  void _broadcastAdmins(RoomState r) {
    final admins = r.users.values.where((u) => u.role == 'admin');
    for (final a in admins) {
      _sendAdminState(r, a.socket);
    }
  }

  void _sendAdminState(RoomState r, WebSocket adminSocket) {
    final users = r.users.values
        .map((u) => {'userId': u.userId, 'name': u.name, 'role': u.role})
        .toList();
    _send(adminSocket, 'admin.state', {'users': users, 'history': r.history});
  }

  void _send(WebSocket s, String type, Map<String, dynamic> payload) {
    s.add(jsonEncode({'type': type, 'payload': payload}));
  }

  void _err(WebSocket s, String message) {
    _send(s, 'error', {'message': message});
  }

  String _rid() => DateTime.now().microsecondsSinceEpoch.toString();
}
