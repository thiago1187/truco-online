import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GameScreen extends StatefulWidget {
  final IO.Socket socket;
  final String playerName;
  final String roomCode;

  const GameScreen({super.key, required this.socket, required this.playerName, required this.roomCode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Map<String, dynamic>> hand = [];
  bool isMyTurn = false;

  @override
  void initState() {
    super.initState();

    widget.socket.on('cartasIniciais', _onInitialCards);
    widget.socket.on('hand', _onHand); // suporte ao backend existente
    widget.socket.on('suaVez', _onYourTurn);
  }

  void _onInitialCards(dynamic data) {
    setState(() {
      hand = List<Map<String, dynamic>>.from(data as List);
    });
  }

  void _onHand(dynamic data) {
    if (data is Map && data['player'] == widget.playerName) {
      setState(() {
        hand = List<Map<String, dynamic>>.from(data['hand'] as List);
      });
    }
  }

  void _onYourTurn(dynamic _) {
    setState(() {
      isMyTurn = true;
    });
  }

  void playCard(Map<String, dynamic> card) {
    widget.socket.emit('jogarCarta', {
      'roomName': widget.roomCode,
      'username': widget.playerName,
      'card': card,
    });
    setState(() {
      hand.removeWhere(
        (c) => c['suit'] == card['suit'] && c['rank'] == card['rank'],
      );
      isMyTurn = false;
    });
  }

  @override
  void dispose() {
    widget.socket.off('cartasIniciais', _onInitialCards);
    widget.socket.off('hand', _onHand);
    widget.socket.off('suaVez', _onYourTurn);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo de Truco'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (!isMyTurn) const Text('Aguardando sua vez...'),
          Wrap(
            spacing: 8,
            children: hand
                .map(
                  (card) => ElevatedButton(
                    onPressed: isMyTurn ? () => playCard(card) : null,
                    child: Text('${card['rank']} de ${card['suit']}'),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
