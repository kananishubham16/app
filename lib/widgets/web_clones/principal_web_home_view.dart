import 'package:flutter/material.dart';
import 'package:learning_setu/models/school_model.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/subject_model.dart';
import 'package:learning_setu/models/remedial_model.dart';
import 'package:learning_setu/app/app_router.dart';

class PrincipalWebHomeView extends StatefulWidget {
  final List<ClassModel> classes;
  final List<StudentModel> students;
  final List<SubjectModel> subjects;
  final List<RemedialAction> remedials;
  final VoidCallback onAddStudent;
  final VoidCallback onRefresh;

  const PrincipalWebHomeView({
    super.key,
    required this.classes,
    required this.students,
    required this.subjects,
    required this.remedials,
    required this.onAddStudent,
    required this.onRefresh,
  });

  @override
  State<PrincipalWebHomeView> createState() => _PrincipalWebHomeViewState();
}

class _PrincipalWebHomeViewState extends State<PrincipalWebHomeView> {
  String _selectedClass = 'All';
  String _selectedDirectiveFilter = 'All';

  // State of BRC Directives compliance
  late List<Map<String, dynamic>> _directives;

  @override
  void initState() {
    super.initState();
    _directives = [
      {
        'id': 'd1',
        'title': 'FLN Subtraction & Place Value Remediation Push',
        'titleGu': 'FLN બાદબાકી અને સ્થાનકિંમત ઉપચારાત્મક શિક્ષણ અભિયાન',
        'issuer': 'Gandhinagar Block-02 • Primary Division',
        'deadline': '10-Nov-2026',
        'priority': 'HIGH',
        'status': 'In Progress',
        'statusGu': 'કાર્ય પ્રગતિમાં છે',
        'desc': 'Target zero-period remedial practice for 38 identified Grade 3 & 4 learners falling under 40% threshold.',
        'descGu': '૪૦% થી ઓછા ગુણ ધરાવતા ૩૮ વિદ્યાર્થીઓ માટે ઝીરો-પીરિયડમાં વિશેષ માર્ગદર્શન સુનિશ્ચિત કરો.',
      },
      {
        'id': 'd2',
        'title': 'Multilingual Oral Reading Fluency (Gujarati / English)',
        'titleGu': 'દ્વિભાષી મુખર વાચન પ્રવાહિતા અભિયાન (ગુજરાતી / અંગ્રેજી)',
        'issuer': 'Gandhinagar Block-02 • Language Cell',
        'deadline': '05-Nov-2026',
        'priority': 'URGENT',
        'status': 'Active',
        'statusGu': 'સક્રિય આદેશ',
        'desc': 'Conduct weekly 1-minute oral reading assessments to raise reading speed to standard 45 words/min.',
        'descGu': 'વાચન ગતિ ધોરણ અનુસાર ૪૫ શબ્દો/મિનિટ સુધી પહોંચાડવા સાપ્તાહિક ૧-મિનિટ ટેસ્ટ લો.',
      },
      {
        'id': 'd3',
        'title': 'Bi-Weekly Parent Feedback & HPC Review Synchronization',
        'titleGu': 'પાક્ષિક વાલી પ્રતિસાદ અને હોલિસ્ટિક પ્રોગ્રેસ કાર્ડ સમન્વય',
        'issuer': 'State Project Directorate • Samagra Shiksha',
        'deadline': '30-Oct-2026',
        'priority': 'REGULAR',
        'status': 'Complied',
        'statusGu': 'પરિપૂર્ણ',
        'desc': 'Update multi-dimensional progress cards across all primary grades and synchronize parent queries.',
        'descGu': 'તમામ પ્રાથમિક વર્ગોમાં સર્વાંગી પ્રગતિ પત્રક અપડેટ કરી વાલીઓના પ્રશ્નોનો નિકાલ કરો.',
      },
    ];
  }

  void _toggleDirectiveStatus(int index) {
    setState(() {
      final current = _directives[index]['status'] as String;
      if (current == 'In Progress' || current == 'Active') {
        _directives[index]['status'] = 'Complied';
        _directives[index]['statusGu'] = 'પરિપૂર્ણ';
      } else {
        _directives[index]['status'] = 'In Progress';
        _directives[index]['statusGu'] = 'કાર્ય પ્રગતિમાં છે';
      }
    });

    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isGu
              ? 'BRC શૈક્ષણિક આદેશની સ્થિતિ સફળતાપૂર્વક અપડેટ થઈ.'
              : 'Directive compliance status updated successfully.',
        ),
        backgroundColor: const Color(0xFF0D9488),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    // Calculate metrics
    final totalStudents = widget.students.isNotEmpty ? widget.students.length : 384;
    const overallAvg = 74.2;
    final excellentCount = (totalStudents * 0.42).round();
    final supportCount = (totalStudents * 0.10).round();

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // 1. Web Header Banner with School and Class Filter
          _buildPrincipalHeaderBanner(isGu),
          const SizedBox(height: 14),

