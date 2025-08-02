import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../models/answer_model.dart';
import '../utils/constants.dart';
import 'result_screen.dart';

class FollowUpScreen extends StatefulWidget {
  final CaseModel caseModel;
  final Map<String, ClerkingAnswer> clerkingAnswers;
  final Map<String, int> scoreBreakdown;
  final Duration timeSpent;

  const FollowUpScreen({
    Key? key,
    required this.caseModel,
    required this.clerkingAnswers,
    required this.scoreBreakdown,
    required this.timeSpent,
  }) : super(key: key);

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  late List<TextEditingController> _controllers;
  late List<FollowUpAnswer> _answers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnswers();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnswers() {
    _controllers = [];
    _answers = [];
    
    for (int i = 0; i < widget.caseModel.followUpQuestions.length; i++) {
      _controllers.add(TextEditingController());
      _answers.add(FollowUpAnswer(
        questionId: i.toString(),
        answer: '',
        score: 0,
      ));
    }
  }

  void _updateAnswer(int index, String answer) {
    setState(() {
      _answers[index] = FollowUpAnswer(
        questionId: index.toString(),
        answer: answer,
        score: _calculateScore(index, answer),
      );
    });
  }

  int _calculateScore(int questionIndex, String answer) {
    // This is a simplified scoring system
    // In a real app, this would use NLP or predefined answer matching
    if (answer.trim().isEmpty) return 0;
    
    final question = widget.caseModel.followUpQuestions[questionIndex];
    final correctAnswers = widget.caseModel.answers;
    
    // Basic scoring logic - can be enhanced
    if (question.type == 'short_answer') {
      if (answer.trim().length >= 10) return 2;
      if (answer.trim().length >= 5) return 1;
    } else if (question.type == 'list') {
      // Count commas or bullet points as indicators of list items
      int items = answer.split(RegExp(r'[,\n•\-\*]')).where((s) => s.trim().isNotEmpty).length;
      return items.clamp(0, 3);
    }
    
    return answer.trim().isNotEmpty ? 1 : 0;
  }

  int _getTotalFollowUpScore() {
    return _answers.fold(0, (sum, answer) => sum + answer.score);
  }

  int _getMaxFollowUpScore() {
    return widget.caseModel.followUpQuestions.length * 3; // Max 3 points per question
  }

  bool _canSubmit() {
    return _answers.every((answer) => answer.answer.trim().isNotEmpty);
  }

  void _submitAnswers() async {
    if (_isSubmitting || !_canSubmit()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    // Calculate total scores
    int clerkingScore = widget.scoreBreakdown.values.fold(0, (sum, score) => sum + score);
    int followUpScore = _getTotalFollowUpScore();
    int totalScore = clerkingScore + followUpScore;
    
    int maxClerkingScore = widget.clerkingAnswers.values.fold(0, (sum, answer) => sum + answer.getMaxScore());
    int maxFollowUpScore = _getMaxFollowUpScore();
    int maxTotalScore = maxClerkingScore + maxFollowUpScore;

    // Navigate to results
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          caseModel: widget.caseModel,
          clerkingAnswers: widget.clerkingAnswers,
          followUpAnswers: _answers,
          clerkingScore: clerkingScore,
          followUpScore: followUpScore,
          totalScore: totalScore,
          maxScore: maxTotalScore,
          timeSpent: widget.timeSpent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Follow-up Questions',
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.divider.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.caseModel.title,
                            style: AppTextStyles.heading3,
                          ),
                          Text(
                            'Answer the clinical questions below',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_getTotalFollowUpScore()}/${_getMaxFollowUpScore()}',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                        Text(
                          'Follow-up Score',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                LinearProgressIndicator(
                  value: _answers.where((a) => a.answer.isNotEmpty).length / _answers.length,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          
          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: widget.caseModel.followUpQuestions.length,
              itemBuilder: (context, index) {
                final question = widget.caseModel.followUpQuestions[index];
                final answer = _answers[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: answer.answer.isNotEmpty 
                                    ? AppColors.accent.withOpacity(0.1)
                                    : AppColors.divider.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: answer.answer.isNotEmpty 
                                      ? AppColors.accent
                                      : AppColors.divider,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: answer.answer.isNotEmpty 
                                        ? AppColors.accent
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.question,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (question.type == 'list') ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Provide a list of items (separate with commas)',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (answer.score > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingSmall,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                ),
                                child: Text(
                                  '${answer.score} pts',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingMedium),
                        TextField(
                          controller: _controllers[index],
                          maxLines: question.type == 'list' ? 4 : 3,
                          decoration: InputDecoration(
                            hintText: _getHintText(question.type),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.accent, width: 2),
                            ),
                          ),
                          onChanged: (value) => _updateAnswer(index, value),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Submit Button
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.divider.withOpacity(0.5),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _canSubmit() && !_isSubmitting ? _submitAnswers : null,
                  icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Answers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit() 
                        ? AppColors.success 
                        : AppColors.textSecondary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText(String questionType) {
    switch (questionType) {
      case 'short_answer':
        return 'Enter your answer here...';
      case 'list':
        return 'List your answers, separated by commas or new lines...';
      default:
        return 'Enter your answer here...';
    }
  }
}