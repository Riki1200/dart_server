import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart';
import '../services/socket_service.dart';

// --- Events ---
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameConnect extends GameEvent {
  final String name;
  final String userId;
  final String roomId;
  final String role;
  final String? adminKey;

  const GameConnect({
    required this.name,
    required this.userId,
    required this.roomId,
    required this.role,
    this.adminKey,
  });
}

class GameDisconnect extends GameEvent {}

class GameSelectRandom extends GameEvent {}

class GameSelectUser extends GameEvent {
  final String userId;
  const GameSelectUser(this.userId);
}

class GameReset extends GameEvent {}

class GameSendMessage extends GameEvent {
  final String targetUserId;
  final String message;
  const GameSendMessage(this.targetUserId, this.message);
}

class _GameSocketMessage extends GameEvent {
  final Map<String, dynamic> message;
  const _GameSocketMessage(this.message);
}

class _GameSocketError extends GameEvent {
  final dynamic error;
  const _GameSocketError(this.error);
}

// --- State ---
class GameState extends Equatable {
  final bool connected;
  final Map<String, dynamic>? me;
  final List<Map<String, dynamic>> adminUsers;
  final List<Map<String, dynamic>> adminHistory;
  final bool iWasSelected;
  final int? lastRoundAt;
  final String? errorMessage;
  final String? adminMessage; // For showing dialogs
  final int? countdownValue;

  const GameState({
    this.connected = false,
    this.me,
    this.adminUsers = const [],
    this.adminHistory = const [],
    this.iWasSelected = false,
    this.lastRoundAt,
    this.errorMessage,
    this.adminMessage,
    this.countdownValue,
  });

  GameState copyWith({
    bool? connected,
    Map<String, dynamic>? me,
    List<Map<String, dynamic>>? adminUsers,
    List<Map<String, dynamic>>? adminHistory,
    bool? iWasSelected,
    int? lastRoundAt,
    String? errorMessage,
    String? adminMessage,
    int? countdownValue,
    bool clearCountdown = false,
  }) {
    return GameState(
      connected: connected ?? this.connected,
      me: me ?? this.me,
      adminUsers: adminUsers ?? this.adminUsers,
      adminHistory: adminHistory ?? this.adminHistory,
      iWasSelected: iWasSelected ?? this.iWasSelected,
      lastRoundAt: lastRoundAt ?? this.lastRoundAt,
      errorMessage: errorMessage, // Always clear unless set
      adminMessage: adminMessage, // Always clear unless set
      countdownValue: clearCountdown
          ? null
          : (countdownValue ?? this.countdownValue),
    );
  }

  bool get isAdmin => me?['role'] == 'admin';

  @override
  List<Object?> get props => [
    connected,
    me,
    adminUsers,
    adminHistory,
    iWasSelected,
    lastRoundAt,
    errorMessage,
    adminMessage,
    countdownValue,
  ];
}

// --- Bloc ---
class GameBloc extends Bloc<GameEvent, GameState> {
  final SocketService _socketService;
  // final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _socketSubscription;
  Timer? _countdownTimer;

  GameBloc({SocketService? socketService})
    : _socketService = socketService ?? SocketService(),
      super(const GameState()) {
    on<GameConnect>(_onConnect);
    on<GameDisconnect>(_onDisconnect);
    on<GameSelectRandom>((_, __) => _socketService.send('select.random', {}));
    on<GameSelectUser>(
      (e, _) => _socketService.send('select.user', {'userId': e.userId}),
    );
    on<GameReset>((_, __) => _socketService.send('reset', {}));
    on<GameSendMessage>(
      (e, _) => _socketService.send('admin.message', {
        'targetUserId': e.targetUserId,
        'message': e.message,
      }),
    );
    on<_GameSocketMessage>(_onSocketMessage);
    on<_GameSocketError>(_onSocketError);
    on<_GameCountdownTick>(_onCountdownTick);
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    _countdownTimer?.cancel();
    _socketService.close();
    return super.close();
  }

