FROM node:18-alpine

WORKDIR /app

COPY server/ ./server/
WORKDIR /app/server
RUN npm init -y && npm install ws

EXPOSE 8080

CMD ["node", "server.js"]
