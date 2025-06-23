const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const rooms = require('./rooms');
const game = require('./game');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: "*"
    }
});

io.on('connection', (socket) => {
    console.log(`Usuário conectado: ${socket.id}`);

    socket.on('createRoom', (roomName) => {
        rooms.createRoom(roomName, socket);
    });

    socket.on('joinRoom', ({ roomName, username }) => {
        rooms.joinRoom(roomName, username, socket);
    });

    socket.on('startGame', (roomName) => {
        game.startGame(roomName, io);
    });

    socket.on('sendMessage', ({ roomName, username, message }) => {
        rooms.sendMessage(roomName, username, message, io);
    });

    socket.on('disconnect', () => {
        rooms.disconnect(socket, io);
    });
});

server.listen(3000, () => {
    console.log('Servidor rodando na porta 3000');
});