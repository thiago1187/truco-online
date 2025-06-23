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
    room.game = { hands: {} };

    room.players.forEach((player) => {
        room.game.hands[player] = deck.splice(0, 3);
        io.to(roomName).emit('hand', { player, hand: room.game.hands[player] });
    });

    io.to(roomName).emit('gameStarted', 'O jogo começou!');
}

function rankValue(card) {
    return RANKS.indexOf(card.rank);
}

function compareCards(a, b) {
    return rankValue(a) - rankValue(b);
}

module.exports = {
    startGame,
    createDeck,
    shuffle,
    compareCards,
};

