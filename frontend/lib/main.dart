import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'room_page.dart';
import 'game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truco Online',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late IO.Socket socket;
  final TextEditingController roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  void connectSocket() {
    socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.connect();

    socket.onConnect((_) {
      print('🔥🔥🔥🔥🔥🔥 CONECTADO NO BACKEND 🔥🔥🔥🔥🔥🔥');
    });

    socket.onConnectError((data) {
      print('Erro de conexão: $data');
    });

    socket.onError((data) {
      print('Erro geral: $data');
    });

    socket.on('roomCreated', (roomName) {
      print('Sala criada: $roomName');
    });

    socket.on('error', (msg) {
      print('Erro: $msg');
    });
  }

  Future<void> _ensureConnected() async {
    if (socket.connected) return;
    final completer = Completer<void>();
    void handler(_) {
      socket.off('connect', handler);
      if (!completer.isCompleted) completer.complete();
    }

    socket.on('connect', handler);
    socket.connect();
    await completer.future;
  }

  Future<void> createRoom() async {
    final roomName = roomController.text;
    if (roomName.isNotEmpty) {
      await _ensureConnected();
      socket.emit('createRoom', roomName);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomPage(roomName: roomName, socket: socket),
        ),
      );
    }
  }

  Future<void> joinRoom() async {
    final roomName = roomController.text;
    if (roomName.isNotEmpty) {
      await _ensureConnected();
      socket.emit('joinRoom', {
        'roomName': roomName,
        'username': 'convidado',
      });
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomPage(roomName: roomName, socket: socket),
        ),
      );
    }
  }

  Future<void> playAgainstBot() async {
    final random = Random();
    final roomName = 'sala-bot-${random.nextInt(1 << 32)}';
    final playerName = 'Jogador${random.nextInt(1000)}';

    await _ensureConnected();
    socket.emit('createRoom', roomName);
    socket.emit('joinRoom', {
      'roomName': roomName,
      'username': playerName,
    });

    void startGameListener(dynamic username) {
      if (username == 'Bot') {
        socket.off('playerJoined', startGameListener);
        socket.emit('startGame', roomName);
      }
    }

    socket.on('playerJoined', startGameListener);

    try {
      await Process.start('node', ['../backend/bot.js', roomName, 'Bot']);
    } catch (e) {
      print('Erro ao iniciar bot: $e');
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          socket: socket,
          playerName: playerName,
          roomCode: roomName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truco Online'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: 'Nome da sala',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => createRoom(),
              child: const Text('Criar Sala'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => joinRoom(),
              child: const Text('Entrar na Sala'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => playAgainstBot(),
              child: const Text('Jogar contra Bot'),
            ),
          ],
        ),
      ),
    );
  }
}