          // 2. School Core Metrics Grid (4 Stat Cards)
          _buildSchoolMetricsGrid(
            isGu: isGu,
            totalStudents: totalStudents,
            overallAvg: overallAvg,
            excellentCount: excellentCount,
            supportCount: supportCount,
          ),
          const SizedBox(height: 16),

          // 3. BRC Academic Directives & School Compliance Action Desk
          _buildBrcDirectivesDesk(isGu),
          const SizedBox(height: 16),

          // 4. Latest BRC Inspection & Institutional Quality Audit Card
          _buildInspectionAuditCard(isGu),
          const SizedBox(height: 16),

          // 5. Classroom-Wise Academic Comparison & Subject-Wise Mastery
          _buildComparativeAnalyticsCard(isGu),
          const SizedBox(height: 16),

          // 6. Dynamic Class Drill-Down & Support Students Ledger
          _buildSupportStudentsDrilldownCard(isGu),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 1: PRINCIPAL HEADER BANNER
  // ==========================================
  Widget _buildPrincipalHeaderBanner(bool isGu) {
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
          Text(
            isGu
                ? 'શાળા-સ્તરીય શૈક્ષણિક દેખરેખ અને વર્ગખંડ મોનિટરિંગ'
                : 'School-Wide Academic Oversight & Classroom Monitoring',
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
                ? 'સંસ્થાકીય પરિણામો, વર્ગ સરખામણી અને લક્ષિત ગુણવત્તા સુધારણા હસ્તક્ષેપ'
                : 'Comprehensive institutional metrics, class comparisons, and targeted quality improvement interventions',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Filters and Action Buttons Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // School Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 15, color: Color(0xFF0F172A)),
                      const SizedBox(width: 6),
                      Text(
                        isGu ? 'કુડાસણ પ્રાથમિક શાળા' : 'Kudasan Primary School',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Class Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedClass,
                    isDense: true,
                    icon: const Icon(Icons.filter_list, size: 16, color: Color(0xFF0D9488)),
                    items: [
                      DropdownMenuItem(
                        value: 'All',
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isGu ? 'બધા વર્ગો' : 'All Classes',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ...['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8'].map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedClass = val);
                    },
                  ),
                ),
              ),

