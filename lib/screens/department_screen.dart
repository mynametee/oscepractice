import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'case_screen.dart';

class DepartmentScreen extends StatefulWidget {
  final Department department;

  const DepartmentScreen({
    Key? key,
    required this.department,
  }) : super(key: key);

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<CaseModel> _cases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    try {
      final cases = await _firestoreService.getCasesByDepartment(widget.department.id);
      
      // If no cases exist, seed some sample cases
      if (cases.isEmpty) {
        await _seedSampleCases();
        final seededCases = await _firestoreService.getCasesByDepartment(widget.department.id);
        setState(() {
          _cases = seededCases;
          _isLoading = false;
        });
      } else {
        setState(() {
          _cases = cases;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _seedSampleCases() async {
    // This is a temporary method to seed sample cases for demonstration
    // In a real app, these would be managed by admins
    if (widget.department.id == 'medicine') {
      // Add a sample medicine case
      // This would typically be done through an admin interface
      // For now, we'll just show a placeholder
    }
  }

  void _navigateToCase(CaseModel caseModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CaseScreen(caseModel: caseModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.department.name,
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'Failed to load cases',
              style: AppTextStyles.heading3.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadCases();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.department.icon,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Text(
              'No Cases Available',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'Cases for ${widget.department.name} will be available soon.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            ElevatedButton.icon(
              onPressed: () => _loadCases(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Department header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Text(
                  widget.department.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.department.name,
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      '${_cases.length} cases available',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Cases list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: _cases.length,
            itemBuilder: (context, index) {
              final caseModel = _cases[index];
              return _CaseCard(
                caseModel: caseModel,
                onTap: () => _navigateToCase(caseModel),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CaseCard extends StatelessWidget {
  final CaseModel caseModel;
  final VoidCallback onTap;

  const _CaseCard({
    required this.caseModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      caseModel.title,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      '${AppConstants.caseDurationMinutes} min',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                caseModel.scenario,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.checklist,
                    label: '${caseModel.getTotalChecklistItems()} items',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  _buildInfoChip(
                    icon: Icons.quiz,
                    label: '${caseModel.followUpQuestions.length} questions',
                    color: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}