const rooms = {};

function getRoom(roomName) {
    return rooms[roomName];
}

function createRoom(roomName, socket) {
    if (rooms[roomName]) {
        socket.emit('error', 'Essa sala já existe!');
    } else {
        rooms[roomName] = {
            players: [],
            messages: [],
            sockets: {}
        };
        socket.join(roomName);
        socket.emit('roomCreated', roomName);
        console.log(`Sala criada: ${roomName}`);
    }
}

function joinRoom(roomName, username, socket) {
    if (!rooms[roomName]) {
        socket.emit('error', 'Sala não existe!');
    } else {
        rooms[roomName].players.push(username);
        rooms[roomName].sockets[username] = socket.id;
        socket.username = username;
        socket.join(roomName);
        socket.to(roomName).emit('playerJoined', username);
        console.log(`${username} entrou na sala ${roomName}`);
    }
}

function sendMessage(roomName, username, message, io) {
    if (!rooms[roomName]) return;
    
    const msg = { username, message };
    rooms[roomName].messages.push(msg);
    io.to(roomName).emit('newMessage', msg);
}

function disconnect(socket, io) {
    for (const roomName in rooms) {
        const players = rooms[roomName].players;
        const index = players.indexOf(socket.username);

        if (index !== -1) {
            players.splice(index, 1);
            delete rooms[roomName].sockets[socket.username];
            socket.to(roomName).emit('playerLeft', socket.username);
        }
    }
}

module.exports = {
    createRoom,
    joinRoom,
    sendMessage,
    disconnect,
    getRoom
};