import 'dart:async';
import '../models/coplay_models.dart';

/// State representation for the Co-Play Riverpod / BLoC controller.
class CoPlayState {
  final SessionStatus status;
  final int currentRound;
  final int totalRounds;
  final QuestionItem? activeQuestion;
  final RevealData? latestReveal;
  final String? partnerName;
  final bool isConnected;
  final bool isWaitingForPartner;
  final String? errorMessage;
  final bool isReconnecting;

  const CoPlayState({
    this.status = SessionStatus.waitingForPartner,
    this.currentRound = 0,
    this.totalRounds = 3,
    this.activeQuestion,
    this.latestReveal,
    this.partnerName,
    this.isConnected = false,
    this.isWaitingForPartner = false,
    this.errorMessage,
    this.isReconnecting = false,
  });

  CoPlayState copyWith({
    SessionStatus? status,
    int? currentRound,
    int? totalRounds,
    QuestionItem? activeQuestion,
    RevealData? latestReveal,
    String? partnerName,
    bool? isConnected,
    bool? isWaitingForPartner,
    String? errorMessage,
    bool? isReconnecting,
  }) {
    return CoPlayState(
      status: status ?? this.status,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      activeQuestion: activeQuestion ?? this.activeQuestion,
      latestReveal: latestReveal ?? this.latestReveal,
      partnerName: partnerName ?? this.partnerName,
      isConnected: isConnected ?? this.isConnected,
      isWaitingForPartner: isWaitingForPartner ?? this.isWaitingForPartner,
      errorMessage: errorMessage,
      isReconnecting: isReconnecting ?? this.isReconnecting,
    );
  }
}

/// State Manager / Notifier handling synchronous co-presence,
/// dual-reveal mechanics, and resilient reconnection states.
class CoPlayStateManager {
  CoPlayState _state = const CoPlayState();
  final _stateController = StreamController<CoPlayState>.broadcast();

  CoPlayState get state => _state;
  Stream<CoPlayState> get stream => _stateController.stream;

  void emit(CoPlayState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  void handleConnected() {
    emit(_state.copyWith(
      isConnected: true,
      isReconnecting: false,
      errorMessage: null,
    ));
  }

  void handlePartnerJoined(String partnerName, QuestionItem firstQuestion) {
    emit(_state.copyWith(
      status: SessionStatus.roundActive,
      partnerName: partnerName,
      activeQuestion: firstQuestion,
      isWaitingForPartner: false,
    ));
  }

  void submitAnswerOptimistic(String answer) {
    emit(_state.copyWith(
      status: SessionStatus.waitingForReveal,
      isWaitingForPartner: true,
    ));
  }

  void handleReveal(RevealData reveal) {
    emit(_state.copyWith(
      status: SessionStatus.roundRecap,
      latestReveal: reveal,
      isWaitingForPartner: false,
    ));
  }

  void advanceRound(int nextRound, QuestionItem nextQuestion) {
    emit(_state.copyWith(
      status: SessionStatus.roundActive,
      currentRound: nextRound,
      activeQuestion: nextQuestion,
      latestReveal: null,
      isWaitingForPartner: false,
    ));
  }

  void handleConnectionLost() {
    emit(_state.copyWith(
      isConnected: false,
      isReconnecting: true,
      errorMessage: "Connection dropped. Reconnecting to your partner...",
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
