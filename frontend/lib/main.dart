import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'room_page.dart';

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
        'https://8d9e-2804-14d-54b8-835c-8850-2802-a70e-4a37.ngrok-free.app',
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

  void createRoom() {
    final roomName = roomController.text;
    if (roomName.isNotEmpty) {
      socket.emit('createRoom', roomName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomPage(roomName: roomName, socket: socket),
        ),
      );
    }
  }

  void joinRoom() {
    final roomName = roomController.text;
    if (roomName.isNotEmpty) {
      socket.emit('joinRoom', {
        'roomName': roomName,
        'username': 'convidado',
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomPage(roomName: roomName, socket: socket),
        ),
      );
    }
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
              onPressed: createRoom,
              child: const Text('Criar Sala'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: joinRoom,
              child: const Text('Entrar na Sala'),
            ),
          ],
        ),
      ),
    );
  }
}