  void _onConnect(GameConnect event, Emitter<GameState> emit) {
    if (state.connected) return;

    _socketService.connect('ws://localhost:8080');
    _socketSubscription?.cancel();
    _socketSubscription = _socketService.stream.listen(
      (msg) => add(_GameSocketMessage(msg)),
      onError: (err) => add(_GameSocketError(err)),
    );

    _socketService.send('join', {
      'roomId': event.roomId,
      'userId': event.userId,
      'name': event.name,
      'role': event.role,
      'adminKey': event.adminKey,
    });
  }

  void _onDisconnect(GameDisconnect event, Emitter<GameState> emit) {
    _socketService.close();
    _socketSubscription?.cancel();
    _countdownTimer?.cancel();
    emit(const GameState(connected: false));
  }

  void _onSocketError(_GameSocketError event, Emitter<GameState> emit) {
    emit(
      state.copyWith(
        connected: false,
        errorMessage: 'Error de conexión: ${event.error}',
      ),
    );
  }

  void _onCountdownTick(_GameCountdownTick event, Emitter<GameState> emit) {
    if (event.value <= 0) {
      emit(state.copyWith(clearCountdown: true));
    } else {
      emit(state.copyWith(countdownValue: event.value));
    }
  }

  void _onSocketMessage(_GameSocketMessage event, Emitter<GameState> emit) {
    final msg = event.message;
    final type = msg['type'] as String;
    final payload = (msg['payload'] ?? {}) as Map<String, dynamic>;

    switch (type) {
      case 'joined':
        emit(
          state.copyWith(
            connected: true,
            me: payload['you'] as Map<String, dynamic>,
          ),
        );
        break;
      case 'admin.state':
        emit(
          state.copyWith(
            adminUsers: List<Map<String, dynamic>>.from(
              payload['users'] as List,
            ),
            adminHistory: List<Map<String, dynamic>>.from(
              payload['history'] as List,
            ),
          ),
        );
        break;
      case 'countdown':
        final seconds = payload['seconds'] as int? ?? 3;
        _startCountdown(seconds);
        break;
      case 'you.selected':
        emit(
          state.copyWith(
            iWasSelected: true,
            lastRoundAt: payload['at'] as int?,
            errorMessage:
                '¡Fuiste seleccionado! 🤫', // Using error for snackbar
            clearCountdown: true,
          ),
        );
        HapticFeedback.heavyImpact();
        _playSound('sounds/win.mp3');
        break;
      case 'admin.selected':
        emit(
          state.copyWith(
            lastRoundAt: payload['at'] as int?,
            clearCountdown: true,
          ),
        );
        break;
      case 'round.update':
        emit(
          state.copyWith(
            iWasSelected: false,
            lastRoundAt: payload['at'] as int?,
            clearCountdown: true,
          ),
        );
        HapticFeedback.lightImpact();
        break;
      case 'error':
        emit(state.copyWith(errorMessage: payload['message']));
        break;
      case 'reset':
        emit(
          state.copyWith(
            iWasSelected: false,
            lastRoundAt: null, // Force null
            errorMessage: 'El administrador ha reiniciado la partida.',
            clearCountdown: true,
          ),
        );
        break;
      case 'admin.message':
        emit(state.copyWith(adminMessage: payload['message']));
        break;
    }
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    add(_GameCountdownTick(seconds));
    var current = seconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      current--;
      add(_GameCountdownTick(current));
      if (current <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _playSound(String assetPath) async {
    try {
      // await _audioPlayer.play(AssetSource(assetPath));
      print('Reproduciendo sonido: $assetPath');
    } catch (e) {
      print('Error reproduciendo sonido: $e');
    }
  }
}

class _GameCountdownTick extends GameEvent {
  final int value;
  const _GameCountdownTick(this.value);
}
