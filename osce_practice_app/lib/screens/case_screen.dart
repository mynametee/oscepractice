import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../widgets/timer_widget.dart';
import '../utils/constants.dart';
import 'clerking_screen.dart';

class CaseScreen extends StatefulWidget {
  final CaseModel caseModel;

  const CaseScreen({
    Key? key,
    required this.caseModel,
  }) : super(key: key);

  @override
  State<CaseScreen> createState() => _CaseScreenState();
}

class _CaseScreenState extends State<CaseScreen> {
  bool _hasStarted = false;
  final GlobalKey<TimerWidgetState> _timerKey = GlobalKey<TimerWidgetState>();

  void _startCase() {
    setState(() {
      _hasStarted = true;
    });
    _timerKey.currentState?.start();
  }

  void _navigateToClerking() {
    final timeSpent = _timerKey.currentState?.timeSpent ?? Duration.zero;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ClerkingScreen(
          caseModel: widget.caseModel,
          timeSpent: timeSpent,
          timerKey: _timerKey,
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
          widget.caseModel.title,
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    Text(
                      'OSCE Station Timer',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    TimerWidget(
                      key: _timerKey,
                      onComplete: () {
                        // Auto-navigate to clerking when timer completes
                        _navigateToClerking();
                      },
                      autoStart: false,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Case Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: AppColors.primary,
                          size: AppDimensions.iconSizeMedium,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Text(
                          'Patient Scenario',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        widget.caseModel.scenario,
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Instructions Card
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
                          color: AppColors.accent,
                          size: AppDimensions.iconSizeMedium,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Text(
                          'Instructions',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildInstructionItem(
                      '1. Read the patient scenario carefully',
                      Icons.visibility,
                    ),
                    _buildInstructionItem(
                      '2. Start the timer when you\'re ready to begin',
                      Icons.timer,
                    ),
                    _buildInstructionItem(
                      '3. Complete the history taking within ${AppConstants.caseDurationMinutes} minutes',
                      Icons.schedule,
                    ),
                    _buildInstructionItem(
                      '4. Follow the structured clerking format',
                      Icons.checklist,
                    ),
                    _buildInstructionItem(
                      '5. Answer follow-up questions after completion',
                      Icons.quiz,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingMedium),
            
            // Case Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Case Statistics',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Duration',
                            '${AppConstants.caseDurationMinutes} min',
                            Icons.timer,
                            AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Checklist Items',
                            '${widget.caseModel.getTotalChecklistItems()}',
                            Icons.checklist,
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
                            'Sections',
                            '${widget.caseModel.getSectionNames().length}',
                            Icons.format_list_numbered,
                            AppColors.warning,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Follow-up Qs',
                            '${widget.caseModel.followUpQuestions.length}',
                            Icons.quiz,
                            AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            // Action Buttons
            if (!_hasStarted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startCase,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateToClerking,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Begin History Taking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: AppDimensions.paddingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSizeSmall,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppDimensions.iconSizeMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
}