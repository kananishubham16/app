import 'package:flutter/material.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';

/// A card widget for displaying a student in list or grid views,
/// showing their avatar with initials, full name, enrollment ID, class/section,
/// and optional performance level indicator.
class StudentCard extends StatelessWidget {
  final StudentModel student;
  final PerformanceLevel? performanceLevel;
  final double? percentage;
  final bool isSelected;
  final VoidCallback? onTap;

  const StudentCard({
    super.key,
    required this.student,
    this.performanceLevel,
    this.percentage,
    this.isSelected = false,
    this.onTap,
  });

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarBackgroundColor(String name, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      const Color(0xFF5E35B1),
      const Color(0xFF3949AB),
      const Color(0xFF00897B),
      const Color(0xFFD81B60),
    ];
    final int hash = name.codeUnits.fold(0, (acc, item) => acc + item);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = _getAvatarBackgroundColor(
      student.name,
      theme.colorScheme,
    );

    final PerformanceLevel? effectiveLevel =
        performanceLevel ??
        (percentage != null
            ? PerformanceClassification.classify(percentage)
            : null);

    return Card(
      elevation: isSelected ? 2 : 1,
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.25)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withOpacity(0.7),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              // Avatar with Student Initials
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColor.withOpacity(0.15),
                child: Text(
                  _getInitials(student.name),
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name, ID, and Class Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: ${student.studentId} • Class ${student.className}-${student.section}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Optional Performance Indicator or Selection Mark
              if (effectiveLevel != null) ...[
                const SizedBox(width: 8),
                PerformanceIndicator(
                  level: effectiveLevel,
                  percentage: percentage,
                  size: 12.0,
                  showLabel: true,
                ),
              ],

              if (isSelected && effectiveLevel == null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
