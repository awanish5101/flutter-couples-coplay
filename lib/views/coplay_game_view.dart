import 'package:flutter/material.dart';
import '../models/coplay_models.dart';
import '../state/coplay_state_manager.dart';

/// Flutter UI implementing complete product flow states:
/// 1. Loading Skeletons
/// 2. Empty States (Waiting for partner)
/// 3. Active Co-Play Question Card
/// 4. Waiting for Partner's Submission State
/// 5. Dual Synchronized Reveal Modal
/// 6. Network Drop & Auto-Retry Banner
class CoPlayGameView extends StatelessWidget {
  final CoPlayState state;
  final Function(String) onAnswerSelected;
  final VoidCallback onRetryConnection;
  final VoidCallback onNextRound;

  const CoPlayGameView({
    Key? key,
    required this.state,
    required this.onAnswerSelected,
    required this.onRetryConnection,
    required this.onNextRound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          state.partnerName != null ? "Playing with ${state.partnerName}" : "Bedtime Co-Play",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          _buildConnectionIndicator(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.isReconnecting) _buildRetryBanner(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.isConnected ? Colors.greenAccent : Colors.amberAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildRetryBanner() {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade900.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.errorMessage ?? "Reconnecting to room...",
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetryConnection,
            child: const Text("Retry Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (state.status) {
      case SessionStatus.waitingForPartner:
        return _buildEmptyState();
      case SessionStatus.roundActive:
        return _buildActiveRound();
      case SessionStatus.waitingForReveal:
        return _buildWaitingForReveal();
      case SessionStatus.roundRecap:
        return _buildRevealRecap();
      case SessionStatus.gameComplete:
        return _buildGameComplete();
      default:
        return _buildLoadingSkeleton();
    }
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 24, width: 140, color: Colors.white10),
          const SizedBox(height: 20),
          Container(height: 120, width: double.infinity, color: Colors.white10),
          const SizedBox(height: 24),
          Container(height: 50, width: double.infinity, color: Colors.white10),
          const SizedBox(height: 12),
          Container(height: 50, width: double.infinity, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.pinkAccent),
            const SizedBox(height: 20),
            const Text(
              "Waiting for your partner to open the app...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            const Text(
              "80% of co-play happens between 9 PM and midnight. We'll start as soon as both of you are ready.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRound() {
    final question = state.activeQuestion;
    if (question == null) return _buildLoadingSkeleton();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Round ${state.currentRound + 1} of ${state.totalRounds}",
              style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(question.prompt,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3)),
          const Spacer(),
          ...question.options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => onAnswerSelected(opt),
                    child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWaitingForReveal() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(color: Colors.pinkAccent, strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          const Text("Answer submitted!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text("Waiting for ${state.partnerName ?? 'partner'} to answer...",
              style: const TextStyle(color: Colors.white60, fontSize: 15)),
          const SizedBox(height: 12),
          const Text("Answers will reveal simultaneously for both of you.",
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRevealRecap() {
    final reveal = state.latestReveal;
    if (reveal == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(reveal.isMatch ? Icons.stars : Icons.favorite,
              size: 56, color: reveal.isMatch ? Colors.amberAccent : Colors.pinkAccent),
          const SizedBox(height: 16),
          Text(reveal.isMatch ? "Perfect Match! 🎉" : "Different Perspectives! ✨",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          ...reveal.partnerAnswers.entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    Text(entry.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          Text("Prompt: ${reveal.conversationStarter}",
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontStyle: FontStyle.italic)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onNextRound,
              child: const Text("Next Question →", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGameComplete() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bedtime, size: 64, color: Colors.amberAccent),
            SizedBox(height: 20),
            Text("Bedtime Co-Play Complete", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 12),
            Text("Goodnight! A new personalized game will be generated for you tomorrow.",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}
