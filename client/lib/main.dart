import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/game_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SelectorApp());
}

class SelectorApp extends StatelessWidget {
  const SelectorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selector Amigos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B), // Slate 800
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: BlocProvider(create: (_) => GameBloc(), child: const GamePage()),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.adminMessage != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Mensaje del Admin'),
              content: Text(state.adminMessage!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        if (!state.connected) {
          return LoginScreen(
            onConnect: (name, userId, roomId, role, key) {
              context.read<GameBloc>().add(
                GameConnect(
                  name: name,
                  userId: userId,
                  roomId: roomId,
                  role: role,
                  adminKey: key,
                ),
              );
            },
          );
        }

        return HomeScreen(
          me: state.me,
          connected: state.connected,
          isAdmin: state.isAdmin,
          iWasSelected: state.iWasSelected,
          lastRoundAt: state.lastRoundAt,
          countdownValue: state.countdownValue,
          adminUsers: state.adminUsers,
          adminHistory: state.adminHistory,
          onDisconnect: () => context.read<GameBloc>().add(GameDisconnect()),
          onSelectRandom: () =>
              context.read<GameBloc>().add(GameSelectRandom()),
          onReset: () => context.read<GameBloc>().add(GameReset()),
          onSelectUser: (uid) =>
              context.read<GameBloc>().add(GameSelectUser(uid)),
          onSendMessage: (uid, msg) =>
              context.read<GameBloc>().add(GameSendMessage(uid, msg)),
        );
      },
    );
  }
}
