/// Domain models for the Couples Co-Play Mobile Client
/// Represents session state, questions, submissions, and synchronized reveals.

enum SessionStatus {
  waitingForPartner,
  roundActive,
  waitingForReveal,
  roundRecap,
  gameComplete,
  disconnected,
}

enum QuestionType {
  choice,
  freeText,
  slider,
}

class QuestionItem {
  final String id;
  final String prompt;
  final QuestionType type;
  final List<String> options;
  final String? followUpPrompt;

  const QuestionItem({
    required this.id,
    required this.prompt,
    required this.type,
    this.options = const [],
    this.followUpPrompt,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    return QuestionItem(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'choice'),
        orElse: () => QuestionType.choice,
      ),
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followUpPrompt: json['follow_up_prompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'type': type.name,
        'options': options,
        'follow_up_prompt': followUpPrompt,
      };
}

class RevealData {
  final int roundIndex;
  final QuestionItem question;
  final Map<String, String> partnerAnswers;
  final bool isMatch;
  final int score;
  final String conversationStarter;

  const RevealData({
    required this.roundIndex,
    required this.question,
    required this.partnerAnswers,
    required this.isMatch,
    required this.score,
    required this.conversationStarter,
  });

  factory RevealData.fromJson(Map<String, dynamic> json) {
    return RevealData(
      roundIndex: json['round_index'] as int,
      question: QuestionItem.fromJson(json['question'] as Map<String, dynamic>),
      partnerAnswers: Map<String, String>.from(json['answers'] as Map),
      isMatch: json['is_match'] as bool? ?? false,
      score: json['compatibility_score'] as int? ?? 50,
      conversationStarter: json['conversation_starter'] as String? ?? '',
    );
  }
}