              // Add Student Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(
                  isGu ? 'વિદ્યાર્થી ઉમેરો' : 'Add Student',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: widget.onAddStudent,
              ),

              // Students Directory Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.people_alt_outlined, size: 16),
                label: Text(
                  isGu ? 'વિદ્યાર્થી ડિરેક્ટરી' : 'Students Directory',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pushNamed(context, AppRouter.students),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: 4 SCHOOL CORE METRICS GRID
  // ==========================================
  Widget _buildSchoolMetricsGrid({
    required bool isGu,
    required int totalStudents,
    required double overallAvg,
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
            _buildStatCard(
              title: isGu ? 'કુલ નોંધાયેલ વિદ્યાર્થીઓ' : 'Total Students Tracked',
              value: '$totalStudents',
              sub: isGu ? '૧૬ સક્રિય વિભાગોમાં' : 'Across 16 Active Sections',
              icon: Icons.groups_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBg: const Color(0xFFDBEAFE),
            ),
            _buildStatCard(
              title: isGu ? 'સમગ્ર શાળાની સરેરાશ' : 'Overall School Average',
              value: '$overallAvg%',
              sub: isGu ? '+૩.૮% સત્રવાર વૃદ્ધિ' : '+3.8% Term-over-Term',
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF0D9488),
              iconBg: const Color(0xFFCCFBF1),
            ),
            _buildStatCard(
              title: isGu ? 'ઉત્કૃષ્ટ પ્રદર્શન' : 'Performing Excellently',
              value: '$excellentCount',
              sub: isGu ? '≥૭૫% સિદ્ધિ માપદંડ' : '≥75% Mastery Standard',
              icon: Icons.military_tech_rounded,
              iconColor: const Color(0xFF16A34A),
              iconBg: const Color(0xFFDCFCE7),
              valueColor: const Color(0xFF15803D),
            ),
            _buildStatCard(
              title: isGu ? 'સહાયની જરૂરિયાત' : 'Requiring Support',
              value: '$supportCount',
              sub: isGu ? '<૪૦% અધ્યયન ક્ષતિ' : '<40% Learning Gap',
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
  // SECTION 3: BRC ACADEMIC DIRECTIVES & SCHOOL COMPLIANCE ACTION DESK
  // ==========================================
  Widget _buildBrcDirectivesDesk(bool isGu) {
    final filtered = _directives.where((d) {
      if (_selectedDirectiveFilter == 'All') return true;
      return d['status'] == _selectedDirectiveFilter;
    }).toList();

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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isGu ? 'સત્તાવાર BRC સંદેશાવ્યવહાર' : 'Official BRC Communication',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isGu ? '૩ સક્રિય આદેશો' : '3 Active Mandates',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isGu
                ? 'BRC શૈક્ષણિક આદેશો અને શાળા અનુપાલન ડેસ્ક'
                : 'BRC Academic Directives & School Compliance Action Desk',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Text(
            isGu
                ? 'BRC ગાંધીનગર બ્લોક-૦૨ દ્વારા કુડાસણ પ્રાથમિક શાળાને આપવામાં આવેલ FLN લક્ષ્યાંકો'
                : 'Official instructional mandates, remedial guidelines, and FLN targets issued by BRC Gandhinagar Block-02',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Directive Filter
          Row(
            children: [
              Text(
                isGu ? 'ફિલ્ટર:' : 'Filter:',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDirectiveFilter,
                  isDense: true,
                  items: [
                    DropdownMenuItem(value: 'All', child: Text(isGu ? 'બધા આદેશો' : 'All Directives', style: const TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Active', child: Text(isGu ? 'સક્રિય' : 'Active', style: const TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'In Progress', child: Text(isGu ? 'પ્રગતિમાં' : 'In Progress', style: const TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'Complied', child: Text(isGu ? 'પરિપૂર્ણ' : 'Complied', style: const TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedDirectiveFilter = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Directives List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final item = filtered[idx];
              final realIdx = _directives.indexOf(item);
              final isComplied = item['status'] == 'Complied';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isComplied ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isComplied ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            isGu ? item['titleGu'] as String : item['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isComplied ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isGu ? item['statusGu'] as String : item['status'] as String,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isComplied ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGu ? item['descGu'] as String : item['desc'] as String,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          '${isGu ? "મુદત" : "Deadline"}: ${item["deadline"]}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isComplied ? const Color(0xFF64748B) : const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            elevation: 0,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: Icon(isComplied ? Icons.restart_alt : Icons.check_circle_outline, size: 13),
                          label: Text(
                            isComplied
                                ? (isGu ? 'પુનઃ સક્રિય' : 'Reopen')
                                : (isGu ? 'પૂર્ણ માર્ક કરો' : 'Mark Done'),
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _toggleDirectiveStatus(realIdx),
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
  // SECTION 4: BRC INSPECTION & QUALITY AUDIT REPORT
  // ==========================================
  Widget _buildInspectionAuditCard(bool isGu) {
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
          Container(height: 3, width: 44, color: const Color(0xFF0F172A)),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  isGu ? 'સંસ્થાકીય ઓડિટ' : 'Institutional Audit',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  isGu ? 'છેલ્લી મુલાકાત: ૧૮-ઓક્ટો-૨૦૨૬' : 'Last Inspection: 18-Oct-2026',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'FLN Tier A • 88%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isGu ? 'તાજેતરનો BRC નિરીક્ષણ અને ગુણવત્તા ઓડિટ અહેવાલ' : 'Latest BRC Inspection & Quality Audit Report',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Text(
            isGu
                ? 'સુપરવાઇઝરી મૂલ્યાંકન, FLN અનુપાલન રેટિંગ અને BRC કોઓર્ડિનેટર દ્વારા આપેલ માર્ગદર્શન'
                : 'Supervisory evaluation, FLN compliance rating, and action directives submitted by BRC Coordinator Dr. K. M. Patel',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Observation Notes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildAuditObservationRow(
                  Icons.check_circle_rounded,
                  const Color(0xFF16A34A),
                  isGu ? 'ધોરણ ૧-૩ માં TLM શૈક્ષણિક સાધનોનો ઉપયોગ ઉત્કૃષ્ટ રહ્યો.' : 'Classroom TLM utilization exemplary across Grades 1-3.',
                ),
                const SizedBox(height: 6),
                _buildAuditObservationRow(
                  Icons.check_circle_rounded,
                  const Color(0xFF16A34A),
                  isGu ? 'ગણિતમાં ઝીરો-પીરિયડ દરમિયાન ઉપચારાત્મક જૂથ શિક્ષણ સક્રિય જોવા મળ્યું.' : 'Remedial grouping active during zero-period for mathematics.',
                ),
                const SizedBox(height: 6),
                _buildAuditObservationRow(
                  Icons.info_outline_rounded,
                  const Color(0xFFD97706),
                  isGu ? 'શિફારસ: ધોરણ ૪ માં અપૂર્ણાંક અને અંગ્રેજી મૌખિક શબ્દભંડોળ પર વધુ ભાર મૂકવો.' : 'Recommendation: Reinforce Class 4 fractions and English oral reading practice.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditObservationRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.3)),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 5: COMPARATIVE ANALYTICS
  // ==========================================
  Widget _buildComparativeAnalyticsCard(bool isGu) {
    final classesData = [
      {'class': 'Class 1', 'avg': 78},
      {'class': 'Class 2', 'avg': 74},
      {'class': 'Class 3', 'avg': 68},
      {'class': 'Class 4', 'avg': 64},
      {'class': 'Class 5', 'avg': 75},
      {'class': 'Class 6', 'avg': 71},
      {'class': 'Class 7', 'avg': 69},
      {'class': 'Class 8', 'avg': 76},
    ];

    final subjectsData = [
      {'subj': isGu ? 'ગણિત' : 'Maths', 'avg': 68, 'col': const Color(0xFF2563EB)},
      {'subj': isGu ? 'અંગ્રેજી' : 'English', 'avg': 72, 'col': const Color(0xFF7C3AED)},
      {'subj': isGu ? 'ગુજરાતી' : 'Gujarati', 'avg': 81, 'col': const Color(0xFFEA580C)},
      {'subj': isGu ? 'હિન્દી' : 'Hindi', 'avg': 75, 'col': const Color(0xFF0D9488)},
      {'subj': isGu ? 'પર્યાવરણ' : 'EVS', 'avg': 78, 'col': const Color(0xFF16A34A)},
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
          Text(
            isGu ? 'શૈક્ષણિક તુલનાત્મક વિશ્લેષણ' : 'Comparative Academic Analytics',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Text(
            isGu ? 'વર્ગવાર સરેરાશ અને વિષયવાર સિદ્ધિ દર' : 'Classroom-wise averages and subject-wise mastery rates',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // 1. Class Comparison Bars
          Text(
            isGu ? '૧. વર્ગવાર શૈક્ષણિક સરેરાશ (ધોરણ ૧ થી ૮)' : '1. Classroom-Wise Academic Comparison (Class 1 to 8)',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          ...classesData.map((c) {
            final avg = c['avg'] as int;
            Color barColor = avg >= 75 ? const Color(0xFF16A34A) : (avg >= 65 ? const Color(0xFF2563EB) : const Color(0xFFCA8A04));

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 55,
                    child: Text(
                      c['class'] as String,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: avg / 100.0,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 35,
                    child: Text(
                      '$avg%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // 2. Subject Mastery
          Text(
            isGu ? '૨. વિષયવાર સરેરાશ સિદ્ધિ દર' : '2. Subject-Wise Mastery Comparison',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          ...subjectsData.map((s) {
            final avg = s['avg'] as int;
            final col = s['col'] as Color;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: Text(
                      s['subj'] as String,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: avg / 100.0,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(col),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 35,
                    child: Text(
                      '$avg%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: SUPPORT STUDENTS DRILL-DOWN LEDGER
  // ==========================================
  Widget _buildSupportStudentsDrilldownCard(bool isGu) {
    final supportRoster = [
      {'name': 'Kavya Prajapati', 'code': 'GPS-2026-003', 'class': 'Class 4-A', 'score': 38, 'gap': isGu ? 'ગણિત: ગુણાકાર ઘડિયા' : 'Maths: Multiplication Tables', 'action': 'Remedial Group A'},
      {'name': 'Yuvraj Solanki', 'code': 'GPS-2026-012', 'class': 'Class 3-B', 'score': 35, 'gap': isGu ? 'અંગ્રેજી: મૂળાક્ષર ધ્વનિ' : 'English: Phonics Blends', 'action': 'FLN Language Kit'},
      {'name': 'Pooja Parmar', 'code': 'GPS-2026-024', 'class': 'Class 5-A', 'score': 39, 'gap': isGu ? 'ગણિત: અપૂર્ણાંક ભાગાકાર' : 'Maths: Fraction Division', 'action': 'Peer Mentor Buddy'},
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                isGu ? 'શૈક્ષણિક સહાયની જરૂરિયાત ધરાવતા વિદ્યાર્થીઓ' : 'Students Requiring Priority Academic Attention',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  isGu ? 'લક્ષિત હસ્તક્ષેપ' : 'Targeted Interventions',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                ),
              ),
            ],
          ),
          Text(
            isGu ? '૪૦% થી ઓછા ગુણ ધરાવતા વિદ્યાર્થીઓ માટે વિશેષ સહાયતા સૂચિ' : 'Individual roster of learners flagged below 40% threshold across classes',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: supportRoster.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = supportRoster[index];

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFDC2626),
                      child: Text(
                        (student['name'] as String).substring(0, 1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'] as String,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF7F1D1D)),
                          ),
                          Text(
                            '${student["class"]} • ${student["code"]} • ${student["gap"]}',
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF991B1B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        '${student["score"]}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
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
}
