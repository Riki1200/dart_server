# Selector Amigos

**Selector Amigos** is a real-time multiplayer application designed for interactive group selections, raffles, and games. Built with a **Dart** server and a **Flutter** client, it features a modern, reactive UI with sound, haptics, and visual effects.

## 🚀 Features

### Core Functionality
-   **Real-time Connection**: Powered by WebSockets for instant updates.
-   **Role-Based Access**:
    -   **Admin**: Controls the game, selects winners, resets rounds, and sends messages.
    -   **Player**: Joins the room, waits for selection, and receives feedback.
-   **Random Selection**: Fair and random selection of a connected player.

### User Experience (UX)
-   **Suspenseful Countdown**: A 3-second countdown (3... 2... 1...) builds excitement before revealing the winner.
-   **Visual Effects**: Custom particle-based **Confetti** celebration for the winner.
-   **Haptic Feedback**: Heavy impact vibration for the winner, light feedback for others.
-   **Sound Effects**: Audio cues for selection and winning (requires `assets/sounds/win.mp3`).
-   **Direct Messaging**: Admins can send private messages to specific players via long-press.

### Architecture
-   **Clean Architecture**: Separation of concerns with Models, Controllers, and Services.
-   **State Management**: Uses **BLoC (Business Logic Component)** for predictable state management in the Flutter client.
-   **Scalable Server**: Modular Dart server handling room state and broadcasting.

## 🛠️ Tech Stack

-   **Server**: Dart (Standalone)
-   **Client**: Flutter (Mobile/Web/Desktop)
-   **Communication**: WebSockets (`web_socket_channel`)
-   **State Management**: `flutter_bloc`, `equatable`
-   **Audio**: `audioplayers`

## 📂 Project Structure

```
dart_server/
├── server/                 # Dart Server
│   ├── bin/                # Entry point
│   ├── lib/
│   │   ├── controllers/    # Game logic (GameController)
│   │   └── models/         # Data models (UserConn, RoomState)
│   └── main.dart
│
└── client/                 # Flutter Client
    ├── lib/
    │   ├── bloc/           # GameBloc (State Management)
    │   ├── models/         # Client-side models
    │   ├── screens/        # UI Screens (Login, Home)
    │   ├── services/       # SocketService
    │   └── widgets/        # Reusable widgets (AdminPanel, ConfettiOverlay)
    └── pubspec.yaml
```

## ⚡ Getting Started

### Prerequisites
-   [Flutter SDK](https://flutter.dev/docs/get-started/install)
-   [Dart SDK](https://dart.dev/get-dart)

### 1. Run the Server
The server listens on `ws://localhost:8080`.

```bash
cd server
dart run bin/main.dart
```

> **Note**: The default Admin Key is set to `'CHANGE_ME_ADMIN_KEY'` in `server/lib/controllers/game_controller.dart`.

### 2. Run the Client
Launch the Flutter application on your preferred device or emulator.

```bash
cd client
flutter run
```

### 3. Usage
1.  **Login**: Enter your name.
2.  **Role**:
    -   Select **Player** to join the waiting list.
    -   Select **Admin** and enter the Admin Key to gain control.
3.  **Admin Controls**:
    -   **Sorteo Rápido**: Triggers the countdown and selects a random winner.
    -   **Reset**: Clears the history and resets the game state.
    -   **Long-Press User**: Send a private message.

## 🎨 Customization

-   **Sound**: Add your own `win.mp3` to `client/assets/sounds/` to enable sound effects.
-   **Theme**: Modify `client/lib/main.dart` to change the color scheme (currently Indigo/Slate).


## 📄 License
This project is open-source and available for personal and educational use.
