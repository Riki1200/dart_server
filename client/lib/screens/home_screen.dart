import 'package:flutter/material.dart';
import '../widgets/admin_panel.dart';
import '../widgets/player_panel.dart';
import '../widgets/confetti_overlay.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic>? me;
  final bool connected;
  final bool isAdmin;
  final bool iWasSelected;
  final int? lastRoundAt;
  final int? countdownValue;
  final List<Map<String, dynamic>> adminUsers;
  final List<Map<String, dynamic>> adminHistory;
  final VoidCallback onDisconnect;
  final VoidCallback onSelectRandom;
  final VoidCallback onReset;
  final Function(String) onSelectUser;
  final Function(String, String) onSendMessage;

  const HomeScreen({
    super.key,
    required this.me,
    required this.connected,
    required this.isAdmin,
    required this.iWasSelected,
    required this.lastRoundAt,
    this.countdownValue,
    required this.adminUsers,
    required this.adminHistory,
    required this.onDisconnect,
    required this.onSelectRandom,
    required this.onReset,
    required this.onSelectUser,
    required this.onSendMessage,
  });

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conectado como: ${me?['name']} (${me?['role']})'),
        if (lastRoundAt != null)
          Text(
            'Última ronda: ${DateTime.fromMillisecondsSinceEpoch(lastRoundAt!).toLocal()}',
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiOverlay(
      shouldPlay: iWasSelected,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Selector Amigos'),
              actions: [
                IconButton(
                  onPressed: onDisconnect,
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Desconectar',
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (isAdmin)
                    Expanded(
                      child: AdminPanel(
                        adminUsers: adminUsers,
                        adminHistory: adminHistory,
                        onSelectRandom: onSelectRandom,
                        onReset: onReset,
                        onSelectUser: onSelectUser,
                        onSendMessage: onSendMessage,
                      ),
                    )
                  else
                    Expanded(child: PlayerPanel(iWasSelected: iWasSelected)),
                ],
              ),
            ),
          ),
          if (countdownValue != null)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  '$countdownValue',
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
