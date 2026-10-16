import 'package:flutter/material.dart';
import 'package:learning_setu/models/user_model.dart';

/// A responsive, non-overflowing badge displaying assigned teacher details.
/// Designed for use across Principal's views (Results, Subjects, Student Details, Dashboard).
class AssignedTeacherBadge extends StatelessWidget {
  final UserModel teacher;
  final String? labelPrefix; // e.g. "Subject Teacher", "Class Teacher", "Teacher"
  final bool showPhone;
  final bool compact;
  final Color? backgroundColor;
  final Color? textColor;

  const AssignedTeacherBadge({
    super.key,
    required this.teacher,
    this.labelPrefix,
    this.showPhone = false,
    this.compact = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    final prefix = labelPrefix ?? (isGu ? 'શિક્ષક' : 'Teacher');
    final bg = backgroundColor ?? Colors.indigo.shade50.withOpacity(0.85);
    final fg = textColor ?? Colors.indigo.shade900;
    final border = Colors.indigo.shade200;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge_outlined, size: 12, color: fg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$prefix: ${teacher.name}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final hasPhone = showPhone && teacher.phone.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: hasPhone
                      ? (constraints.maxWidth > 220 ? constraints.maxWidth - 120 : constraints.maxWidth)
                      : constraints.maxWidth,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, size: 14, color: fg),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '$prefix: ${teacher.name}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: fg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasPhone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: border.withOpacity(0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_rounded, size: 11, color: fg),
                      const SizedBox(width: 3),
                      Text(
                        teacher.phone,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
