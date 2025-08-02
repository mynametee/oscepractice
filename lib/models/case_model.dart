class Department {
  final String id;
  final String name;
  final String icon;

  Department({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Department.fromMap(Map<String, dynamic> map, String id) {
    return Department(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '🏥',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}

class FollowUpQuestion {
  final String type;
  final String question;
  final List<String>? options;

  FollowUpQuestion({
    required this.type,
    required this.question,
    this.options,
  });

  factory FollowUpQuestion.fromMap(Map<String, dynamic> map) {
    return FollowUpQuestion(
      type: map['type'] ?? '',
      question: map['question'] ?? '',
      options: map['options'] != null 
          ? List<String>.from(map['options']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'question': question,
      'options': options,
    };
  }
}

class CaseModel {
  final String id;
  final String departmentId;
  final String title;
  final String scenario;
  final Map<String, List<String>> clerkingChecklist;
  final List<FollowUpQuestion> followUpQuestions;
  final Map<String, dynamic> answers;
  final int maxScore;

  CaseModel({
    required this.id,
    required this.departmentId,
    required this.title,
    required this.scenario,
    required this.clerkingChecklist,
    required this.followUpQuestions,
    required this.answers,
    required this.maxScore,
  });

  factory CaseModel.fromMap(Map<String, dynamic> map, String id) {
    return CaseModel(
      id: id,
      departmentId: map['departmentId'] ?? '',
      title: map['title'] ?? '',
      scenario: map['scenario'] ?? '',
      clerkingChecklist: Map<String, List<String>>.from(
        (map['clerkingChecklist'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      followUpQuestions: (map['followUpQuestions'] as List<dynamic>? ?? [])
          .map((item) => FollowUpQuestion.fromMap(item))
          .toList(),
      answers: Map<String, dynamic>.from(map['answers'] ?? {}),
      maxScore: map['maxScore'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'departmentId': departmentId,
      'title': title,
      'scenario': scenario,
      'clerkingChecklist': clerkingChecklist,
      'followUpQuestions': followUpQuestions.map((q) => q.toMap()).toList(),
      'answers': answers,
      'maxScore': maxScore,
    };
  }

  int getTotalChecklistItems() {
    return clerkingChecklist.values
        .fold(0, (sum, items) => sum + items.length);
  }

  List<String> getSectionNames() {
    return clerkingChecklist.keys.toList();
  }
}