import 'package:flutter/material.dart';

class AdminPanel extends StatelessWidget {
  final List<Map<String, dynamic>> adminUsers;
  final List<Map<String, dynamic>> adminHistory;
  final Function() onSelectRandom;
  final Function() onReset;
  final Function(String) onSelectUser;
  final Function(String, String) onSendMessage;

  const AdminPanel({
    super.key,
    required this.adminUsers,
    required this.adminHistory,
    required this.onSelectRandom,
    required this.onReset,
    required this.onSelectUser,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSelectRandom,
                  icon: const Icon(Icons.casino_rounded),
                  label: const Text('Sorteo Rápido'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6), // Violet
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('¿Reiniciar Partida?'),
                      content: const Text(
                        'Se borrará todo el historial y se desmarcarán los ganadores.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onReset();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Reiniciar'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Resetear todo',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Connected Users
        Row(
          children: [
            const Icon(Icons.people_alt_rounded, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'CONECTADOS (${adminUsers.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 2,
          child: adminUsers.isEmpty
              ? _emptyState('Nadie conectado aún')
              : ListView.builder(
                  itemCount: adminUsers.length,
                  itemBuilder: (_, i) {
                    final u = adminUsers[i];
                    final isPlayer = u['role'] == 'player';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => onSelectUser(u['userId']),
                        leading: CircleAvatar(
                          backgroundColor: isPlayer
                              ? Colors.blue.shade50
                              : Colors.orange.shade50,
                          child: Icon(
                            isPlayer
                                ? Icons.person_rounded
                                : Icons.security_rounded,
                            color: isPlayer
                                ? Colors.blue.shade400
                                : Colors.orange.shade400,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          u['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'ID: ${u['userId']}',
                          style: TextStyle(
                            fontSize: 12,

                            color: Colors.grey.shade400,
                          ),
                        ),
                        trailing: isPlayer
                            ? const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.green,
                              )
                            : null,
                        onLongPress: () {
                          _showMsgDialog(context, u['name'], u['userId']);
                        },
                      ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 24),

        // History
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'HISTORIAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 1,
          child: adminHistory.isEmpty
              ? _emptyState('Sin historial reciente')
              : ListView.builder(
                  itemCount: adminHistory.length,
                  itemBuilder: (_, i) {
                    final h = adminHistory[i];
                    final at = DateTime.fromMillisecondsSinceEpoch(
                      (h['at'] as int),
                    ).toLocal();
                    final timeStr =
                        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.grey.shade50,
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.amber,
                        ),
                        title: Text(
                          h['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          timeStr,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          _showMsgDialog(context, h['name'], h['userId']);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  void _showMsgDialog(BuildContext context, String name, String userId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mensaje a $name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Escribe algo...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onSendMessage(userId, ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
