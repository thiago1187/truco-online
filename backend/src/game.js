const rooms = require('./rooms');

const SUITS = ['paus', 'copas', 'espadas', 'ouros'];
// Ordem de força das cartas no Truco paulista
const RANKS = ['4', '5', '6', '7', 'Q', 'J', 'K', 'A', '2', '3'];

function createDeck() {
    const deck = [];
    for (const suit of SUITS) {
        for (const rank of RANKS) {
            deck.push({ suit, rank });
        }
    }
    return deck;
}

function shuffle(deck) {
    for (let i = deck.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [deck[i], deck[j]] = [deck[j], deck[i]];
    }
    return deck;
}

function startGame(roomName, io) {
    const room = rooms.getRoom(roomName);
    if (!room) {
        return;
    }

    const deck = shuffle(createDeck());
    room.game = {
        hands: {},
        currentTurnIndex: 0,
        playersOrder: room.players.slice(),
    };

    room.players.forEach((player) => {
        room.game.hands[player] = deck.splice(0, 3);
        io.to(roomName).emit('hand', { player, hand: room.game.hands[player] });
    });

    io.to(roomName).emit('gameStarted', 'O jogo começou!');

    const firstPlayer = room.game.playersOrder[room.game.currentTurnIndex];
    const socketId = room.sockets[firstPlayer];
    if (socketId) {
        io.to(socketId).emit('suaVez');
    }
}

function playCard(roomName, username, card, io) {
    const room = rooms.getRoom(roomName);
    if (!room || !room.game) return;

    const hand = room.game.hands[username];
    if (hand) {
        const index = hand.findIndex(
            (c) => c.suit === card.suit && c.rank === card.rank
        );
        if (index !== -1) {
            hand.splice(index, 1);
        }
    }

    io.to(roomName).emit('cartaJogada', { username, card });

    room.game.currentTurnIndex =
        (room.game.currentTurnIndex + 1) % room.game.playersOrder.length;
    const nextPlayer = room.game.playersOrder[room.game.currentTurnIndex];
    const socketId = room.sockets[nextPlayer];
    if (socketId) {
        io.to(socketId).emit('suaVez');
    }
}

function rankValue(card) {
    return RANKS.indexOf(card.rank);
}

function compareCards(a, b) {
    return rankValue(a) - rankValue(b);
}

module.exports = {
    startGame,
    playCard,
    createDeck,
    shuffle,
    compareCards,
};

