import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../models/answer_model.dart';
import '../widgets/timer_widget.dart';
import '../widgets/input_card.dart';
import '../utils/constants.dart';
import 'followup_screen.dart';

class ClerkingScreen extends StatefulWidget {
  final CaseModel caseModel;
  final Duration timeSpent;
  final GlobalKey<TimerWidgetState> timerKey;

  const ClerkingScreen({
    Key? key,
    required this.caseModel,
    required this.timeSpent,
    required this.timerKey,
  }) : super(key: key);

  @override
  State<ClerkingScreen> createState() => _ClerkingScreenState();
}

class _ClerkingScreenState extends State<ClerkingScreen> {
  late Map<String, ClerkingAnswer> _answers;
  late ScrollController _scrollController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnswers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnswers() {
    _answers = {};
    for (String section in widget.caseModel.getSectionNames()) {
      final items = widget.caseModel.clerkingChecklist[section] ?? [];
      Map<String, bool> checklistItems = {};
      for (String item in items) {
        checklistItems[item] = false;
      }
      
      _answers[section] = ClerkingAnswer(
        section: section,
        checklistItems: checklistItems,
        notes: '',
      );
    }
  }

  void _updateSection(String section, Map<String, bool> checklist) {
    setState(() {
      _answers[section] = ClerkingAnswer(
        section: section,
        checklistItems: checklist,
        notes: _answers[section]?.notes ?? '',
      );
    });
  }

  void _updateNotes(String section, String notes) {
    setState(() {
      _answers[section] = ClerkingAnswer(
        section: section,
        checklistItems: _answers[section]?.checklistItems ?? {},
        notes: notes,
      );
    });
  }

  int _getTotalScore() {
    return _answers.values.fold(0, (sum, answer) => sum + answer.getScore());
  }

  int _getMaxScore() {
    return _answers.values.fold(0, (sum, answer) => sum + answer.getMaxScore());
  }

  double _getCompletionPercentage() {
    int maxScore = _getMaxScore();
    if (maxScore == 0) return 0.0;
    return (_getTotalScore() / maxScore) * 100;
  }

  void _submitClerking() {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    // Calculate scores
    Map<String, int> scoreBreakdown = {};
    for (String section in _answers.keys) {
      scoreBreakdown[section] = _answers[section]!.getScore();
    }

    final timeSpent = widget.timerKey.currentState?.timeSpent ?? Duration.zero;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FollowUpScreen(
          caseModel: widget.caseModel,
          clerkingAnswers: _answers,
          scoreBreakdown: scoreBreakdown,
          timeSpent: timeSpent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completionPercentage = _getCompletionPercentage();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'History Taking',
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () => _showTimerDialog(),
          ),
        ],
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
                            'Complete all sections below',
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
                          '${_getTotalScore()}/${_getMaxScore()}',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${completionPercentage.toStringAsFixed(0)}% Complete',
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
                  value: completionPercentage / 100,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(completionPercentage / 100),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          
          // Clerking Sections
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: widget.caseModel.getSectionNames().length,
              itemBuilder: (context, index) {
                final section = widget.caseModel.getSectionNames()[index];
                final checklistItems = widget.caseModel.clerkingChecklist[section] ?? [];
                final answer = _answers[section]!;
                
                return InputCard(
                  title: _formatSectionTitle(section),
                  checklistItems: checklistItems,
                  selectedItems: answer.checklistItems,
                  notes: answer.notes,
                  onChecklistChanged: (checklist) => _updateSection(section, checklist),
                  onNotesChanged: (notes) => _updateNotes(section, notes),
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
                  onPressed: _isSubmitting ? null : _submitClerking,
                  icon: _isSubmitting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Complete History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: completionPercentage >= 70 
                        ? AppColors.accent 
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

  void _showTimerDialog() {
    final timeSpent = widget.timerKey.currentState?.timeSpent ?? Duration.zero;
    final timeRemaining = widget.timerKey.currentState?.currentSeconds ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timer Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Time Spent'),
              subtitle: Text(_formatDuration(timeSpent)),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Time Remaining'),
              subtitle: Text(_formatTime(timeRemaining)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatSectionTitle(String section) {
    Map<String, String> sectionTitles = {
      'biodata': 'Biodata',
      'presentingComplaint': 'Presenting Complaint',
      'HPC': 'History of Presenting Complaint',
      'reviewOfSystems': 'Review of Systems',
      'PMH': 'Past Medical History',
      'FSH': 'Family & Social History',
      'summary': 'Summary',
    };
    
    return sectionTitles[section] ?? section
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.6) return AppColors.accent;
    if (progress >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}