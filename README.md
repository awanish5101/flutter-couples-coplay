# Flutter Couples Co-Play Mobile Client & Real-Time Sync Engine

[![CI](https://github.com/awanish5101/flutter-couples-coplay/actions/workflows/ci.yml/badge.svg)](https://github.com/awanish5101/flutter-couples-coplay/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg)](https://dart.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A real-time co-play mobile application and synchronized event stream engine built for long-distance and bedtime couples co-presence. Implements complete mobile product flows with loading skeletons, empty states, dual-blind answer submissions, simultaneous reveals, and auto-retry reconnection handling.

---

## Features

- **Flutter / Dart Mobile Client:**
  - Architected using **Riverpod / BLoC** state management for reactive UI updates and separation of concerns.
  - Complete flow handling: loading skeleton cards, empty state partner invites, round question cards, dual-reveal modal sheets, and connection recovery banners.
  - Tactile interaction design with immediate client-side optimistic responses before network synchronization.
- **Real-Time WebSocket Synchronization Engine:**
  - Low-latency full-duplex communication over WebSockets with heartbeat ping/pong keep-alives.
  - **Dual-Blind Reveal Protocol:** Partner submissions are securely masked on the server until both players answer, triggering a synchronized event broadcast with compatibility scoring and conversation starters.
  - Automatic exponential backoff reconnection and state recovery when network connectivity drops.
- **Backend & Cloud Architecture:**
  - Lightweight Node.js WebSocket broker with Docker containerization and CI automation via GitHub Actions.

---

## Project Structure

```text
flutter-couples-coplay/
├── lib/
│   ├── models/
│   │   └── coplay_models.dart        # Session, Question, and Reveal domain entities
│   ├── state/
│   │   └── coplay_state_manager.dart # Riverpod/BLoC state controller & retry policies
│   ├── views/
│   │   └── coplay_game_view.dart     # Complete Flutter UI widget tree (empty/loading/active)
├── server/
│   └── server.js                     # Node.js WebSocket co-play room broker
├── test/
│   └── test_coplay.py                # Protocol & state transition validation
├── pubspec.yaml                      # Flutter dependencies
├── Dockerfile                        # Backend containerization
└── README.md
```

---

## Quickstart

### 1. Start Real-Time WebSocket Server

```bash
cd server
npm install ws
node server.js
```

Server starts on port `8080`.

### 2. Run Flutter Client

```bash
flutter pub get
flutter run
```

---

## License

MIT License. Developed by [Awanish Chaurasiya](https://github.com/awanish5101).
