# Truco Online 🃏🔥

Projeto de um aplicativo de Truco Online feito em Flutter (Frontend) e Node.js (Backend).

Desenvolvido por:  
- Thiago Alves  
- Marco Veras

---

## Sobre o Projeto

Esse projeto tem como objetivo criar um app de Truco completo, online e local, com tudo que um jogador quer:

- Criar sala
- Entrar em sala
- Jogar truco clássico
- Jogar truco paulista
- Chat em tempo real
- Multiplayer online
- Visual bonito e responsivo
- Escalável e pronto pra Play Store / App Store futuramente

---

## Tecnologias usadas

### Backend
- Node.js
- Express
- Socket.io
- Estrutura pronta pra deploy com Docker futuramente

### Frontend
- Flutter
- Socket.io Client
- Interface responsiva
- Pronto pra web, desktop e mobile

## Pré-requisitos

Para rodar o projeto é necessário ter o **Node.js** e o **Flutter SDK** instalados.
Garanta que o executável `node` esteja no `PATH`, pois o app Flutter utiliza esse
comando para iniciar o bot automaticamente.

---

## Como Rodar o Projeto Localmente

### 1. Clonar o Repositório

```bash
git clone https://github.com/thiago1187/truco-online.git
cd truco-online

```

### 2. Executar o Backend

```bash
cd backend
npm install
npm start
```
Se precisar alterar a porta padrão (3000), defina a variável `PORT` antes de iniciar o servidor. Exemplo:

```bash
PORT=4000 npm start
```

### 3. Rodar o Frontend Flutter

```bash
cd ../frontend
flutter pub get
flutter run
```

Ao abrir a aplicação, pressione **"Jogar contra Bot"** para iniciar uma partida
contra a IA. O bot será executado automaticamente sem necessidade de comando
adicional.

