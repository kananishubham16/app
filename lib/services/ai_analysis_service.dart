import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learning_setu/models/performance_model.dart';
import 'package:learning_setu/services/gemini_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiAnalysisResult {
  final String summary;
  final List<String> recommendedActions;
  final bool isOnlineAi;
  final String modelName;

  const AiAnalysisResult({
    required this.summary,
    required this.recommendedActions,
    required this.isOnlineAi,
    required this.modelName,
  });
}

/// Service providing AI-powered performance diagnostics.
/// Uses a Hybrid Architecture:
/// 1. Cloud AI: Google Gemini SDK (Gemini Flash)
/// 2. Offline Heuristics: Cognitive Pedagogical AI engine
class AiAnalysisService {
  static const String _geminiApiKeyPrefKey = 'gemini_api_key';
  static const String _modelName = 'Gemini Flash';
  static const String _fallbackModelName = 'Pedagogical AI Engine';

  String? _cachedApiKey;

  AiAnalysisService({String? apiKey})
      : _cachedApiKey = apiKey;

  /// Gets the currently stored Gemini API key, if any.
  Future<String?> getApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) return _cachedApiKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(_geminiApiKeyPrefKey);
      if (key != null && key.trim().isNotEmpty) return key.trim();
    } catch (_) {
      // Ignored in headless unit test environments
    }

    // Fallback to .env configuration if available
    try {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null && envKey.trim().isNotEmpty) {
        return envKey.trim();
      }
    } catch (_) {
      // dotenv may not be initialized in some tests
    }

    return null;
  }

  /// Sets or updates the Gemini API key.
  Future<void> setApiKey(String? apiKey) async {
    _cachedApiKey = apiKey?.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (apiKey == null || apiKey.trim().isEmpty) {
        await prefs.remove(_geminiApiKeyPrefKey);
      } else {
        await prefs.setString(_geminiApiKeyPrefKey, apiKey.trim());
      }
    } catch (_) {
      // Ignored in headless unit test environments
    }
  }

  /// Generates a comprehensive AI analysis of student performance.
  Future<AiAnalysisResult> generateStudentAnalysis({
    required String studentId,
    required double? overallPercentage,
    required List<String> weakTopics,
    required int subjectsAssessed,
    required int totalSubjects,
    required List<SubjectPerformance> subjectPerformances,
    String languageCode = 'en',
    bool forceRefresh = false,
  }) async {
    // 1. If unassessed, return early with localized prompt
    if (overallPercentage == null || subjectsAssessed == 0) {
      return _generateUnassessedResult(languageCode, totalSubjects);
    }

    final promptText = _buildStudentPrompt(
      overallPercentage: overallPercentage,
      weakTopics: weakTopics,
      subjectsAssessed: subjectsAssessed,
      totalSubjects: totalSubjects,
      subjectPerformances: subjectPerformances,
      languageCode: languageCode,
    );

    final apiKey = await getApiKey();

    // 1. Cloud Gemini
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final onlineResult = await _callGeminiApiWithPrompt(
          apiKey: apiKey,
          promptText: promptText,
        );
        if (onlineResult != null) {
          return onlineResult;
        }
      } catch (e) {
        debugPrint('Cloud Gemini failed, attempting fallback: $e');
      }
    }

    // 2. Deterministic Cognitive Pedagogical AI Fallback
    return _generatePedagogicalFallback(
      overallPercentage: overallPercentage,
      weakTopics: weakTopics,
      subjectsAssessed: subjectsAssessed,
      totalSubjects: totalSubjects,
      subjectPerformances: subjectPerformances,
      languageCode: languageCode,
    );
  }

  String _buildStudentPrompt({
    required double overallPercentage,
    required List<String> weakTopics,
    required int subjectsAssessed,
    required int totalSubjects,
    required List<SubjectPerformance> subjectPerformances,
    required String languageCode,
  }) {
    final subjectsSummary = subjectPerformances.map((s) {
      final scoreStr = s.latestPercentage != null
          ? '${s.latestPercentage!.toStringAsFixed(1)}%'
          : 'Not assessed';
      return '${s.subjectName}: $scoreStr (${s.level.name})';
    }).join('; ');

    return '''
You are an expert primary school educational psychologist and pedagogy specialist for Gujarat primary schools.
Analyze this student's diagnostic test data and provide a constructive, actionable diagnostic summary and specific intervention steps.

Student Metrics:
- Overall Score: ${overallPercentage.toStringAsFixed(1)}%
- Subjects Assessed: $subjectsAssessed of $totalSubjects
- Subject Details: $subjectsSummary
- Critical Learning Gaps / Weak Topics: ${weakTopics.isEmpty ? 'None' : weakTopics.join(', ')}
- Target Output Language: ${languageCode == 'gu' ? 'Gujarati (ગુજરાતી)' : 'English'}

Important Instructions:
1. Include the exact phrase "$subjectsAssessed of $totalSubjects subjects assessed" in the summary.
2. Growth-Mindset Compliment & Encouragement Tone Guidelines:
   - For high-performing students (≥70%): Motivate conceptual brilliance, celebrate diligence, and challenge them to stretch their curiosity with advanced enrichment (HOTS) and creative problem solving.
   - For struggling / weak students (<40%): Avoid hollow praise that leads to complacency, but never use deficit, harsh, or demotivating labels. Warmly and constructively encourage persistence, diligent daily effort, and step-by-step foundational practice.
   - For developing students (40-69%): Acknowledge steady progress and provide targeted revision areas to unlock top mastery.
3. The summary must explain the underlying cognitive barrier for the weak topics and suggest positive reinforcement.
4. Provide 3 to 4 specific, actionable, grade-appropriate remedial interventions.
5. Respond ONLY with a valid JSON object matching this schema:
{
  "summary": "String",
  "recommendedActions": ["String", "String", "String"]
}
''';
  }

  AiAnalysisResult _generateUnassessedResult(String languageCode, int total) {
    if (languageCode == 'gu') {
      return const AiAnalysisResult(
        summary:
            'હજુ સુધી કોઈ મૂલ્યાંકન નોંધાયેલ નથી. No assessments recorded yet. Please complete subject assessments to see performance analysis.',
        recommendedActions: [
          'વિષયવાર નિદાન મૂલ્યાંકન શેડ્યૂલ કરો',
          'મૂળભૂત ક્ષમતા ચકાસણી હાથ ધરો',
          'નિયમિત હાજરી અને પ્રગતિ પર નજર રાખો',
        ],
        isOnlineAi: false,
        modelName: _fallbackModelName,
      );
    }

    return const AiAnalysisResult(
      summary:
          'No assessments recorded yet. Please complete subject assessments to see performance analysis.',
      recommendedActions: [
        'Schedule initial baseline assessments across curriculum subjects',
        'Record foundational learning levels in primary subjects',
        'Monitor regular classroom attendance and engagement',
      ],
      isOnlineAi: false,
      modelName: _fallbackModelName,
    );
  }

  /// Low-level execution for Cloud Gemini with structured prompt
  Future<AiAnalysisResult?> _callGeminiApiWithPrompt({
    required String apiKey,
    required String promptText,
  }) async {
    try {
      final gemini = GeminiService(apiKey: apiKey);
      final jsonText = await gemini
          .generateJson(promptText, temperature: 0.3, maxTokens: 800)
          .timeout(const Duration(seconds: 10));

      final parsed = jsonDecode(jsonText);
      final summary = parsed['summary'] as String?;
      final actions = (parsed['recommendedActions'] as List?)?.cast<String>();

      if (summary != null && actions != null && actions.isNotEmpty) {
        return AiAnalysisResult(
          summary: summary,
          recommendedActions: actions,
          isOnlineAi: true,
          modelName: _modelName,
        );
      }
    } catch (e) {
      debugPrint('Gemini SDK call failed: $e');
    }

    return null;
  }

  /// Builds structured prompt for school/institutional BRC diagnostics
  String _buildSchoolPrompt({
    required String schoolId,
    required String schoolName,
    required double overallPercentage,
    required double coveragePercentage,
    required double remedialCompletionRate,
    required List<String> criticalGapTopics,
    required int totalClasses,
    required String languageCode,
  }) {
    return '''
You are a senior primary education administrator and institutional auditor for Gujarat primary schools (BRC level).
Analyze this school's assessment coverage and academic mastery data to provide an executive institutional diagnostic and concrete administrative interventions.

School Metrics:
- School Name: $schoolName (ID: $schoolId)
- Overall Mastery Score: ${overallPercentage.toStringAsFixed(1)}%
- Assessment Coverage: ${coveragePercentage.toStringAsFixed(0)}%
- Remedial Completion Rate: ${remedialCompletionRate.toStringAsFixed(0)}%
- Enrolled Classes: $totalClasses
- Critical Learning Gap Topics: ${criticalGapTopics.isEmpty ? 'None identified' : criticalGapTopics.join(', ')}
- Target Output Language: ${languageCode == 'gu' ? 'Gujarati (ગુજરાતી)' : 'English'}

Instructions:
1. Provide a professional, encouraging, and data-driven executive summary explaining the institutional health of this school.
2. Formulate 3 to 4 specific, actionable, institutional-level recommendations for the Block Resource Centre (BRC) and School Headmaster.
3. Respond ONLY with a valid JSON object matching this schema:
{
  "summary": "String",
  "recommendedActions": ["String", "String", "String"]
}
''';
  }

  /// Generates deep pedagogical synthesis offline.
  AiAnalysisResult _generatePedagogicalFallback({
    required double overallPercentage,
    required List<String> weakTopics,
    required int subjectsAssessed,
    required int totalSubjects,
    required List<SubjectPerformance> subjectPerformances,
    required String languageCode,
  }) {
    final coverage = '$subjectsAssessed of $totalSubjects subjects assessed';
    final isGu = languageCode == 'gu';

    String levelDesc;
    String cognitiveInsight;
    List<String> actions = [];

    if (overallPercentage >= 70.0) {
      levelDesc = isGu
          ? 'ઉચ્ચ શૈક્ષણિક પ્રાવીણ્ય દર્શાવે છે'
          : 'demonstrating strong academic mastery';
      cognitiveInsight = isGu
          ? 'વિદ્યાર્થી મુખ્ય સંકલ્પનાઓમાં ઉત્તમ આત્મવિશ્વાસ ધરાવે છે. વિશ્લેષણાત્મક વિચારસરણી અને ઉચ્ચ સ્તરના પ્રશ્નો (HOTS) માટે તૈયાર છે.'
          : 'The student exhibits strong conceptual foundation and fluid application skills. Ready for advanced enrichment tasks and creative problem-solving.';
    } else if (overallPercentage >= 40.0) {
      levelDesc = isGu
          ? 'સામાન્ય પ્રદર્શન અને સતત વિકાસ દર્શાવે છે'
          : 'showing average performance with developing competencies';
      cognitiveInsight = isGu
          ? 'વિદ્યાર્થી મૂળભૂત નિયમો સમજે છે પરંતુ જટિલ સમસ્યાઓમાં પુનરાવર્તન અને માર્ગદર્શિત મહાવરાની જરૂર છે.'
          : 'The student understands core procedures but requires structured scaffolding when transitioning to multi-step problem solving.';
    } else {
      levelDesc = isGu
          ? 'માર્ગદર્શિત દૈનિક મહાવરા દ્વારા પાયાની ક્ષમતાઓ મજબૂત કરી રહ્યો છે'
          : 'actively building foundational strength through daily guided practice';
      cognitiveInsight = isGu
          ? 'પાયાના ખ્યાલો દ્રઢ કરવા માટે ધીરજ, નિયમિત અભ્યાસ અને મૂર્ત શૈક્ષણિક સાધનોના ઉપયોગથી આત્મવિશ્વાસ અને પ્રગતિ બંને વધશે. નિરાશ થયા વગર દરરોજ પ્રેક્ટિસ જરૂરી છે.'
          : 'Foundational learning requires patience, structured reinforcement, and persistent daily practice. With guided micro-steps and concrete learning aids, confidence and mastery will steadily grow.';
    }

    // Weak topics diagnostic breakdown
    String weakTopicsNarrative = '';
    if (weakTopics.isNotEmpty) {
      final mathGaps = weakTopics
          .where(
            (t) =>
                t.toLowerCase().contains('sub') ||
                t.toLowerCase().contains('div') ||
                t.toLowerCase().contains('frac') ||
                t.toLowerCase().contains('mult') ||
                t.toLowerCase().contains('add'),
          )
          .toList();
      final langGaps = weakTopics
          .where(
            (t) =>
                t.toLowerCase().contains('read') ||
                t.toLowerCase().contains('phon') ||
                t.toLowerCase().contains('word') ||
                t.toLowerCase().contains('sent') ||
                t.toLowerCase().contains('vocab'),
          )
          .toList();

      if (isGu) {
        weakTopicsNarrative = ' ધ્યાનાકર્ષક ક્ષેત્રો: ${weakTopics.join(", ")}. ';
        if (mathGaps.isNotEmpty) {
          weakTopicsNarrative +=
              'ગણિતમાં (${mathGaps.join(", ")}) સંકલ્પનાત્મક સ્પષ્ટતા માટે સંખ્યા રેખા અને મૂર્ત પદ્ધતિઓ જરૂરી છે. ';
        }
        if (langGaps.isNotEmpty) {
          weakTopicsNarrative +=
              'ભાષામાં (${langGaps.join(", ")}) દૈનિક ૧૫ મિનિટનું મોટેથી વાચન અને શબ્દ નિર્માણ ઉપયોગી રહેશે.';
        }
      } else {
        weakTopicsNarrative = ' Priority learning gaps: ${weakTopics.join(", ")}. ';
        if (mathGaps.isNotEmpty) {
          weakTopicsNarrative +=
              'In Mathematics (${mathGaps.join(", ")}), concrete-representational-abstract (CRA) methods will rebuild procedural fluency. ';
        }
        if (langGaps.isNotEmpty) {
          weakTopicsNarrative +=
              'In Language competencies (${langGaps.join(", ")}), targeted phonemic drills and contextual vocabulary immersion are advised.';
        }
      }
    }

    String summary;
    if (isGu) {
      summary =
          'તાજેતરના નિયમિત મૂલ્યાંકનો પર આધારિત ($coverage), આ વિદ્યાર્થી $levelDesc અને એકંદર સ્કોર ${overallPercentage.toStringAsFixed(1)}% ધરાવે છે. $cognitiveInsight$weakTopicsNarrative';
    } else {
      summary =
          'Based on the latest regular assessments ($coverage), this student is $levelDesc with an overall score of ${overallPercentage.toStringAsFixed(1)}%. $cognitiveInsight$weakTopicsNarrative';
    }

    // Recommended Actions Generation
    if (subjectsAssessed < totalSubjects) {
      actions.add(
        isGu
            ? 'બાકી રહેલા ${totalSubjects - subjectsAssessed} વિષય(ઓ) માટે મૂલ્યાંકન પૂર્ણ કરો'
            : 'Complete assessments for remaining ${totalSubjects - subjectsAssessed} subject(s)',
      );
    }

    for (final topic in weakTopics.take(3)) {
      actions.add(
        isGu
            ? 'નબળા વિષયનો મહાવરો: $topic (અનુકૂલિત ક્વિઝ લો)'
            : 'Practice weak topic: $topic (launch targeted quiz)',
      );
    }

    if (overallPercentage < 40.0) {
      actions.add(
        isGu
            ? 'શિક્ષક સાથે દૈનિક ૧૫ મિનિટનું વ્યક્તિગત ઉપચારાત્મક સત્ર ગોઠવો'
            : 'Schedule one-on-one pedagogical support session',
      );
      actions.add(
        isGu
            ? 'વાલીને ઘરે સરળ પ્રવૃત્તિ-આધારિત અભ્યાસ કરાવવા માર્ગદર્શન આપો'
            : 'Coordinate with parents for 10-minute guided home practice',
      );
    } else if (overallPercentage >= 70.0) {
      actions.add(
        isGu
            ? 'ઉચ્ચ સ્તરીય વિચારસરણી (HOTS) પ્રવૃત્તિઓ સોંપો'
            : 'Consider advanced practice and enrichment activities',
      );
    } else {
      actions.add(
        isGu
            ? 'સાપ્તાહિક પ્રગતિ માપવા ફોલો-અપ પુનઃચકાસણી કરો'
            : 'Conduct weekly micro-quiz reassessment to track gap closure',
      );
    }

    if (actions.isEmpty) {
      actions.add(
        isGu
            ? 'પ્રગતિ ચકાસવા નિયમિત મૂલ્યાંકન ચાલુ રાખો'
            : 'Continue regular assessments to track progress',
      );
    }

    return AiAnalysisResult(
      summary: summary,
      recommendedActions: actions,
      isOnlineAi: false,
      modelName: _fallbackModelName,
    );
  }

  /// Generates a comprehensive AI analysis of institutional/school-level performance for BRC.
  Future<AiAnalysisResult> generateSchoolAnalysis({
    required String schoolId,
    required String schoolName,
    required double overallPercentage,
    required double coveragePercentage,
    required double remedialCompletionRate,
    required List<String> criticalGapTopics,
    required int totalClasses,
    String languageCode = 'en',
    bool forceRefresh = false,
  }) async {
    final promptText = _buildSchoolPrompt(
      schoolId: schoolId,
      schoolName: schoolName,
      overallPercentage: overallPercentage,
      coveragePercentage: coveragePercentage,
      remedialCompletionRate: remedialCompletionRate,
      criticalGapTopics: criticalGapTopics,
      totalClasses: totalClasses,
      languageCode: languageCode,
    );

    final apiKey = await getApiKey();

    // 1. Cloud Gemini AI
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final onlineResult = await _callGeminiApiWithPrompt(
          apiKey: apiKey,
          promptText: promptText,
        );
        if (onlineResult != null) return onlineResult;
      } catch (e) {
        debugPrint('Gemini school analysis failed, attempting fallback: $e');
      }
    }

    final isGu = languageCode == 'gu';

    String statusNarrative;
    if (overallPercentage < 60.0) {
      statusNarrative = isGu
          ? 'શાળા સ્તરના મૂલ્યાંકનમાં $schoolName ખાતે ગણન અને વાંચન ક્ષમતાઓમાં પડકારો જણાયા છે (સરેરાશ ${overallPercentage.toStringAsFixed(1)}%). ઉપચારાત્મક કાર્ય યોજના પૂર્ણતા દર ${remedialCompletionRate.toStringAsFixed(0)}% છે, જે દર્શાવે છે કે વધુ સંસ્થાકીય ધ્યાન જરૂરી છે.'
          : '$schoolName exhibits critical foundational gaps in numeracy and basic language acquisition (Cluster Average: ${overallPercentage.toStringAsFixed(1)}%). Remedial completion rate is at ${remedialCompletionRate.toStringAsFixed(0)}%, indicating an immediate need for supervisory intervention.';
    } else if (overallPercentage >= 70.0) {
      statusNarrative = isGu
          ? '$schoolName સમગ્ર બ્લોકમાં ઉચ્ચ શૈક્ષણિક પ્રાવીણ્ય (સરેરાશ ${overallPercentage.toStringAsFixed(1)}%) અને ${coveragePercentage.toStringAsFixed(0)}% કવરેજ સાથે અગ્રેસર છે. આ શાળા અન્ય ક્લસ્ટર શાળાઓ માટે પ્રેરણારૂપ છે.'
          : '$schoolName demonstrates exemplary academic mastery with an average score of ${overallPercentage.toStringAsFixed(1)}% and strong assessment coverage of ${coveragePercentage.toStringAsFixed(0)}%. The institution is positioned as a benchmark model for peer cluster schools.';
    } else {
      statusNarrative = isGu
          ? '$schoolName માં સરેરાશ પ્રદર્શન ${overallPercentage.toStringAsFixed(1)}% છે અને મૂલ્યાંકન કવરેજ ${coveragePercentage.toStringAsFixed(0)}% છે. મુખ્ય વિષયોમાં સ્થિર પ્રગતિ છે, પરંતુ વિશિષ્ટ કૌશલ્યોમાં પુનરાવર્તન આવશ્યક છે.'
          : '$schoolName reflects balanced institutional progress at ${overallPercentage.toStringAsFixed(1)}% academic mastery and ${coveragePercentage.toStringAsFixed(0)}% assessment coverage. Core subjects show stability, though targeted reinforcement is needed in foundational competencies.';
    }

    String gapsNarrative = '';
    if (criticalGapTopics.isNotEmpty) {
      gapsNarrative = isGu
          ? ' મુખ્ય સંસ્થાકીય અધ્યયન ક્ષતિઓ: ${criticalGapTopics.join(", ")}. BRC સ્તરે આ વિષયો માટે પ્રવૃત્તિ-આધારિત શિક્ષણ કિટ્સ અને માર્ગદર્શન પૂરાં પાડવાં હિતાવહ છે.'
          : ' Priority institutional learning bottlenecks: ${criticalGapTopics.join(", ")}. Targeted experiential toolkits and micro-learning interventions are required across enrolled grades.';
    }

    final summary = '$statusNarrative$gapsNarrative';

    final List<String> actions = [];
    if (overallPercentage < 60.0) {
      actions.add(
        isGu
            ? 'BRC શિક્ષણશાસ્ત્રીય નિરીક્ષણ મુલાકાત શેડ્યૂલ કરો અને કેલેન્ડર રીમાઇન્ડર સેટ કરો'
            : 'Schedule BRC pedagogical inspection visit and set calendar reminder',
      );
      actions.add(
        isGu
            ? 'મુખ્ય શિક્ષક સાથે દ્વિ-સાપ્તાહિક FLN ઉપચારાત્મક સમીક્ષા બેઠક યોજો'
            : 'Convene bi-weekly FLN remedial progress review with School Headmaster',
      );
      actions.add(
        isGu
            ? 'નબળા વિષયો (${criticalGapTopics.take(2).join(", ")}) માટે મૂર્ત ગણિત અને ભાષા કિટ્સ ફાળવો'
            : 'Dispatch foundational numeracy and language kits for ${criticalGapTopics.take(2).join(", ")}',
      );
    } else if (overallPercentage >= 70.0) {
      actions.add(
        isGu
            ? 'શાળાની સફળ શિક્ષણ પદ્ધતિઓનું દસ્તાવેજીકરણ કરી ક્લસ્ટરમાં શેર કરો'
            : 'Document and share exemplary pedagogical practices across cluster schools',
      );
      actions.add(
        isGu
            ? 'પ્રતિભાશાળી શિક્ષકોને નબળી શાળાઓના માર્ગદર્શક (પીઅર મેન્ટર) તરીકે નિયુક્ત કરો'
            : 'Enlist lead educators as peer mentors for lower-performing cluster schools',
      );
      actions.add(
        isGu
            ? 'વિદ્યાર્થીઓ માટે ઉચ્ચ સ્તરીય જ્ઞાનવર્ધક પડકારો અને ક્વિઝ સ્પર્ધા આયોજિત કરો'
            : 'Introduce advanced learning challenges and inter-school academic fairs',
      );
    } else {
      actions.add(
        isGu
            ? 'નિયમિત નિરીક્ષણ મુલાકાતનું આયોજન કરો અને વર્ગખંડ શિક્ષણનું મૂલ્યાંકન કરો'
            : 'Schedule routine supervisory visit to audit classroom teaching practices',
      );
      actions.add(
        isGu
            ? 'સાપ્તાહિક ઉપચારાત્મક ક્વિઝ અને ગૃહ પ્રવૃત્તિઓના અમલીકરણની ચકાસણી કરો'
            : 'Verify implementation of weekly remedial quizzes and parent engagement activities',
      );
      actions.add(
        isGu
            ? 'મૂલ્યાંકન કવરેજ દર ૯૦% થી ઉપર લઈ જવા શિક્ષકોને પ્રેરિત કરો'
            : 'Encourage teaching staff to drive assessment coverage above 90% benchmark',
      );
    }

    return AiAnalysisResult(
      summary: summary,
      recommendedActions: actions,
      isOnlineAi: false,
      modelName: _fallbackModelName,
    );
  }
}

