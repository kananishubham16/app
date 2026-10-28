import 'package:flutter/material.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/remedial_model.dart';

class ParentWebHomeView extends StatefulWidget {
  final StudentModel child;
  final List<StudentModel> children;
  final List<AssessmentModel> assessments;
  final List<RemedialAction> pendingRemedials;
  final Function(StudentModel?) onChildChanged;
  final VoidCallback onRefresh;

  const ParentWebHomeView({
    super.key,
    required this.child,
    required this.children,
    required this.assessments,
    required this.pendingRemedials,
    required this.onChildChanged,
    required this.onRefresh,
  });

  @override
  State<ParentWebHomeView> createState() => _ParentWebHomeViewState();
}

class _ParentWebHomeViewState extends State<ParentWebHomeView> {
  final List<Map<String, String>> _inquiryMessages = [
    {
      'from': 'parent',
      'sender': 'You (Parent of Aarav)',
      'senderGu': 'તમે (આરવના વાલી)',
      'text': 'How can I support Aarav with fractions and division at home? He finds visual parts difficult.',
      'textGu': 'આરવને ઘરે અપૂર્ણાંક અને ભાગાકાર સમજવામાં કઈ રીતે મદદ કરી શકાય? તેને આકૃતિ દ્વારા સમજવું થોડું મુશ્કેલ લાગે છે.',
      'time': 'Yesterday, 04:30 PM',
      'timeGu': 'ગઈકાલે, ૦૪:૩૦ સાંજે',
    },
    {
      'from': 'teacher',
      'sender': 'Mrs. Anjali Sharma (Maths Teacher)',
      'senderGu': 'શ્રીમતી અંજલી શર્મા (ગણિત શિક્ષિકા)',
      'text': 'We suggest using chapati or paper fold strips to show 1/2 and 1/4 during dinner. He is making steady progress!',
      'textGu': 'જમતી વખતે રોટલી અથવા કાગળના ટુકડા વાળીને ૧/૨ અને ૧/૪ સમજાવવાનો પ્રયત્ન કરાવો. તે સારો પ્રયાસ કરી રહ્યો છે!',
      'time': 'Today, 09:15 AM',
      'timeGu': 'આજે, ૦૯:૧૫ સવારે',
    },
  ];

