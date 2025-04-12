// Aqui futuramente vamos colocar toda a lógica do jogo de Truco

function startGame(roomName, io) {
    io.to(roomName).emit('gameStarted', 'O jogo começou!');
}

module.exports = {
    startGame
};