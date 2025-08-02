class ClerkingAnswer {
  final String section;
  final Map<String, bool> checklistItems;
  final String? notes;

  ClerkingAnswer({
    required this.section,
    required this.checklistItems,
    this.notes,
  });

  factory ClerkingAnswer.fromMap(Map<String, dynamic> map) {
    return ClerkingAnswer(
      section: map['section'] ?? '',
      checklistItems: Map<String, bool>.from(map['checklistItems'] ?? {}),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'section': section,
      'checklistItems': checklistItems,
      'notes': notes,
    };
  }

  int getScore() {
    return checklistItems.values.where((checked) => checked).length;
  }

  int getMaxScore() {
    return checklistItems.length;
  }
}

class FollowUpAnswer {
  final String questionId;
  final String answer;
  final int score;

  FollowUpAnswer({
    required this.questionId,
    required this.answer,
    required this.score,
  });

  factory FollowUpAnswer.fromMap(Map<String, dynamic> map) {
    return FollowUpAnswer(
      questionId: map['questionId'] ?? '',
      answer: map['answer'] ?? '',
      score: map['score'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'answer': answer,
      'score': score,
    };
  }
}

class AttemptModel {
  final String id;
  final String userId;
  final String caseId;
  final DateTime timestamp;
  final Map<String, ClerkingAnswer> clerkingAnswers;
  final List<FollowUpAnswer> followUpAnswers;
  final Map<String, int> scoreBreakdown;
  final int totalScore;
  final int maxScore;
  final Duration timeSpent;
  final bool completed;

  AttemptModel({
    required this.id,
    required this.userId,
    required this.caseId,
    required this.timestamp,
    required this.clerkingAnswers,
    required this.followUpAnswers,
    required this.scoreBreakdown,
    required this.totalScore,
    required this.maxScore,
    required this.timeSpent,
    required this.completed,
  });

  factory AttemptModel.fromMap(Map<String, dynamic> map, String id) {
    return AttemptModel(
      id: id,
      userId: map['userId'] ?? '',
      caseId: map['caseId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      clerkingAnswers: Map<String, ClerkingAnswer>.from(
        (map['clerkingAnswers'] ?? {}).map(
          (key, value) => MapEntry(key, ClerkingAnswer.fromMap(value)),
        ),
      ),
      followUpAnswers: (map['followUpAnswers'] as List<dynamic>? ?? [])
          .map((item) => FollowUpAnswer.fromMap(item))
          .toList(),
      scoreBreakdown: Map<String, int>.from(map['scoreBreakdown'] ?? {}),
      totalScore: map['totalScore'] ?? 0,
      maxScore: map['maxScore'] ?? 0,
      timeSpent: Duration(seconds: map['timeSpentSeconds'] ?? 0),
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'caseId': caseId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'clerkingAnswers': clerkingAnswers.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'followUpAnswers': followUpAnswers.map((answer) => answer.toMap()).toList(),
      'scoreBreakdown': scoreBreakdown,
      'totalScore': totalScore,
      'maxScore': maxScore,
      'timeSpentSeconds': timeSpent.inSeconds,
      'completed': completed,
    };
  }

  double getPercentageScore() {
    if (maxScore == 0) return 0.0;
    return (totalScore / maxScore) * 100;
  }

  String getGrade() {
    final percentage = getPercentageScore();
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }
}