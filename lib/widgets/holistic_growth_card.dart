import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/models/holistic_evaluation_model.dart';
import 'package:learning_setu/providers/holistic_provider.dart';

class HolisticGrowthCard extends StatelessWidget {
  final String studentId;
  final bool isTeacher;
  final String? teacherName;

  const HolisticGrowthCard({
    super.key,
    required this.studentId,
    this.isTeacher = false,
    this.teacherName,
  });

  IconData _getBadgeIcon(String iconName) {
    switch (iconName) {
      case 'track_changes_outlined':
      case 'fitness_center':
        return Icons.track_changes_outlined;
      case 'lightbulb_outline':
        return Icons.lightbulb_outline;
      case 'handshake_outlined':
        return Icons.handshake_outlined;
      case 'palette_outlined':
        return Icons.palette_outlined;
      case 'sports_volleyball_outlined':
      case 'sports_soccer':
        return Icons.sports_volleyball_outlined;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.stars_rounded;
    }
  }

  Color _getBadgeColor(String badgeKey) {
    switch (badgeKey) {
      case 'high_effort':
        return const Color(0xFFE65100);
      case 'curious_mind':
        return const Color(0xFF7B1FA2);
      case 'team_player':
        return const Color(0xFF00796B);
      case 'creative_thinker':
        return const Color(0xFFC2185B);
      case 'active_sport':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Color _getBadgeBg(String badgeKey) {
    switch (badgeKey) {
      case 'high_effort':
        return const Color(0xFFFFF3E0);
      case 'curious_mind':
        return const Color(0xFFF3E5F5);
      case 'team_player':
        return const Color(0xFFE0F2F1);
      case 'creative_thinker':
        return const Color(0xFFFCE4EC);
      case 'active_sport':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    HolisticProvider? holisticProv;
    try {
      holisticProv = Provider.of<HolisticProvider?>(context, listen: true);
    } catch (_) {}

    final evaluation = holisticProv?.getEvaluationForStudent(studentId) ??
        HolisticEvaluationModel(
          studentId: studentId,
          practiceGrit: 84.0,
          learningConsistency: 88.0,
          engagementCuriosity: 80.0,
          teamworkEmpathy: 85.0,
          coCurricular: 80.0,
          updatedAt: DateTime.now(),
        );
    final composite = evaluation.compositeScore;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGu
                            ? '૩૬૦° સર્વાંગી વિકાસ અને ચારિત્ર્ય'
                            : '360° Holistic Growth & Character',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isGu
                            ? 'NEP 2020 • માર્ક્સ સિવાય વાસ્તવિક મૂલ્યાંકન'
                            : 'NEP 2020 • Multi-dimensional Growth Assessment',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Composite score badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: composite >= 80
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: composite >= 80
                          ? const Color(0xFF81C784)
                          : const Color(0xFFFFD54F),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: composite >= 80
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFF57F17),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${composite.toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: composite >= 80
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFF57F17),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isGu
                          ? 'સ્થિતિ: ${evaluation.getLocalizedStatus(isGu)} (આપમેળે ગણતરી)'
                          : 'Status: ${evaluation.getLocalizedStatus(isGu)} (Auto-Calculated)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Trait Progress Bars
            _buildTraitRow(
              title: isGu ? 'ખંત અને મહાવરો (Practice Grit)' : 'Practice Grit & Effort',
              subtitle: isGu
                  ? 'ઉપચારાત્મક કાર્ય અને પ્રશ્નોત્તરી પૂર્ણતા'
                  : 'Computed from completed remedials & practice',
              score: evaluation.practiceGrit,
              icon: Icons.track_changes_outlined,
              color: const Color(0xFFE65100),
            ),
            const SizedBox(height: 10),
            _buildTraitRow(
              title: isGu ? 'નિયમિતતા (Learning Consistency)' : 'Learning Consistency',
              subtitle: isGu
                  ? 'હાજરી અને દૈનિક મૂલ્યાંકન સક્રિયતા'
                  : 'Computed from attendance & daily regularity',
              score: evaluation.learningConsistency,
              icon: Icons.schedule,
              color: const Color(0xFF1565C0),
            ),
            const SizedBox(height: 10),
            _buildTraitRow(
              title: isGu ? 'જિજ્ઞાસુ વૃત્તિ (Classroom Curiosity)' : 'Classroom Curiosity',
              subtitle: isGu
                  ? 'પ્રશ્નો પૂછવાની અને નવું શીખવાની ધગશ'
                  : 'Questioning attitude & inquiry mindset',
              score: evaluation.engagementCuriosity,
              icon: Icons.lightbulb_outline,
              color: const Color(0xFF7B1FA2),
            ),
            const SizedBox(height: 10),
            _buildTraitRow(
              title: isGu ? 'ટીમવર્ક અને સહકાર (Teamwork & Empathy)' : 'Teamwork & Empathy',
              subtitle: isGu
                  ? 'સહપાઠીઓને મદદ અને જૂથ પ્રવૃત્તિ'
                  : 'Peer support, sharing & group collaboration',
              score: evaluation.teamworkEmpathy,
              icon: Icons.handshake_outlined,
              color: const Color(0xFF00796B),
            ),
            const SizedBox(height: 10),
            _buildTraitRow(
              title: isGu ? 'સહ-અભ્યાસિક અને રમતગમત (Co-Curricular)' : 'Co-Curricular & Sports',
              subtitle: isGu
                  ? 'કલા, રમતગમત અને સ્વચ્છતા પ્રવૃત્તિઓ'
                  : 'Arts, physical well-being & sports participation',
              score: evaluation.coCurricular,
              icon: Icons.sports_volleyball_outlined,
              color: const Color(0xFFC2185B),
            ),

            const SizedBox(height: 20),

            // Positive Character Shout-Out Badges Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium, size: 20, color: Color(0xFFF57F17)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isGu ? 'સકારાત્મક પ્રોત્સાહન બેજ' : 'Character Shout-Out Badges',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isTeacher)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: Text(
                      isGu ? '+ બેજ આપો' : '+ Award Badge',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showAwardBadgeDialog(
                      context,
                      isGu,
                      holisticProv,
                      teacherName ?? (isGu ? 'શિક્ષક' : 'Teacher'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (evaluation.badges.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Center(
                  child: Text(
                    isGu
                        ? 'વિદ્યાર્થીને પ્રોત્સાહિત કરવા શિક્ષક દ્વારા ૧-ક્લિક બેજ એનાયત કરવામાં આવશે.'
                        : 'No badges awarded yet. Teacher can award 1-tap positive shout-outs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: evaluation.badges.map((b) {
                  final color = _getBadgeColor(b.badgeKey);
                  final bg = _getBadgeBg(b.badgeKey);
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showBadgeDetailSheet(context, b, isGu),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getBadgeIcon(b.iconName), size: 16, color: color),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isGu ? b.titleGu : b.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.info_outline, size: 12, color: color.withAlpha(150)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Teacher Notes
            if (evaluation.teacherNotes != null &&
                evaluation.teacherNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDCEDC8)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote, size: 20, color: Color(0xFF558B2F)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGu ? 'શિક્ષકનું અવલોકન નોંધ:' : "Teacher's Observation Note:",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF33691E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            evaluation.teacherNotes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1B5E20),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTraitRow({
    required String title,
    required String subtitle,
    required double score,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${score.toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (score.clamp(0.0, 100.0)) / 100.0,
            minHeight: 6,
            backgroundColor: color.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  void _showBadgeDetailSheet(BuildContext context, CharacterBadge badge, bool isGu) {
    final dateFormat = DateFormat('dd MMM yyyy');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getBadgeBg(badge.badgeKey),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getBadgeIcon(badge.iconName),
                      size: 28,
                      color: _getBadgeColor(badge.badgeKey),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGu ? badge.titleGu : badge.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isGu ? 'શિક્ષક તરફથી પ્રોત્સાહન' : 'Teacher Shout-Out Badge',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGu ? 'શિક્ષકનું મંતવ્ય:' : "Teacher's Recognition:",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGu
                          ? 'વિદ્યાર્થીએ વર્ગખંડમાં ઉત્કૃષ્ટ ઉત્સાહ, સદ્ભાવના અને ખંત દર્શાવ્યો છે.'
                          : 'Demonstrated outstanding positive attitude and character in classroom activities.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isGu ? 'એનાયત કરનાર:' : 'Awarded by:'} ${badge.awardedBy}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  Text(
                    dateFormat.format(badge.awardedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    isGu ? 'બંધ કરો' : 'Close',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAwardBadgeDialog(
    BuildContext context,
    bool isGu,
    HolisticProvider? prov,
    String currentTeacher,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String? selectedKey = CharacterBadge.availableTemplates.first['key'];
        final noteController = TextEditingController();

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium, color: Color(0xFFF57F17), size: 26),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isGu
                                ? '૧-ક્લિક સકારાત્મક પ્રોત્સાહન બેજ'
                                : '1-Tap Character Shout-Out Badge',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isGu
                          ? 'વિદ્યાર્થીના ચારિત્ર્ય અને પ્રયત્નને બિરદાવવા ૧ ક્લિકમાં બેજ આપો:'
                          : 'Award instant positive recognition for character and daily effort:',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 14),

                    // Grid/List of badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CharacterBadge.availableTemplates.map((t) {
                        final key = t['key'] ?? '';
                        final isSelected = selectedKey == key;
                        final color = _getBadgeColor(key);
                        final bg = _getBadgeBg(key);

                        return ChoiceChip(
                          selected: isSelected,
                          avatar: Icon(
                            _getBadgeIcon(t['icon'] ?? ''),
                            size: 16,
                            color: isSelected ? Colors.white : color,
                          ),
                          label: Text(
                            isGu ? (t['titleGu'] ?? '') : (t['title'] ?? ''),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selectedColor: color,
                          backgroundColor: bg,
                          side: BorderSide(
                            color: isSelected ? color : color.withAlpha(60),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                selectedKey = key;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: isGu
                            ? 'પ્રોત્સાહક નોંધ (વૈકલ્પિક)'
                            : 'Short Encouragement Note (Optional)',
                        hintText: isGu
                            ? 'દા.ત., આજે ગણિતના પ્રશ્નોમાં અદભુત ખંત દર્શાવ્યો.'
                            : 'e.g., Showed extraordinary grit solving word problems today.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(modalCtx),
                            child: Text(isGu ? 'રદ કરો' : 'Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.star, size: 16, color: Colors.white),
                            label: Text(
                              isGu ? 'બેજ એનાયત કરો' : 'Award Badge',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (selectedKey != null) {
                                await prov?.awardBadge(
                                  studentId: studentId,
                                  badgeKey: selectedKey!,
                                  teacherName: currentTeacher,
                                  note: noteController.text.trim().isNotEmpty
                                      ? noteController.text.trim()
                                      : null,
                                );
                                if (modalCtx.mounted) {
                                  Navigator.pop(modalCtx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isGu
                                            ? 'સફળતાપૂર્વક બેજ એનાયત કરવામાં આવ્યો!'
                                            : 'Badge successfully awarded!',
                                      ),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
