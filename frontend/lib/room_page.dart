import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RoomPage extends StatefulWidget {
  final String roomName;
  final IO.Socket socket;

  const RoomPage({super.key, required this.roomName, required this.socket});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final List<String> messages = [];
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    widget.socket.on('newMessage', (data) {
      setState(() {
        messages.add('${data['username']}: ${data['message']}');
      });
    });

    widget.socket.on('playerJoined', (username) {
      setState(() {
        messages.add('$username entrou na sala');
      });
    });

    widget.socket.on('playerLeft', (username) {
      setState(() {
        messages.add('$username saiu da sala');
      });
    });
  }

  void sendMessage() {
    final msg = messageController.text;
    if (msg.isNotEmpty) {
      widget.socket.emit('sendMessage', {
        'roomName': widget.roomName,
        'username': 'convidado',
        'message': msg,
      });
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sala: ${widget.roomName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Mensagem',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}