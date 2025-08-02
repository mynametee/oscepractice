import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../models/answer_model.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final CaseModel caseModel;
  final Map<String, ClerkingAnswer> clerkingAnswers;
  final List<FollowUpAnswer> followUpAnswers;
  final int clerkingScore;
  final int followUpScore;
  final int totalScore;
  final int maxScore;
  final Duration timeSpent;

  const ResultScreen({
    Key? key,
    required this.caseModel,
    required this.clerkingAnswers,
    required this.followUpAnswers,
    required this.clerkingScore,
    required this.followUpScore,
    required this.totalScore,
    required this.maxScore,
    required this.timeSpent,
  }) : super(key: key);

  double get percentageScore => maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0;

  String get grade {
    if (percentageScore >= 80) return 'A';
    if (percentageScore >= 70) return 'B';
    if (percentageScore >= 60) return 'C';
    if (percentageScore >= 50) return 'D';
    return 'F';
  }

  Color get gradeColor {
    if (percentageScore >= 80) return AppColors.success;
    if (percentageScore >= 70) return AppColors.accent;
    if (percentageScore >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Results',
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _navigateToHome(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            // Overall Score Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: gradeColor, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              grade,
                              style: AppTextStyles.heading1.copyWith(
                                color: gradeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingLarge),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Score',
                                style: AppTextStyles.heading2,
                              ),
                              Text(
                                '$totalScore / $maxScore points',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${percentageScore.toStringAsFixed(1)}%',
                                style: AppTextStyles.heading3.copyWith(
                                  color: gradeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    LinearProgressIndicator(
                      value: percentageScore / 100,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Time and Performance Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Summary',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Time Spent',
                            _formatDuration(timeSpent),
                            Icons.timer,
                            AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Case Type',
                            caseModel.title,
                            Icons.assignment,
                            AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Clerking',
                            '$clerkingScore pts',
                            Icons.checklist,
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Follow-up',
                            '$followUpScore pts',
                            Icons.quiz,
                            AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Section Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Section Breakdown',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    ...clerkingAnswers.entries.map((entry) {
                      final section = entry.key;
                      final answer = entry.value;
                      final score = answer.getScore();
                      final maxSectionScore = answer.getMaxScore();
                      final sectionPercentage = maxSectionScore > 0 ? (score / maxSectionScore) * 100 : 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatSectionTitle(section),
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$score/$maxSectionScore',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: sectionPercentage / 100,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getSectionColor(sectionPercentage),
                              ),
                              minHeight: 4,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Detailed Feedback
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Feedback',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildFeedbackSection(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Missed Items
            if (_getMissedItems().isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: AppDimensions.iconSizeMedium,
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          Text(
                            'Areas for Improvement',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      ..._getMissedItems().map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            Expanded(
                              child: Text(
                                item,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _retryCase(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToHome(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppDimensions.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppDimensions.iconSizeMedium,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    String feedback = '';
    
    if (percentageScore >= 80) {
      feedback = 'Excellent work! You demonstrated strong clinical reasoning and comprehensive history-taking skills.';
    } else if (percentageScore >= 70) {
      feedback = 'Good performance! You covered most essential areas with some minor gaps to address.';
    } else if (percentageScore >= 60) {
      feedback = 'Satisfactory attempt. Focus on improving completeness and systematic approach.';
    } else {
      feedback = 'Needs improvement. Review the fundamentals of history taking and practice more cases.';
    }
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: gradeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: gradeColor.withOpacity(0.3)),
          ),
          child: Text(
            feedback,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  List<String> _getMissedItems() {
    List<String> missed = [];
    
    for (var entry in clerkingAnswers.entries) {
      final section = entry.key;
      final answer = entry.value;
      
      for (var itemEntry in answer.checklistItems.entries) {
        if (!itemEntry.value) {
          missed.add('${_formatSectionTitle(section)}: ${_formatChecklistItem(itemEntry.key)}');
        }
      }
    }
    
    return missed;
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

  String _formatChecklistItem(String item) {
    return item
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Color _getSectionColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.accent;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _retryCase(BuildContext context) {
    // Navigate back to case screen for retry
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }
}