import 'package:flutter/material.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/performance_model.dart';

/// A reusable widget that displays a student's or subject's performance level
/// with standard color coding, icon, label, and optional percentage badge.
class PerformanceIndicator extends StatelessWidget {
  final PerformanceLevel level;
  final double? percentage;
  final bool showLabel;
  final bool showIcon;
  final double size;

  const PerformanceIndicator({
    super.key,
    required this.level,
    this.percentage,
    this.showLabel = true,
    this.showIcon = true,
    this.size = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.getPerformanceColor(level);
    final IconData icon = AppColors.getPerformanceIcon(level);
    final l10n = AppLocalizations.of(context);
    String label = PerformanceClassification.label(level);
    if (l10n != null) {
      switch (level) {
        case PerformanceLevel.weak:
          label = l10n.weak;
          break;
        case PerformanceLevel.average:
          label = l10n.average;
          break;
        case PerformanceLevel.strong:
          label = l10n.strong;
          break;
        case PerformanceLevel.notAssessed:
          label = l10n.notAssessed;
          break;
      }
    }

    final String percentageText = percentage != null
        ? '${percentage!.round()}%'
        : '';

    final String fullSemanticLabel = percentage != null
        ? '$label: $percentageText'
        : label;

    final double horizontalPadding = (size * 0.55).clamp(6.0, 14.0);
    final double verticalPadding = (size * 0.28).clamp(3.0, 8.0);
    final double iconSize = (size * 1.15).clamp(14.0, 24.0);
    final double fontSize = size.clamp(10.0, 20.0);

    return Semantics(
      label: 'Performance level $fullSemanticLabel',
      child: Tooltip(
        message: fullSemanticLabel,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(size * 0.6),
            border: Border.all(color: color.withOpacity(0.35), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showIcon) ...[
                Icon(icon, size: iconSize, color: color),
                if (showLabel || percentage != null)
                  SizedBox(width: (size * 0.35).clamp(4.0, 8.0)),
              ],
              if (showLabel)
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              if (percentage != null) ...[
                if (showLabel)
                  Text(
                    ' ($percentageText)',
                    style: TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Text(
                    percentageText,
                    style: TextStyle(
                      color: color,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
