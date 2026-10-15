import 'package:flutter/material.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/performance_model.dart';

/// A horizontal percentage progress bar with label, animated fill,
/// and percentage readout, with color-coding support from [PerformanceLevel].
class PercentageBar extends StatelessWidget {
  final String label;
  final double percentage;
  final Color? color;
  final PerformanceLevel? level;
  final double height;

  const PercentageBar({
    super.key,
    required this.label,
    required this.percentage,
    this.color,
    this.level,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    final progressFactor = clampedPercentage / 100.0;

    // Resolve color priority: direct color > level color > classified percentage color
    final Color effectiveColor =
        color ??
        (level != null
            ? AppColors.getPerformanceColor(level!)
            : AppColors.getPerformanceColor(
                PerformanceClassification.classify(percentage),
              ));

    final String formattedPercentage =
        clampedPercentage.truncateToDouble() == clampedPercentage
        ? '${clampedPercentage.toInt()}%'
        : '${clampedPercentage.toStringAsFixed(1)}%';

    return Semantics(
      label: '$label: $formattedPercentage',
      value: formattedPercentage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedPercentage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progressFactor),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, animatedFactor, child) {
                return Stack(
                  children: [
                    // Background track
                    Container(
                      height: height,
                      width: double.infinity,
                      color: effectiveColor.withOpacity(0.15),
                    ),
                    // Animated Fill
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: animatedFactor,
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: effectiveColor,
                          borderRadius: BorderRadius.circular(height / 2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
