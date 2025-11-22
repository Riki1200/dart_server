import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Function(
    String name,
    String userId,
    String roomId,
    String role,
    String? key,
  )
  onConnect;

  const LoginScreen({super.key, required this.onConnect});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController(text: 'Player');
  final _userIdCtrl = TextEditingController(
    text: 'u${DateTime.now().millisecondsSinceEpoch % 100000}',
  );
  final _roomCtrl = TextEditingController(text: 'default');
  final _adminKeyCtrl = TextEditingController(text: 'CHANGE_ME_ADMIN_KEY');
  String _role = 'player';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userIdCtrl.dispose();
    _roomCtrl.dispose();
    _adminKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.groups_3_rounded,
                size: 80,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Únete para participar en el sorteo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 48),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tu Nombre',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _userIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ID de Usuario',
                          prefixIcon: Icon(Icons.fingerprint),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _roomCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Sala',
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _role,
                        items: const [
                          DropdownMenuItem(
                            value: 'player',
                            child: Text('Jugador'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _role = v ?? 'player'),
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      if (_role == 'admin') ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _adminKeyCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Clave de Admin',
                            prefixIcon: Icon(Icons.vpn_key_outlined),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          widget.onConnect(
                            _nameCtrl.text.trim(),
                            _userIdCtrl.text.trim(),
                            _roomCtrl.text.trim(),
                            _role,
                            _role == 'admin' ? _adminKeyCtrl.text.trim() : null,
                          );
                        },
                        child: const Text('Entrar a la Sala'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
