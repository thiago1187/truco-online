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
  String? roundWinner;
  Map<String, dynamic> scores = {};
  String? gameWinner;

  @override
  void initState() {
    super.initState();

    widget.socket.on('cartasIniciais', _onInitialCards);
    widget.socket.on('hand', _onHand); // suporte ao backend existente
    widget.socket.on('suaVez', _onYourTurn);
    widget.socket.on('roundWinner', _onRoundWinner);
    widget.socket.on('gameWinner', _onGameWinner);
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

  void _onRoundWinner(dynamic data) {
    setState(() {
      roundWinner = data['winner'] as String?;
      scores = Map<String, dynamic>.from(data['scores'] as Map);
    });
  }

  void _onGameWinner(dynamic winner) {
    setState(() {
      gameWinner = winner as String?;
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
    widget.socket.off('roundWinner', _onRoundWinner);
    widget.socket.off('gameWinner', _onGameWinner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo de Truco - ${widget.playerName}'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (!isMyTurn) const Text('Aguardando sua vez...'),
          if (roundWinner != null && gameWinner == null)
            Text('Rodada vencida por $roundWinner - ' +
                scores.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .join(', ')),
          if (gameWinner != null)
            Text('Jogo encerrado! Vencedor: $gameWinner'),
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
