import 'package:flutter/material.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/models/assessment_model.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/app/app_router.dart';

class TeacherWebHomeView extends StatefulWidget {
  final List<StudentModel> students;
  final List<SubjectModel> subjects;
  final List<AssessmentModel> assessments;
  final List<RemedialAction> pendingRemedials;
  final Function(StudentModel) onStudentTap;
  final VoidCallback onRefresh;

  const TeacherWebHomeView({
    super.key,
    required this.students,
    required this.subjects,
    required this.assessments,
    required this.pendingRemedials,
    required this.onStudentTap,
    required this.onRefresh,
  });

  @override
  State<TeacherWebHomeView> createState() => _TeacherWebHomeViewState();
}

class _TeacherWebHomeViewState extends State<TeacherWebHomeView> {
  String _selectedSubject = 'Mathematics';
  final TextEditingController _ledgerSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _doubtsSectionKey = GlobalKey();

  // Thresholds (configurable)
  int _excellentThreshold = 75;
  int _averageThreshold = 40;

  // Selected filter for student ledger: 'ALL', 'GREEN', 'YELLOW', 'RED'
  String _ledgerBandFilter = 'ALL';

  @override
  void dispose() {
    _ledgerSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDoubts() {
    Scrollable.ensureVisible(
      _doubtsSectionKey.currentContext ?? context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _openThresholdConfigDialog(bool isGu) {
    int tempExcellent = _excellentThreshold;
    int tempAverage = _averageThreshold;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.tune_rounded, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Text(isGu ? 'પ્રદર્શન મર્યાદા સેટિંગ્સ' : 'Configure Thresholds'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGu
                  ? 'વિદ્યાર્થીઓના ગુણાંક અનુસાર રંગ માપદંડ બદલો:'
                  : 'Customize mastery color benchmarks for your classroom:',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Text(
                '${isGu ? "ઉત્કૃષ્ટ (ગ્રીન)" : "Excellent (Green)"} ≥ $tempExcellent%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
              ),
              Slider(
                value: tempExcellent.toDouble(),
                min: 60,
                max: 90,
                divisions: 6,
                activeColor: const Color(0xFF16A34A),
                label: '$tempExcellent%',
                onChanged: (v) => setDialogState(() => tempExcellent = v.toInt()),
              ),
              const SizedBox(height: 8),
              Text(
                '${isGu ? "સરેરાશ (પીળો)" : "Average (Yellow)"} $tempAverage% - ${tempExcellent - 1}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFCA8A04)),
              ),
              Slider(
                value: tempAverage.toDouble(),
                min: 30,
                max: 60,
                divisions: 6,
                activeColor: const Color(0xFFCA8A04),
                label: '$tempAverage%',
                onChanged: (v) => setDialogState(() => tempAverage = v.toInt()),
              ),
              Text(
                '${isGu ? "સુધારણા જરૂરી (લાલ)" : "Needs Improvement (Red)"} < $tempAverage%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isGu ? 'રદ કરો' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _excellentThreshold = tempExcellent;
                  _averageThreshold = tempAverage;
                });
                Navigator.pop(ctx);
              },
              child: Text(isGu ? 'સાચવો' : 'Save Thresholds'),
            ),
          ],
        ),
      ),
    );
  }

  // Topic mastery lookup for the selected subject
  List<Map<String, dynamic>> _getTopicsForSubject(String subjectName, bool isGu) {
    switch (subjectName) {
      case 'Mathematics':
        return [
          {
            'title': isGu ? 'સંખ્યા જ્ઞાન અને સ્થાનકિંમત' : 'Numbers & Place Value',
            'desc': isGu ? '3-અંકની સ્થાનકિંમત અને વિસ્તરણ' : '3-digit place value & expanded form',
            'percentage': 85,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'સરવાળા અને બાદબાકી' : 'Addition & Subtraction',
            'desc': isGu ? 'વદ્દીવાળા સરવાળા અને દસકાવાળી બાદબાકી' : 'With carry & regrouping borrowing',
            'percentage': 78,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'ગુણાકાર અને ભાગાકાર' : 'Multiplication & Division',
            'desc': isGu ? 'ઘડિયા 1 થી 10 અને ગુણાકાર' : 'Tables 1 to 10 & 2-digit multiplication',
            'percentage': 52,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'અપૂર્ણાંકની પાયાની સમજ' : 'Fractions Basics',
            'desc': isGu ? 'અડધો, પા અને પોણો ભાગ' : 'Halves, thirds & pictorial fractions',
            'percentage': 36,
            'color': const Color(0xFFDC2626),
          },
          {
            'title': isGu ? 'વ્યવહારિક કૂટપ્રશ્નો' : 'Word Problems',
            'desc': isGu ? 'રોજિંદા જીવનના ગાણિતિક કોયડા' : 'Multi-step real-world story problems',
            'percentage': 59,
            'color': const Color(0xFFCA8A04),
          },
        ];
      case 'English':
        return [
          {
            'title': isGu ? 'ફોનિક્સ અને ઉચ્ચારણ' : 'Phonics & Pronunciation',
            'desc': isGu ? 'સ્વર અને વ્યંજન ધ્વનિ' : 'Vowel blends & digraph sounds',
            'percentage': 82,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'વાચન અર્થગ્રહણ' : 'Reading Comprehension',
            'desc': isGu ? 'સરળ વાર્તા પઠન અને પ્રશ્નોત્તરી' : 'Passage reading & main idea deduction',
            'percentage': 70,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'શબ્દભંડોળ વૃદ્ધિ' : 'Vocabulary Building',
            'desc': isGu ? 'સમાનાર્થી અને વિરોધી શબ્દો' : 'Synonyms, antonyms & sight words',
            'percentage': 64,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'વ્યાકરણ અને કાળ' : 'Grammar & Tenses',
            'desc': isGu ? 'નામ, સર્વનામ અને ક્રિયાપદ' : 'Nouns, pronouns & simple present tense',
            'percentage': 55,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'સર્જનાત્મક લેખન' : 'Creative Writing',
            'desc': isGu ? 'સરળ વાક્ય રચના' : '3-line self introduction & picture composition',
            'percentage': 48,
            'color': const Color(0xFFCA8A04),
          },
        ];
      case 'Gujarati':
        return [
          {
            'title': isGu ? 'મૂળાક્ષર અને માત્રા ઓળખ' : 'Alphabet & Matra Mastery',
            'desc': isGu ? 'સ્વર અને વ્યંજનની સંપૂર્ણ ઓળખ' : 'Full Gujarati alphabet & vowel marks',
            'percentage': 88,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'શબ્દભંડોળ અને અર્થબોધ' : 'Vocabulary & Word Meanings',
            'desc': isGu ? 'રોજિંદા ઉપયોગી ગુજરાતી શબ્દો' : 'Everyday contextual vocabulary',
            'percentage': 84,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'વાચન અર્થગ્રહણ' : 'Reading Comprehension',
            'desc': isGu ? 'વાર્તા અને કવિતા પઠન' : 'Story recitation & question responses',
            'percentage': 76,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'જોડણી અને વ્યાકરણ' : 'Spelling & Grammar',
            'desc': isGu ? 'હ્રસ્વ-દીર્ઘ અને અનુસ્વાર' : 'Correct vowel signs & punctuation',
            'percentage': 65,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'લેખન અભિવ્યક્તિ' : 'Written Expression',
            'desc': isGu ? 'પોતાના વિચારો લેખિતમાં વ્યક્ત કરવા' : 'Paragraph writing & story completion',
            'percentage': 60,
            'color': const Color(0xFFCA8A04),
          },
        ];
      case 'Hindi':
        return [
          {
            'title': isGu ? 'વર્ણમાલા જ્ઞાન' : 'Varnamala Identification',
            'desc': isGu ? 'સ્વર અને વ્યંજન ઓળખ' : 'Devanagari vowels and consonants',
            'percentage': 80,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'શબ્દ રચના' : 'Word Formation',
            'desc': isGu ? 'માત્રાયુક્ત શબ્દો' : 'Matra-based word building',
            'percentage': 75,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'વાક્ય પ્રયોગ' : 'Sentence Construction',
            'desc': isGu ? 'સરળ વાક્યોનું નિર્માણ' : 'Simple sentence structuring',
            'percentage': 62,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'વ્યાકરણ બોધ' : 'Grammar Basics',
            'desc': isGu ? 'સંજ્ઞા અને ક્રિયા' : 'Nouns and action verbs',
            'percentage': 58,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'પઠન અને સમજ' : 'Reading & Comprehension',
            'desc': isGu ? 'ગદ્ય પઠન' : 'Short paragraph reading fluency',
            'percentage': 70,
            'color': const Color(0xFFCA8A04),
          },
        ];
      case 'EVS':
      default:
        return [
          {
            'title': isGu ? 'વનસ્પતિ અને પ્રાણીઓ' : 'Plants & Animal Life',
            'desc': isGu ? 'આસપાસની પ્રકૃતિનું અવલોકન' : 'Flora, fauna & living organisms',
            'percentage': 86,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'ખોરાક અને પોષણ' : 'Food & Nutrition',
            'desc': isGu ? 'સમતુલ આહાર અને સ્વાસ્થ્ય' : 'Balanced diet & hygiene habits',
            'percentage': 80,
            'color': const Color(0xFF16A34A),
          },
          {
            'title': isGu ? 'પાણી અને ઋતુઓ' : 'Water, Seasons & Weather',
            'desc': isGu ? 'જળ સંરક્ષણ અને ઋતુચક્ર' : 'Water conservation & seasons cycle',
            'percentage': 72,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'પર્યાવરણ સુરક્ષા' : 'Environmental Conservation',
            'desc': isGu ? 'સ્વચ્છતા અને કચરાનું વ્યવસ્થાપન' : 'Waste management & clean surroundings',
            'percentage': 68,
            'color': const Color(0xFFCA8A04),
          },
          {
            'title': isGu ? 'નકશા અને દિશાઓ' : 'Maps & Cardinal Directions',
            'desc': isGu ? 'પૂર્વ-પશ્ચિમ દિશા અને શાળાનો નકશો' : 'Compass directions & neighborhood layout',
            'percentage': 54,
            'color': const Color(0xFFCA8A04),
          },
        ];
    }
  }

  // Student roster data for selected subject
  List<Map<String, dynamic>> _getStudentLedgerList(bool isGu) {
    return [
      {
        'id': 'student_1',
        'name': 'Aarav Patel',
        'code': 'GPS-2026-001',
        'roll': '01',
        'score': _selectedSubject == 'Mathematics' ? 58 : (_selectedSubject == 'EVS' ? 86 : 74),
        'strongTopic': _selectedSubject == 'Mathematics'
            ? (isGu ? 'સંખ્યા જ્ઞાન (88%)' : 'Place Value (88%)')
            : (isGu ? 'વનસ્પતિ-પ્રાણી (90%)' : 'Plants & Nature (90%)'),
        'weakTopic': _selectedSubject == 'Mathematics'
            ? (isGu ? 'અપૂર્ણાંક (32%)' : 'Fractions (32%)')
            : (isGu ? 'નકશા અને દિશાઓ (48%)' : 'Map Reading (48%)'),
      },
      {
        'id': 'student_2',
        'name': 'Diya Shah',
        'code': 'GPS-2026-002',
        'roll': '02',
        'score': _selectedSubject == 'Mathematics' ? 84 : 88,
        'strongTopic': isGu ? 'સરવાળા-બાદબાકી (94%)' : 'Addition & Subtraction (94%)',
        'weakTopic': isGu ? 'કૂટપ્રશ્નો (68%)' : 'Word Problems (68%)',
      },
      {
        'id': 'student_3',
        'name': 'Kavya Prajapati',
        'code': 'GPS-2026-003',
        'roll': '03',
        'score': _selectedSubject == 'Mathematics' ? 38 : 62,
        'strongTopic': isGu ? 'સરવાળા (70%)' : 'Basic Addition (70%)',
        'weakTopic': isGu ? 'ગુણાકાર-ભાગાકાર (28%)' : 'Multiplication Tables (28%)',
      },
      {
        'id': 'student_4',
        'name': 'Rohan Varma',
        'code': 'GPS-2026-004',
        'roll': '04',
        'score': _selectedSubject == 'Mathematics' ? 64 : 70,
        'strongTopic': isGu ? 'સંખ્યા જ્ઞાન (82%)' : 'Place Value (82%)',
        'weakTopic': isGu ? 'અપૂર્ણાંક (42%)' : 'Fraction Division (42%)',
      },
      {
        'id': 'student_5',
        'name': 'Pooja Joshi',
        'code': 'GPS-2026-005',
        'roll': '05',
        'score': _selectedSubject == 'Mathematics' ? 66 : 75,
        'strongTopic': isGu ? 'ગુણાકાર (80%)' : 'Multiplication (80%)',
        'weakTopic': isGu ? 'કૂટપ્રશ્નો (50%)' : 'Word Problems (50%)',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    // Compute stats for current subject
    final studentLedger = _getStudentLedgerList(isGu);
    final totalStudents = studentLedger.length;
    final subjectAvg = (studentLedger.fold<int>(0, (sum, s) => sum + (s['score'] as int)) / totalStudents).round();
    final excellentCount = studentLedger.where((s) => (s['score'] as int) >= _excellentThreshold).length;
    final supportCount = studentLedger.where((s) => (s['score'] as int) < _averageThreshold).length;
    final avgCount = totalStudents - excellentCount - supportCount;

    // Filter student ledger
    final searchQuery = _ledgerSearchController.text.trim().toLowerCase();
    final filteredRoster = studentLedger.where((s) {
      final name = (s['name'] as String).toLowerCase();
      final code = (s['code'] as String).toLowerCase();
      final score = s['score'] as int;

      final matchesSearch = searchQuery.isEmpty || name.contains(searchQuery) || code.contains(searchQuery);
      if (!matchesSearch) return false;

      if (_ledgerBandFilter == 'GREEN') return score >= _excellentThreshold;
      if (_ledgerBandFilter == 'YELLOW') return score >= _averageThreshold && score < _excellentThreshold;
      if (_ledgerBandFilter == 'RED') return score < _averageThreshold;
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // 1. Web-Cloned Header Banner
          _buildWebHeaderBanner(isGu),
          const SizedBox(height: 14),

          // 2. 5 Subject Selector Grid (Exact clone of web/teacher.html)
          _buildSubjectSelectorGrid(isGu),
          const SizedBox(height: 14),

          // 3. Configurable Performance Thresholds Legend Bar
          _buildThresholdLegendBar(isGu),
          const SizedBox(height: 14),

          // 4. 4 Metric Stats Grid
          _buildStatsCardsGrid(
            isGu: isGu,
            totalStudents: totalStudents,
            subjectAvg: subjectAvg,
            excellentCount: excellentCount,
            supportCount: supportCount,
          ),
          const SizedBox(height: 16),

          // 5. Topic-Wise Class Mastery Rate
          _buildTopicMasteryCard(isGu),
          const SizedBox(height: 16),

          // 6. Performance Distribution Card
          _buildPerformanceDistributionCard(
            isGu: isGu,
            total: totalStudents,
            excellent: excellentCount,
            average: avgCount,
            support: supportCount,
          ),
          const SizedBox(height: 16),

          // 7. Student Performance & Diagnostic Ledger
          _buildDiagnosticLedgerCard(isGu, filteredRoster),
          const SizedBox(height: 20),

          // 8. Answer Parent Questions & Inquiries Desk
          Container(
            key: _doubtsSectionKey,
            child: _buildParentInquiriesDesk(isGu),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 1: HEADER BANNER
  // ==========================================
  Widget _buildWebHeaderBanner(bool isGu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGu
                          ? 'વર્ગ શૈક્ષણિક પ્રદર્શન અને નિદાન લેજર'
                          : 'Class Academic Performance & Diagnostic Ledger',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGu
                          ? 'સતત વર્ગખંડ મૂલ્યાંકન, મુદ્દાવાર ક્ષતિ વિશ્લેષણ અને લક્ષિત ઉપચારાત્મક માર્ગદર્શન'
                          : 'Continuous classroom evaluation, topic-level gap analysis, and tailored remedial recommendations',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Primary Class Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 15, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Text(
                        isGu ? 'ધોરણ ૪ - વર્ગ અ (પ્રાથમિક)' : 'Class 4 - Section A (Primary)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Answer Parent Questions Badge Button
              InkWell(
                onTap: _scrollToDoubts,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.question_answer_rounded, size: 15, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Text(
                          isGu ? 'વાલીઓના પ્રશ્નોના ઉત્તર' : 'Answer Parent Questions',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: 5 SUBJECT SELECTOR GRID
  // ==========================================
  Widget _buildSubjectSelectorGrid(bool isGu) {
    final subjectsConfig = [
      {
        'key': 'Mathematics',
        'title': isGu ? 'ગણિત' : 'Mathematics',
        'sub': isGu ? '૫ નિદાન વિષયો' : '5 Diagnostic Topics',
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'key': 'English',
        'title': isGu ? 'અંગ્રેજી' : 'English',
        'sub': isGu ? 'ભાષા અને વ્યાકરણ' : 'Language & Grammar',
        'icon': Icons.spellcheck_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'key': 'Gujarati',
        'title': isGu ? 'ગુજરાતી' : 'Gujarati',
        'sub': isGu ? 'ગુજરાતી સાહિત્ય' : 'ગુજરાતી સાહિત્ય',
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFFEA580C),
      },
      {
        'key': 'Hindi',
        'title': isGu ? 'હિન્દી' : 'Hindi',
        'sub': isGu ? 'હિન્દી ભાષા' : 'हिन्दी भाषा एवं व्याकरण',
        'icon': Icons.translate_rounded,
        'color': const Color(0xFF0D9488),
      },
      {
        'key': 'EVS',
        'title': isGu ? 'આસપાસ (EVS)' : 'EVS',
        'sub': isGu ? 'પર્યાવરણ અભ્યાસ' : 'Environmental Studies',
        'icon': Icons.eco_rounded,
        'color': const Color(0xFF16A34A),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(14),
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
              const Icon(Icons.menu_book_rounded, color: Color(0xFF0D9488), size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGu ? 'નિરીક્ષણ કરવા વિષય પસંદ કરો' : 'Select Subject to Inspect',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isGu
                ? 'વિષયવાર નિદાન અને ક્ષતિ વિશ્લેષણ જોવા નીચેનામાંથી વિષય ટેપ કરો:'
                : 'Choose any of the five primary subjects to view topic-wise diagnostic breakdowns:',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 580;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjectsConfig.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 5 : (constraints.maxWidth > 380 ? 3 : 2),
                  childAspectRatio: isWide ? 1.6 : 1.45,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final subj = subjectsConfig[index];
                  final isSelected = _selectedSubject == subj['key'];
                  final iconColor = subj['color'] as Color;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSubject = subj['key'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FDFA) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(subj['icon'] as IconData, size: 18, color: iconColor),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle, size: 14, color: Color(0xFF0D9488)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subj['title'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subj['sub'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: THRESHOLD LEGEND BAR
  // ==========================================
  Widget _buildThresholdLegendBar(bool isGu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                isGu ? 'મૂલ્યાંકન માપદંડ:' : 'Performance Thresholds:',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              _buildPill(
                isGu ? 'ઉત્તમ (≥$_excellentThreshold%)' : 'Green • Excellent (≥$_excellentThreshold%)',
                const Color(0xFFDCFCE7),
                const Color(0xFF15803D),
              ),
              _buildPill(
                isGu ? 'સરેરાશ ($_averageThreshold% - ${_excellentThreshold - 1}%)' : 'Yellow • Average ($_averageThreshold% - ${_excellentThreshold - 1}%)',
                const Color(0xFFFEF9C3),
                const Color(0xFFA16207),
              ),
              _buildPill(
                isGu ? 'સુધારણા જરૂરી (<$_averageThreshold%)' : 'Red • Needs Improvement (<$_averageThreshold%)',
                const Color(0xFFFEE2E2),
                const Color(0xFFB91C1C),
              ),
            ],
          ),
          InkWell(
            onTap: () => _openThresholdConfigDialog(isGu),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings, size: 14, color: Color(0xFF475569)),
                  const SizedBox(width: 4),
                  Text(
                    isGu ? 'સેટિંગ્સ' : 'Configure',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }

  // ==========================================
  // SECTION 4: 4 STAT CARDS
  // ==========================================
  Widget _buildStatsCardsGrid({
    required bool isGu,
    required int totalStudents,
    required int subjectAvg,
    required int excellentCount,
    required int supportCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 580;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isWide ? 1.5 : 1.3,
          children: [
            // Card 1: Students Evaluated
            _buildStatCard(
              title: isGu ? 'કુલ મૂલ્યાંકિત વિદ્યાર્થીઓ' : 'Students Evaluated',
              value: '$totalStudents',
              sub: isGu ? 'વર્ગ ૪-અ સક્રિય રોસ્ટર' : 'Class 4-A Active Roster',
              icon: Icons.groups_rounded,
              iconColor: const Color(0xFF0D9488),
              iconBg: const Color(0xFFCCFBF1),
            ),

            // Card 2: Subject Average
            _buildStatCard(
              title: isGu ? 'વિષયની સરેરાશ' : 'Subject Average',
              value: '$subjectAvg%',
              sub: subjectAvg >= _excellentThreshold
                  ? (isGu ? 'ઉચ્ચ સ્તર' : 'High Mastery')
                  : (subjectAvg >= _averageThreshold
                      ? (isGu ? 'મધ્યમ સ્તર' : 'Average Mastery')
                      : (isGu ? 'સહાય જરૂરી' : 'Needs Support')),
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBg: const Color(0xFFDBEAFE),
            ),

            // Card 3: Excellent Performers
            _buildStatCard(
              title: isGu ? 'ઉત્કૃષ્ટ વિદ્યાર્થીઓ' : 'Excellent Performers',
              value: '$excellentCount',
              sub: '≥$_excellentThreshold% ${isGu ? "સિદ્ધિ સ્તર" : "Mastery Band"}',
              icon: Icons.military_tech_rounded,
              iconColor: const Color(0xFF16A34A),
              iconBg: const Color(0xFFDCFCE7),
              valueColor: const Color(0xFF15803D),
            ),

            // Card 4: Needs More Improvement
            _buildStatCard(
              title: isGu ? 'સુધારણાની જરૂર' : 'Needs Improvement',
              value: '$supportCount',
              sub: '<$_averageThreshold% ${isGu ? "નિદાન ક્ષતિ" : "Critical Gap"}',
              icon: Icons.priority_high_rounded,
              iconColor: const Color(0xFFDC2626),
              iconBg: const Color(0xFFFEE2E2),
              valueColor: const Color(0xFFB91C1C),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: TOPIC-WISE CLASS MASTERY RATE
  // ==========================================
  Widget _buildTopicMasteryCard(bool isGu) {
    final topics = _getTopicsForSubject(_selectedSubject, isGu);

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
              const Icon(Icons.bar_chart_rounded, color: Color(0xFF0D9488), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGu ? 'મુદ્દાવાર વર્ગ સિદ્ધિ દર' : 'Topic-Wise Class Mastery Rate',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      '$_selectedSubject • ${isGu ? "મુખ્ય ૫ મુદ્દાઓનું વિશ્લેષણ" : "Breakdown across the 5 primary topics"}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final topic = topics[index];
              final pct = topic['percentage'] as int;
              final col = topic['color'] as Color;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          topic['title'] as String,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: col.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$pct%',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: col),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    topic['desc'] as String,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100.0,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(col),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: PERFORMANCE DISTRIBUTION
  // ==========================================
  Widget _buildPerformanceDistributionCard({
    required bool isGu,
    required int total,
    required int excellent,
    required int average,
    required int support,
  }) {
    final excPct = total > 0 ? ((excellent / total) * 100).round() : 20;
    final avgPct = total > 0 ? ((average / total) * 100).round() : 60;
    final supPct = total > 0 ? ((support / total) * 100).round() : 20;

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
              const Icon(Icons.pie_chart_rounded, color: Color(0xFF1E293B), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGu ? 'પ્રદર્શન વિતરણ' : 'Performance Distribution',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      isGu ? 'આ વિષયમાં ગુણવત્તા સ્તર અનુસાર વિદ્યાર્થી વિતરણ' : 'Student breakdown by mastery bands in this subject',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal segmented mastery bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 22,
              child: Row(
                children: [
                  if (excPct > 0)
                    Expanded(
                      flex: excPct,
                      child: Container(
                        color: const Color(0xFF16A34A),
                        alignment: Alignment.center,
                        child: Text(
                          '$excPct%',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  if (avgPct > 0)
                    Expanded(
                      flex: avgPct,
                      child: Container(
                        color: const Color(0xFFEAB308),
                        alignment: Alignment.center,
                        child: Text(
                          '$avgPct%',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  if (supPct > 0)
                    Expanded(
                      flex: supPct,
                      child: Container(
                        color: const Color(0xFFDC2626),
                        alignment: Alignment.center,
                        child: Text(
                          '$supPct%',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDistLegendItem(
                label: isGu ? 'ઉત્કૃષ્ટ' : 'High (≥75%)',
                count: '$excellent ${isGu ? "વિદ્યાર્થી" : "students"}',
                color: const Color(0xFF16A34A),
              ),
              _buildDistLegendItem(
                label: isGu ? 'સરેરાશ' : 'Average (40-74%)',
                count: '$average ${isGu ? "વિદ્યાર્થી" : "students"}',
                color: const Color(0xFFCA8A04),
              ),
              _buildDistLegendItem(
                label: isGu ? 'સહાય જરૂરી' : 'Needs Help (<40%)',
                count: '$support ${isGu ? "વિદ્યાર્થી" : "students"}',
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistLegendItem({required String label, required String count, required Color color}) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            Text(count, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 7: STUDENT PERFORMANCE & DIAGNOSTIC LEDGER
  // ==========================================
  Widget _buildDiagnosticLedgerCard(bool isGu, List<Map<String, dynamic>> roster) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isGu ? "વિદ્યાર્થી પ્રદર્શન અને નિદાન લેજર" : "Student Performance & Diagnostic Ledger"}: $_selectedSubject',
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      isGu ? 'વિદ્યાર્થીઓની ક્ષમતાઓ અને સુધારણા ક્ષેત્રોનું લિસ્ટ' : 'Comprehensive roster, individual gap analysis, and tailored actions',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _ledgerSearchController,
            decoration: InputDecoration(
              hintText: isGu ? 'વિદ્યાર્થીનું નામ અથવા ID શોધો...' : 'Search student by name or enrollment ID...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _ledgerSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _ledgerSearchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),

          // Filter Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text(isGu ? 'બધા (${roster.length})' : 'All (${roster.length})'),
                selected: _ledgerBandFilter == 'ALL',
                onSelected: (_) => setState(() => _ledgerBandFilter = 'ALL'),
              ),
              ChoiceChip(
                label: Text(isGu ? 'ઉત્તમ (Green)' : 'Excellent (Green)'),
                selected: _ledgerBandFilter == 'GREEN',
                selectedColor: const Color(0xFFDCFCE7),
                onSelected: (_) => setState(() => _ledgerBandFilter = 'GREEN'),
              ),
              ChoiceChip(
                label: Text(isGu ? 'સરેરાશ (Yellow)' : 'Average (Yellow)'),
                selected: _ledgerBandFilter == 'YELLOW',
                selectedColor: const Color(0xFFFEF9C3),
                onSelected: (_) => setState(() => _ledgerBandFilter = 'YELLOW'),
              ),
              ChoiceChip(
                label: Text(isGu ? 'સહાય જરૂરી (Red)' : 'Needs Support (Red)'),
                selected: _ledgerBandFilter == 'RED',
                selectedColor: const Color(0xFFFEE2E2),
                onSelected: (_) => setState(() => _ledgerBandFilter = 'RED'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Student Cards List
          if (roster.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  isGu ? 'કોઈ વિદ્યાર્થી મળ્યા નથી.' : 'No students found matching this criteria.',
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: roster.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = roster[index];
                final score = student['score'] as int;

                Color badgeBg;
                Color badgeText;
                String statusLabel;
                if (score >= _excellentThreshold) {
                  badgeBg = const Color(0xFFDCFCE7);
                  badgeText = const Color(0xFF15803D);
                  statusLabel = isGu ? 'ઉત્તમ' : 'Mastered';
                } else if (score >= _averageThreshold) {
                  badgeBg = const Color(0xFFFEF9C3);
                  badgeText = const Color(0xFFA16207);
                  statusLabel = isGu ? 'સરેરાશ' : 'Developing';
                } else {
                  badgeBg = const Color(0xFFFEE2E2);
                  badgeText = const Color(0xFFB91C1C);
                  statusLabel = isGu ? 'સહાય જરૂરી' : 'Needs Support';
                }

                // Match with actual student model if available
                final studentModel = widget.students.any((s) => s.id == student['id'])
                    ? widget.students.firstWhere((s) => s.id == student['id'])
                    : StudentModel(
                        id: student['id'] as String,
                        name: student['name'] as String,
                        studentId: student['code'] as String,
                        classId: 'class_4_a',
                        className: 'Class 4',
                        section: 'A',
                        schoolId: 'school_1',
                        schoolName: 'GPS Primary School Kudasan',
                      );

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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF0D9488),
                            child: Text(
                              (student['name'] as String).substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '${student["code"]} • Roll #${student["roll"]}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$score%',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: badgeText),
                                ),
                                Text(
                                  statusLabel,
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: badgeText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFF16A34A)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${isGu ? "મજબૂત પાસું" : "Strong"}: ${student["strongTopic"]}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${isGu ? "સુધારણા ક્ષેત્ર" : "Critical Gap"}: ${student["weakTopic"]}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0D9488),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.analytics_outlined, size: 16),
                            label: Text(
                              isGu ? 'નિદાન જુઓ' : 'View Diagnostic',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => widget.onStudentTap(studentModel),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              elevation: 0,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.assignment_add, size: 15),
                            label: Text(
                              isGu ? 'ઉપચારાત્મક કાર્ય' : 'Assign Practice',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.assignRemedial,
                                arguments: studentModel.id,
                              );
                            },
                          ),
                        ],
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
  // SECTION 8: PARENT INQUIRIES DESK
  // ==========================================
  Widget _buildParentInquiriesDesk(bool isGu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mark_chat_unread_rounded, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGu ? 'વાલી શૈક્ષણિક પ્રશ્નોત્તરી ડેસ્ક' : 'Answer Parent Academic Doubts & Questions',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isGu
                ? 'વાલીઓ તરફથી આવેલ તાજેતરના પ્રશ્નો અને માર્ગદર્શન વિનંતીઓ:'
                : 'Direct questions submitted by parents regarding topic comprehension & home practice:',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
          ),
          const SizedBox(height: 12),

          // Inquiry Item 1
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mrs. Geeta Patel (${isGu ? "આરવના વાલી" : "Parent of Aarav"})',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isGu ? 'ગણિત • અપૂર્ણાંક' : 'Maths • Fractions',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isGu
                      ? '"નમસ્તે શિક્ષકશ્રી, આરવને ઘરે અપૂર્ણાંક સમજવામાં મુશ્કેલી પડે છે. ઘરે કઈ પ્રવૃત્તિ કરાવી શકાય?"'
                      : '"Hello Teacher, Aarav struggles with fractions at home. Which simple game or activity should we practice with him?"',
                  style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.reply_rounded, size: 15),
                      label: Text(
                        isGu ? 'જવાબ આપો (DeepL / SMS)' : 'Reply to Parent',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isGu
                                  ? 'વાલીને જવાબી માર્ગદર્શન સફળતાપૂર્વક મોકલવામાં આવ્યું.'
                                  : 'Guidance and home practice suggestions sent to parent via DeepL.',
                            ),
                            backgroundColor: const Color(0xFF0D9488),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
