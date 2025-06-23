const { createDeck, shuffle } = require('./game');

const deck = shuffle(createDeck());
const player1 = deck.splice(0, 3);
const player2 = deck.splice(0, 3);

console.log('Mao do Jogador 1:', player1);
console.log('Mao do Jogador 2:', player2);
