const io = require('socket.io-client');

const roomName = process.argv[2] || 'sala-bot';
const username = process.argv[3] || 'Bot';

const socket = io('http://localhost:3000', {
    transports: ['websocket'],
});

let hand = [];

socket.on('connect', () => {
    console.log(`Bot conectado: ${socket.id}`);
    socket.emit('joinRoom', { roomName, username });
});

socket.on('hand', (data) => {
    if (data.player === username) {
        hand = data.hand;
        console.log('Mão recebida:', hand);
    }
});

socket.on('suaVez', () => {
    if (hand.length === 0) return;
    const index = Math.floor(Math.random() * hand.length);
    const card = hand.splice(index, 1)[0];
    console.log('Jogando carta', card);
    socket.emit('jogarCarta', { roomName, username, card });
});
