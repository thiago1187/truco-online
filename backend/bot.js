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

// Compatibilidade com servidores mais novos
socket.on('cartasIniciais', (cartas) => {
    hand = cartas;
    console.log('Cartas iniciais recebidas:', hand);
});

socket.on('suaVez', () => {
    if (hand.length === 0) return;
    const index = Math.floor(Math.random() * hand.length);
    const card = hand.splice(index, 1)[0];
    console.log('Jogando carta', card);
    socket.emit('jogarCarta', { roomName, username, card });
});

socket.on('cartaJogada', (data) => {
    console.log(`${data.username} jogou`, data.card);
});