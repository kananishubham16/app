// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Learning Setu';

  @override
  String get home => 'Home';

  @override
  String get subjects => 'Subjects';

  @override
  String get performance => 'Performance';

  @override
  String get profile => 'Profile';

  @override
  String get results => 'Results';

  @override
  String get performanceAnalysis => 'Performance Analysis';

  @override
  String get remedialActivities => 'Remedial Activities & Quizzes';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get tryDemo => 'Try Demo';

  @override
  String get email => 'Email / Mobile Number';

  @override
  String get password => 'Password';

  @override
  String get teacher => 'Primary School Teacher';

  @override
  String get principal => 'School Principal';

  @override
  String get brc => 'Block Resource Coordinator';

  @override
  String get parent => 'Parent';

  @override
  String get welcome => 'Welcome to Learning Setu';

  @override
  String get selectRole => 'Select your role to continue';

  @override
  String get mathematics => 'Mathematics';

  @override
  String get gujarati => 'Gujarati';

  @override
  String get english => 'English';

  @override
  String get environmentalStudies => 'Environmental Studies';

  @override
  String get weak => 'Weak';

  @override
  String get average => 'Average';

  @override
  String get strong => 'Strong';

  @override
  String get notAssessed => 'Not Assessed';

  @override
  String get viewStudent => 'View Student';

  @override
  String get addAssessment => 'Add Assessment';

  @override
  String get assignPractice => 'Assign Practice';

  @override
  String get resetDemoData => 'Reset Demo Data';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get submit => 'Submit';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No data available';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get quizComplete => 'Quiz Complete!';

  @override
  String get score => 'Score';

  @override
  String get practiceWeakTopics => 'Practice Weak Topics';

  @override
  String get readyForReassessment => 'Ready for reassessment';

  @override
  String get furtherPracticeRecommended => 'Further practice recommended';

  @override
  String get insufficientData => 'Insufficient data';

  @override
  String get demoNote => 'Demo Mode — Authentication is simulated';

  @override
  String get language => 'Language';

  @override
  String get tagline =>
      'Smart Tracking & Remedial Action System for Student Learning Gaps';

  @override
  String get appSubtitle =>
      'An educational bridge connecting classroom diagnostics with targeted micro-interventions, adaptive quizzes, and analytics.';

  @override
  String get teacherDashboard => 'Teacher Dashboard';

  @override
  String get principalDashboard => 'Principal Dashboard';

  @override
  String get brcDashboard => 'BRC Dashboard';

  @override
  String get parentDashboard => 'Parent Dashboard';

  @override
  String get selectClass => 'Select Class';

  @override
  String get selectedClass => 'Selected Class';

  @override
  String get studentsInClass => 'Students in Class';

  @override
  String get studentsAssessed => 'Assessed';

  @override
  String get needSupport => 'Need Support';

  @override
  String get pendingRemedials => 'Pending Remedials';

  @override
  String get recentAssessments => 'Recent Assessments';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get curriculumSubjects => 'Curriculum Subjects';

  @override
  String get classPerformanceOverview => 'Class Performance Overview';

  @override
  String get totalSchools => 'Total Schools';

  @override
  String get schoolsInBlock => 'Schools in Block';

  @override
  String get schoolsAssessed => 'Schools Assessed';

  @override
  String get assessmentCoverage => 'Assessment Coverage';

  @override
  String get avgBlockScore => 'Avg Block Score';

  @override
  String get prioritySupportSchools => 'Priority Support Schools';

  @override
  String get schoolPerformanceComparisons => 'School Performance Comparisons';

  @override
  String get allSubjects => 'All Subjects';

  @override
  String get subjectsAndCurriculum => 'Subjects & Curriculum';

  @override
  String get classSubjectsOverview => 'Class Subjects Overview';

  @override
  String get keyTopics => 'Key Topics';

  @override
  String get viewDetails => 'View Details';

  @override
  String get englishLanguage => 'English';

  @override
  String get gujaratiLanguage => 'ગુજરાતી';

  @override
  String get activeAssignments => 'Active assignments';

  @override
  String get belowThreshold => 'Below 40% threshold';

  @override
  String coveragePercent(int percent) {
    return '$percent% coverage';
  }

  @override
  String get tapStudentDiagnostics =>
      'Tap a student to view learning gaps & diagnostics';

  @override
  String get latestEvaluations => 'Latest evaluations submitted';

  @override
  String get viewAll => 'View All';

  @override
  String allSubjectsInGrade(int count) {
    return 'All $count subjects taught in this grade';
  }

  @override
  String get myAssignedSubjects => 'My Assigned Subjects';

  @override
  String get allCurriculumSubjects => 'All Curriculum Subjects';

  @override
  String get searchStudentHint => 'Search student by name or enrollment ID...';

  @override
  String get noStudentsFound => 'No Students Found';

  @override
  String get superviseQuiz => 'Supervise Quiz';

  @override
  String get startHomeQuiz => 'Start Home Quiz';

  @override
  String get quizAssignedObserver =>
      'Quiz Assigned (Supervised by Teacher / Parent)';

  @override
  String get practiceWeakTopic => 'Practice Weak Topic';

  @override
  String get remedialObservation =>
      'Remedial quizzes are conducted by teachers in class or parents at home.';

  @override
  String get selectSchool => 'Select School';

  @override
  String get allSchools => 'All Schools';

  @override
  String get allClasses => 'All Classes';

  @override
  String get curriculumOverview => 'Curriculum Overview';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get assignRemedial => 'Assign Remedial';

  @override
  String get remedialInterventions => 'Remedial Interventions';

  @override
  String get noActionsFound => 'No Actions Found';

  @override
  String get performanceDiagnostic => 'Performance Diagnostic';

  @override
  String get generatingAnalysis => 'Generating AI-powered analysis...';

  @override
  String get noPerformanceData => 'No Performance Data';

  @override
  String get selectStudentToAnalyze => 'Select Student to Analyze';

  @override
  String get viewingStudent => 'Viewing Student';

  @override
  String get generalView => 'General View (No student selected)';

  @override
  String get selectStudent => 'Select Student';

  @override
  String get academicPerformanceAvg => 'Academic Performance Average';

  @override
  String get assessmentCoverageRate => 'Assessment Coverage Rate';

  @override
  String get statusLabel => 'Status';

  @override
  String get viewAnalytics => 'View Analytics';

  @override
  String get subjectWiseClassAverages => 'Subject-wise Class Averages';

  @override
  String get basedOnLatestAssessments =>
      'Based on latest regular assessment scores across all subjects';

  @override
  String get ruleBasedNotice =>
      'AI-Powered Diagnostics: Powered by Gemini & Cognitive Pedagogical Engine.';

  @override
  String get aiPoweredNotice =>
      'Analysis and targeted micro-interventions generated using AI diagnostics (Gemini 1.5 Flash & Pedagogical Engine).';

  @override
  String get aiPoweredDiagnostic => 'AI-Powered Diagnostic';

  @override
  String get aiReanalyze => 'AI Re-analyze';

  @override
  String get aiDiagnosticSummary => 'AI Diagnostic Assessment Summary';

  @override
  String get aiEngine => 'AI Diagnostic Engine';

  @override
  String get aiEngineSubtitle => 'Gemini 1.5 Flash & Cognitive Synthesis';

  @override
  String get geminiApiKey => 'Gemini API Key (Optional)';

  @override
  String get geminiApiKeyHint => 'Enter your Google Gemini API key';

  @override
  String get apiKeySaved => 'API Key saved successfully';

  @override
  String get apiKeyCleared => 'API Key cleared';

  @override
  String get assignedStatus => 'Assigned';

  @override
  String get inProgressStatus => 'In Progress';

  @override
  String get completedStatus => 'Completed';

  @override
  String get needsFollowUpStatus => 'Needs Follow-up';
}
