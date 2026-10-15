import 'package:flutter/material.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/widgets/percentage_bar.dart';
import 'package:learning_setu/widgets/performance_indicator.dart';

/// A card widget displaying a subject summary, including its icon, name,
/// topic count, optional performance level indicator, and animated percentage bar.
class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final double? percentage;
  final PerformanceLevel? level;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    this.percentage,
    this.level,
    this.onTap,
  });

  IconData _resolveSubjectIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
      case 'calculate_rounded':
      case 'math':
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'science':
      case 'science_rounded':
        return Icons.science_rounded;
      case 'menu_book':
      case 'menu_book_rounded':
      case 'book':
      case 'reading':
        return Icons.menu_book_rounded;
      case 'translate':
      case 'translate_rounded':
      case 'language':
      case 'english':
      case 'gujarati':
        return Icons.translate_rounded;
      case 'eco':
      case 'eco_rounded':
      case 'nature':
      case 'environmental_studies':
      case 'evs':
        return Icons.eco_rounded;
      case 'history':
      case 'history_edu':
      case 'history_edu_rounded':
        return Icons.history_edu_rounded;
      case 'palette':
      case 'art':
        return Icons.palette_rounded;
      case 'music_note':
      case 'music':
        return Icons.music_note_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectIcon = _resolveSubjectIcon(subject.iconName);

    final PerformanceLevel? effectiveLevel =
        level ??
        (percentage != null
            ? PerformanceClassification.classify(percentage)
            : null);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.7),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Icon, Subject Title & Topics Count, Performance Indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      subjectIcon,
                      color: theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.getLocalizedName(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${subject.topics.length} ${subject.topics.length == 1 ? "topic" : "topics"}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (effectiveLevel != null)
                    PerformanceIndicator(
                      level: effectiveLevel,
                      percentage: null,
                      size: 12.0,
                    )
                  else if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.6,
                      ),
                      size: 20,
                    ),
                ],
              ),

              // Description if available and concise
              if (subject.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  subject.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Animated Performance Bar if percentage available
              if (percentage != null) ...[
                const SizedBox(height: 14),
                PercentageBar(
                  label: 'Mastery',
                  percentage: percentage!,
                  level: effectiveLevel,
                  height: 6.0,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
