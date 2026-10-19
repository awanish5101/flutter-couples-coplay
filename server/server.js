const http = require('http');
const WebSocket = require('ws');

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', timestamp: Date.now() }));
    return;
  }
  res.writeHead(404);
  res.end();
});

const wss = new WebSocket.Server({ server });
const rooms = new Map(); // roomId -> { players: Map(playerId -> ws), answers: Map(round -> Map(playerId -> answer)) }

wss.on('connection', (ws, req) => {
  let currentRoom = null;
  let currentPlayer = null;

  ws.on('message', (data) => {
    try {
      const msg = JSON.parse(data);
      const { action, roomId, playerId, payload } = msg;

      if (action === 'JOIN_ROOM') {
        currentRoom = roomId;
        currentPlayer = playerId;

        if (!rooms.has(roomId)) {
          rooms.set(roomId, {
            players: new Map(),
            answers: new Map(),
            currentRound: 0,
          });
        }

        const room = rooms.get(roomId);
        room.players.set(playerId, ws);

        // Notify room
        broadcastToRoom(roomId, {
          event: 'PLAYER_JOINED',
          playerId,
          playerCount: room.players.size,
        });

        if (room.players.size >= 2) {
          broadcastToRoom(roomId, {
            event: 'ROUND_STARTED',
            roundIndex: room.currentRound,
          });
        }
      } else if (action === 'SUBMIT_ANSWER') {
        const room = rooms.get(roomId);
        if (!room) return;

        const round = payload.roundIndex;
        if (!room.answers.has(round)) {
          room.answers.set(round, new Map());
        }

        const roundAnswers = room.answers.get(round);
        roundAnswers.set(playerId, payload.answer);

        if (roundAnswers.size < room.players.size) {
          // Notify partner that this player submitted
          broadcastToRoom(roomId, {
            event: 'PARTNER_SUBMITTED',
            playerId,
          });
        } else {
          // Both submitted -> trigger dual reveal
          const allAnswers = Object.fromEntries(roundAnswers);
          const answerValues = Array.from(roundAnswers.values());
          const isMatch = answerValues.length >= 2 && answerValues[0].trim().toLowerCase() === answerValues[1].trim().toLowerCase();

          broadcastToRoom(roomId, {
            event: 'ROUND_REVEAL',
            roundIndex: round,
            answers: allAnswers,
            isMatch,
            compatibilityScore: isMatch ? 100 : 50,
          });
        }
      }
    } catch (e) {
      ws.send(JSON.stringify({ event: 'ERROR', message: e.message }));
    }
  });

  ws.on('close', () => {
    if (currentRoom && currentPlayer) {
      const room = rooms.get(currentRoom);
      if (room) {
        room.players.delete(currentPlayer);
        broadcastToRoom(currentRoom, {
          event: 'PARTNER_DISCONNECTED',
          playerId: currentPlayer,
        });
        if (room.players.size === 0) {
          rooms.delete(currentRoom);
        }
      }
    }
  });
});

function broadcastToRoom(roomId, message) {
  const room = rooms.get(roomId);
  if (!room) return;
  const data = JSON.stringify(message);
  for (const [, client] of room.players) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(data);
    }
  }
}

const PORT = process.env.PORT || 8080;
if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`Co-Play WebSocket Server listening on port ${PORT}`);
  });
}

module.exports = { server, rooms };
