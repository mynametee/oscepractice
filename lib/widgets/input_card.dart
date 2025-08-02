import 'package:flutter/material.dart';
import '../utils/constants.dart';

class InputCard extends StatefulWidget {
  final String title;
  final List<String> checklistItems;
  final Map<String, bool> selectedItems;
  final String? notes;
  final Function(Map<String, bool>) onChecklistChanged;
  final Function(String) onNotesChanged;
  final bool isExpanded;

  const InputCard({
    Key? key,
    required this.title,
    required this.checklistItems,
    required this.selectedItems,
    this.notes,
    required this.onChecklistChanged,
    required this.onNotesChanged,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  State<InputCard> createState() => _InputCardState();
}

class _InputCardState extends State<InputCard> {
  late TextEditingController _notesController;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.notes ?? '');
    _isExpanded = widget.isExpanded;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleItem(String item, bool value) {
    Map<String, bool> updatedItems = Map.from(widget.selectedItems);
    updatedItems[item] = value;
    widget.onChecklistChanged(updatedItems);
  }

  int _getCompletedCount() {
    return widget.selectedItems.values.where((selected) => selected).length;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _getCompletedCount();
    final totalCount = widget.checklistItems.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusMedium),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: _isExpanded 
                    ? AppColors.primary.withOpacity(0.05)
                    : AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(AppDimensions.radiusMedium),
                  bottom: _isExpanded 
                      ? Radius.zero 
                      : const Radius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.divider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(progress),
                                ),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingSmall),
                            Text(
                              '$completedCount/$totalCount',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _getProgressColor(progress),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checklist items
                  ...widget.checklistItems.map((item) {
                    final isSelected = widget.selectedItems[item] ?? false;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                      child: InkWell(
                        onTap: () => _toggleItem(item, !isSelected),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                            vertical: AppDimensions.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.accent.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.accent
                                  : AppColors.divider,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.accent 
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.accent 
                                        : AppColors.divider,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: AppColors.surface,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppDimensions.paddingMedium),
                              Expanded(
                                child: Text(
                                  _formatChecklistItem(item),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isSelected 
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected 
                                        ? FontWeight.w500 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // Notes section
                  Text(
                    'Additional Notes',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add any additional observations or details...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    ),
                    style: AppTextStyles.bodyMedium,
                    onChanged: widget.onNotesChanged,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.5) return AppColors.accent;
    if (progress >= 0.3) return AppColors.warning;
    return AppColors.error;
  }

  String _formatChecklistItem(String item) {
    // Convert snake_case or camelCase to readable format
    return item
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}