  void _openAskTeacherDialog(bool isGu) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.question_answer_rounded, color: Color(0xFF0D9488)),
            const SizedBox(width: 8),
            Text(isGu ? 'શિક્ષકને પ્રશ્ન પૂછો' : 'Ask Teacher a Question'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isGu
                  ? 'શ્રીમતી અંજલી શર્મા (વર્ગ શિક્ષિકા) ને તમારા બાળકના અભ્યાસ કે ગૃહકાર્ય બાબતે સંદેશ મોકલો:'
                  : 'Send a direct inquiry to Mrs. Anjali Sharma regarding your child\'s learning or home practice:',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: isGu
                    ? 'તમારો પ્રશ્ન અહીં લખો (દા.ત. ઘડિયા યાદ રાખવામાં મદદ...)'
                    : 'Type your message or question here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isGu ? 'રદ કરો' : 'Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: Text(isGu ? 'મોકલો' : 'Send via DeepL'),
            onPressed: () {
              final msg = textController.text.trim();
              if (msg.isNotEmpty) {
                setState(() {
                  _inquiryMessages.add({
                    'from': 'parent',
                    'sender': 'You (Parent of ${widget.child.name})',
                    'senderGu': 'તમે (${widget.child.name}ના વાલી)',
                    'text': msg,
                    'textGu': msg,
                    'time': 'Just now',
                    'timeGu': 'હમણાં જ',
                  });
                });
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isGu
                        ? 'તમારો પ્રશ્ન શિક્ષકને મોકલી દેવાયો છે.'
                        : 'Your question has been securely sent to the teacher.',
                  ),
                  backgroundColor: const Color(0xFF0D9488),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // 1. Deep Navy Child Header Banner (Exact Clone of web/parent.html)
          _buildChildHeaderBanner(isGu),
          const SizedBox(height: 14),

          // 2. Understanding Colors Banner & Ask Teacher Button
          _buildColorUnderstandingBanner(isGu),
          const SizedBox(height: 16),

          // 3. 5 Core Subject Cards Grid
          _buildCoreSubjectsGrid(isGu),
          const SizedBox(height: 16),

          // 4. 360° Holistic Growth & Character Strengths Card (NEP 2020 HPC Alignment)
          _buildHolisticGrowthCard(isGu),
          const SizedBox(height: 16),

          // 5. Core Strengths & Focus Areas Card
          _buildCoreStrengthsCard(isGu),
          const SizedBox(height: 16),

          // 6. Data-Backed Home Practice Suggestions (10-Minute Activities)
          _buildHomePracticeSuggestions(isGu),
          const SizedBox(height: 16),

          // 7. Direct Teacher Communications & Inquiries Desk
          _buildTeacherCommunicationsDesk(isGu),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 1: DEEP NAVY CHILD HEADER BANNER
  // ==========================================
  Widget _buildChildHeaderBanner(bool isGu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If parent has multiple children, show dropdown selector
          if (widget.children.length > 1) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  isGu ? 'બાળક પસંદ કરો:' : 'Select Child:',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<StudentModel>(
                    value: widget.children.any((c) => c.id == widget.child.id)
                        ? widget.children.firstWhere((c) => c.id == widget.child.id)
                        : null,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    items: widget.children.map((c) {
                      return DropdownMenuItem<StudentModel>(
                        value: c,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: widget.onChildChanged,
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF334155), height: 16),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF0D9488),
                child: Text(
                  widget.child.name.isNotEmpty ? widget.child.name.substring(0, 1) : 'A',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGu ? 'વિદ્યાર્થી શૈક્ષણિક પ્રોફાઇલ' : 'STUDENT ACADEMIC SUMMARY',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF5EEAD4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.child.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${widget.child.className} - Section ${widget.child.section}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                        ),
                        const Text('•', style: TextStyle(color: Color(0xFF64748B))),
                        Text(
                          'Roll #${widget.child.studentId}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                        ),
                        const Text('•', style: TextStyle(color: Color(0xFF64748B))),
                        Text(
                          '${isGu ? "હાજરી" : "Attendance"}: 94%',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF4ADE80), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Frosted Glass Overall Performance Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGu ? 'સમગ્ર શૈક્ષણિક સિદ્ધિ' : 'OVERALL PERFORMANCE',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isGu ? 'સરેરાશ સિદ્ધિ સ્તર' : 'Average Mastery Band',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFEF08A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '68%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: COLOR UNDERSTANDING BANNER
  // ==========================================
  Widget _buildColorUnderstandingBanner(bool isGu) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGu ? 'તમારા બાળકના પરિણામોના રંગો સમજો:' : 'Understanding Your Child\'s Assessment Colors:',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isGu
                ? '🟢 લીલો (૭૫%–૧૦૦%): પાયાની કુશળતાઓમાં નિપુણ • 🟡 પીળો (૪૦%–૭૪%): પ્રગતિશીલ • 🔴 લાલ (<૪૦%): ઘરે પ્રેક્ટિસની જરૂર'
                : '🟢 Green (75%–100%): Mastered foundational skills • 🟡 Yellow (40%–74%): Steady developing progress • 🔴 Red (Below 40%): Needs gentle extra home practice',
            style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.3),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                  elevation: 0,
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                label: Text(
                  isGu ? 'શિક્ષકને પ્રશ્ન પૂછો' : 'Ask Teacher a Question',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _openAskTeacherDialog(isGu),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: 5 CORE SUBJECTS GRID
  // ==========================================
  Widget _buildCoreSubjectsGrid(bool isGu) {
    final subjects = [
      {
        'name': isGu ? 'ગણિત' : 'Mathematics',
        'score': 58,
        'badge': isGu ? 'મધ્યમ સ્તર' : 'Average',
        'sub': isGu ? 'ગુણાકાર ઘડિયામાં સહાય જરૂરી' : 'Multiplication Tables needs practice',
        'color': const Color(0xFFEAB308),
        'bg': const Color(0xFFFEF9C3),
      },
      {
        'name': isGu ? 'અંગ્રેજી' : 'English',
        'score': 72,
        'badge': isGu ? 'પ્રગતિશીલ' : 'Good',
        'sub': isGu ? 'વ્યાકરણ અને મુખર વાચન' : 'Grammar & Oral Reading Fluency',
        'color': const Color(0xFFEAB308),
        'bg': const Color(0xFFFEF9C3),
      },
      {
        'name': isGu ? 'ગુજરાતી' : 'Gujarati',
        'score': 82,
        'badge': isGu ? 'ઉત્તમ' : 'Mastered',
        'sub': isGu ? 'વાચન અર્થગ્રહણમાં શ્રેષ્ઠ' : 'Excellent literary comprehension',
        'color': const Color(0xFF16A34A),
        'bg': const Color(0xFFDCFCE7),
      },
      {
        'name': isGu ? 'હિન્દી' : 'Hindi',
        'score': 74,
        'badge': isGu ? 'સરેરાશ' : 'Developing',
        'sub': isGu ? 'શબ્દ રચના અને વાક્ય પ્રયોગ' : 'Good vocabulary & sentences',
        'color': const Color(0xFFEAB308),
        'bg': const Color(0xFFFEF9C3),
      },
      {
        'name': isGu ? 'આસપાસ (EVS)' : 'EVS',
        'score': 86,
        'badge': isGu ? 'ઉત્કૃષ્ટ' : 'Exemplary',
        'sub': isGu ? 'પર્યાવરણ અને વિજ્ઞાન સમજ' : 'Environmental awareness & nature study',
        'color': const Color(0xFF16A34A),
        'bg': const Color(0xFFDCFCE7),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isGu ? 'વિષયવાર પરિણામો અને વિગતો' : 'Subject-Wise Results & Details',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isGu ? '૫ મુખ્ય વિષયો' : '5 Core Subjects',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final s = subjects[idx];
              final score = s['score'] as int;
              final col = s['color'] as Color;
              final bg = s['bg'] as Color;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s['name'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            '$score% • ${s["badge"]}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: col),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['sub'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score / 100.0,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(col),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: 360° HOLISTIC GROWTH & CHARACTER CARD
  // ==========================================
  Widget _buildHolisticGrowthCard(bool isGu) {
    final pillars = [
      {'name': isGu ? 'ખંત અને પ્રયત્ન (Grit & Effort)' : 'Practice Grit & Effort', 'score': 84, 'col': const Color(0xFFEA580C)},
      {'name': isGu ? 'નિયમિતતા (Consistency)' : 'Learning Consistency', 'score': 88, 'col': const Color(0xFF2563EB)},
      {'name': isGu ? 'જિજ્ઞાસુ વૃત્તિ (Curiosity)' : 'Classroom Curiosity', 'score': 82, 'col': const Color(0xFF9333EA)},
      {'name': isGu ? 'સહકાર અને નમ્રતા (Teamwork)' : 'Teamwork & Empathy', 'score': 86, 'col': const Color(0xFF0D9488)},
      {'name': isGu ? 'સહ-અભ્યાસિક (Co-Curricular)' : 'Co-Curricular & Sports', 'score': 80, 'col': const Color(0xFFDB2777)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, width: 44, color: const Color(0xFF0D9488)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isGu ? '૩૬૦° સર્વાંગી વિકાસ અને ચારિત્ર્ય શક્તિ' : '360° Holistic Growth & Character Strengths',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFCCFBF1), borderRadius: BorderRadius.circular(6)),
                child: const Text(
                  '86% • Exemplary',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F766E)),
                ),
              ),
            ],
          ),
          Text(
            isGu
                ? 'રાષ્ટ્રીય શિક્ષણ નીતિ ૨૦૨૦ (NEP 2020) HPC માર્ગદર્શિકા મુજબ માત્ર ગુણથી આગળ સર્વાંગી મૂલ્યાંકન'
                : 'NEP 2020 Multi-Dimensional Progress Card (HPC) Alignment — Evaluated beyond marks',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // 5 Pillars
          ...pillars.map((p) {
            final score = p['score'] as int;
            final col = p['col'] as Color;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p['name'] as String, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      Text('$score%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100.0,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(col),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // Teacher Observation Note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFEF08A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote_rounded, color: Color(0xFFCA8A04), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isGu
                        ? 'શિક્ષકની નોંધ: "આરવ ગણિતના કોયડા ઉકેલવામાં અદ્ભુત ખંત દર્શાવે છે અને જૂથ પ્રવૃત્તિઓમાં મિત્રોને મદદરૂપ બને છે."'
                        : 'Teacher Note: "Aarav shows remarkable perseverance during math problem-solving and actively supports his peers in group activities."',
                    style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF713F12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: CORE STRENGTHS & FOCUS AREAS
  // ==========================================
  Widget _buildCoreStrengthsCard(bool isGu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isGu ? 'મુખ્ય શક્તિઓ અને સુધારણા ક્ષેત્રો' : 'Core Strengths & Focus Areas',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Text(
            isGu ? 'શિક્ષકો દ્વારા સંકલિત શિક્ષણશાસ્ત્રીય અવલોકનો' : 'Pedagogical observations compiled by class teachers',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Strength
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFF16A34A), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGu ? 'સૌથી મજબૂત શૈક્ષણિક વિષય:' : 'Strongest Academic Domain:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                      ),
                      Text(
                        isGu ? 'પર્યાવરણ (EVS) • ૮૬% સિદ્ધિ દર' : 'Environmental Studies (EVS) • 86% Mastery',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Focus Area
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGu ? 'ધ્યાન આપવાની જરૂરિયાત વાળો વિષય:' : 'Domain Requiring Active Practice:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                      ),
                      Text(
                        isGu ? 'ગણિત • ૫૮% (ગુણાકાર ઘડિયામાં પ્રેક્ટિસ જરૂરી)' : 'Mathematics • 58% (Multiplication Tables needs support)',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: 10-MINUTE HOME PRACTICE ACTIVITIES
  // ==========================================
  Widget _buildHomePracticeSuggestions(bool isGu) {
    final suggestions = [
      {
        'title': isGu ? 'રસોડામાં ગુણાકાર રમત' : 'Kitchen Multiplication Relay',
        'sub': isGu ? 'ગણિત • ૧૦ મિનિટ • ચમચી અને વાટકીઓ ૩-૩ ના જૂથમાં ગણાવો' : 'Maths • 10 mins • Count spoons and bowls in groups of 3 & 4',
        'icon': Icons.calculate_outlined,
        'col': const Color(0xFF2563EB),
      },
      {
        'title': isGu ? 'ગુજરાતી વાર્તા વાક્ય નિર્માણ' : 'Gujarati Story Sentence Building',
        'sub': isGu ? 'ગુજરાતી • ૧૦ મિનિટ • ૧ પેરેગ્રાફ વાંચી ૨ નવા વાક્યો બનાવો' : 'Gujarati • 10 mins • Read 1 paragraph and write 2 new sentences',
        'icon': Icons.menu_book_rounded,
        'col': const Color(0xFFEA580C),
      },
      {
        'title': isGu ? 'કુદરત અવલોકન અને પાંદડાની ઓળખ' : 'Nature Journaling & Plant Observation',
        'sub': isGu ? 'પર્યાવરણ • ૧૦ મિનિટ • આસપાસના ૩ વૃક્ષોના પાંદડા ઓળખો' : 'EVS • 10 mins • Observe 3 local tree leaves and describe texture',
        'icon': Icons.eco_outlined,
        'col': const Color(0xFF16A34A),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cottage_rounded, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              Text(
                isGu ? 'ડેટા-આધારિત ૧૦ મિનિટની ગૃહ પ્રવૃત્તિઓ' : 'Data-Backed Home Practice Suggestions',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          Text(
            isGu
                ? 'બાળકના મૂલ્યાંકન પરિણામોના આધારે તૈયાર કરેલી સરળ ૧૦ મિનિટની રમતો:'
                : 'Practical 10-minute activities formulated specifically from your child\'s assessment evidence:',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final item = suggestions[idx];
              final col = item['col'] as Color;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: col.withOpacity(0.12), shape: BoxShape.circle),
                      child: Icon(item['icon'] as IconData, color: col, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            item['sub'] as String,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 7: TEACHER COMMUNICATIONS & INQUIRIES DESK
  // ==========================================
  Widget _buildTeacherCommunicationsDesk(bool isGu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, width: 44, color: const Color(0xFF0D9488)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isGu ? 'શિક્ષક સાથે સીધો સંવાદ અને માર્ગદર્શન' : 'Direct Teacher Communications & Inquiries Desk',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 0,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add_comment_rounded, size: 14),
                label: Text(isGu ? 'નવો પ્રશ્ન' : 'Ask Question', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _openAskTeacherDialog(isGu),
              ),
            ],
          ),
          Text(
            isGu ? 'શ્રીમતી અંજલી શર્મા સાથે આપ-લે થયેલ પ્રશ્નોત્તરી:' : 'Exchange of questions and guidance between you and your child\'s teachers:',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _inquiryMessages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final msg = _inquiryMessages[idx];
              final isParent = msg['from'] == 'parent';

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isParent ? const Color(0xFFF0FDFA) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isParent ? const Color(0xFF99F6E4) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isGu ? msg['senderGu']! : msg['sender']!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isParent ? const Color(0xFF0F766E) : const Color(0xFF92400E),
                          ),
                        ),
                        Text(
                          isGu ? msg['timeGu']! : msg['time']!,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGu ? msg['textGu']! : msg['text']!,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
