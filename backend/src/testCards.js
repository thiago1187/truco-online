const { compareCards } = require('./game');

const order = ['4', '5', '6', '7', 'Q', 'J', 'K', 'A', '2', '3'];
for (let i = 0; i < order.length - 1; i++) {
  const weaker = { suit: 'paus', rank: order[i] };
  const stronger = { suit: 'copas', rank: order[i + 1] };
  if (compareCards(stronger, weaker) <= 0) {
    console.error(`Erro: ${order[i + 1]} deveria vencer ${order[i]}`);
    process.exit(1);
  }
}
console.log('Todos os testes passaram');
