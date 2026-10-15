import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Setu'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @performanceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Performance Analysis'**
  String get performanceAnalysis;

  /// No description provided for @remedialActivities.
  ///
  /// In en, this message translates to:
  /// **'Remedial Activities & Quizzes'**
  String get remedialActivities;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @tryDemo.
  ///
  /// In en, this message translates to:
  /// **'Try Demo'**
  String get tryDemo;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email / Mobile Number'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Primary School Teacher'**
  String get teacher;

  /// No description provided for @principal.
  ///
  /// In en, this message translates to:
  /// **'School Principal'**
  String get principal;

  /// No description provided for @brc.
  ///
  /// In en, this message translates to:
  /// **'Block Resource Coordinator'**
  String get brc;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Learning Setu'**
  String get welcome;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role to continue'**
  String get selectRole;

  /// No description provided for @mathematics.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get mathematics;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @environmentalStudies.
  ///
  /// In en, this message translates to:
  /// **'Environmental Studies'**
  String get environmentalStudies;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @notAssessed.
  ///
  /// In en, this message translates to:
  /// **'Not Assessed'**
  String get notAssessed;

  /// No description provided for @viewStudent.
  ///
  /// In en, this message translates to:
  /// **'View Student'**
  String get viewStudent;

  /// No description provided for @addAssessment.
  ///
  /// In en, this message translates to:
  /// **'Add Assessment'**
  String get addAssessment;

  /// No description provided for @assignPractice.
  ///
  /// In en, this message translates to:
  /// **'Assign Practice'**
  String get assignPractice;

  /// No description provided for @resetDemoData.
  ///
  /// In en, this message translates to:
  /// **'Reset Demo Data'**
  String get resetDemoData;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @quizComplete.
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @practiceWeakTopics.
  ///
  /// In en, this message translates to:
  /// **'Practice Weak Topics'**
  String get practiceWeakTopics;

  /// No description provided for @readyForReassessment.
  ///
  /// In en, this message translates to:
  /// **'Ready for reassessment'**
  String get readyForReassessment;

  /// No description provided for @furtherPracticeRecommended.
  ///
  /// In en, this message translates to:
  /// **'Further practice recommended'**
  String get furtherPracticeRecommended;

  /// No description provided for @insufficientData.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data'**
  String get insufficientData;

  /// No description provided for @demoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo Mode — Authentication is simulated'**
  String get demoNote;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Tracking & Remedial Action System for Student Learning Gaps'**
  String get tagline;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An educational bridge connecting classroom diagnostics with targeted micro-interventions, adaptive quizzes, and analytics.'**
  String get appSubtitle;

  /// No description provided for @teacherDashboard.
  ///
  /// In en, this message translates to:
  /// **'Teacher Dashboard'**
  String get teacherDashboard;

  /// No description provided for @principalDashboard.
  ///
  /// In en, this message translates to:
  /// **'Principal Dashboard'**
  String get principalDashboard;

  /// No description provided for @brcDashboard.
  ///
  /// In en, this message translates to:
  /// **'BRC Dashboard'**
  String get brcDashboard;

  /// No description provided for @parentDashboard.
  ///
  /// In en, this message translates to:
  /// **'Parent Dashboard'**
  String get parentDashboard;

  /// No description provided for @selectClass.
  ///
  /// In en, this message translates to:
  /// **'Select Class'**
  String get selectClass;

  /// No description provided for @selectedClass.
  ///
  /// In en, this message translates to:
  /// **'Selected Class'**
  String get selectedClass;

  /// No description provided for @studentsInClass.
  ///
  /// In en, this message translates to:
  /// **'Students in Class'**
  String get studentsInClass;

  /// No description provided for @studentsAssessed.
  ///
  /// In en, this message translates to:
  /// **'Assessed'**
  String get studentsAssessed;

  /// No description provided for @needSupport.
  ///
  /// In en, this message translates to:
  /// **'Need Support'**
  String get needSupport;

  /// No description provided for @pendingRemedials.
  ///
  /// In en, this message translates to:
  /// **'Pending Remedials'**
  String get pendingRemedials;

  /// No description provided for @recentAssessments.
  ///
  /// In en, this message translates to:
  /// **'Recent Assessments'**
  String get recentAssessments;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @curriculumSubjects.
  ///
  /// In en, this message translates to:
  /// **'Curriculum Subjects'**
  String get curriculumSubjects;

  /// No description provided for @classPerformanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Class Performance Overview'**
  String get classPerformanceOverview;

  /// No description provided for @totalSchools.
  ///
  /// In en, this message translates to:
  /// **'Total Schools'**
  String get totalSchools;

  /// No description provided for @schoolsInBlock.
  ///
  /// In en, this message translates to:
  /// **'Schools in Block'**
  String get schoolsInBlock;

  /// No description provided for @schoolsAssessed.
  ///
  /// In en, this message translates to:
  /// **'Schools Assessed'**
  String get schoolsAssessed;

  /// No description provided for @assessmentCoverage.
  ///
  /// In en, this message translates to:
  /// **'Assessment Coverage'**
  String get assessmentCoverage;

  /// No description provided for @avgBlockScore.
  ///
  /// In en, this message translates to:
  /// **'Avg Block Score'**
  String get avgBlockScore;

  /// No description provided for @prioritySupportSchools.
  ///
  /// In en, this message translates to:
  /// **'Priority Support Schools'**
  String get prioritySupportSchools;

  /// No description provided for @schoolPerformanceComparisons.
  ///
  /// In en, this message translates to:
  /// **'School Performance Comparisons'**
  String get schoolPerformanceComparisons;

  /// No description provided for @allSubjects.
  ///
  /// In en, this message translates to:
  /// **'All Subjects'**
  String get allSubjects;

  /// No description provided for @subjectsAndCurriculum.
  ///
  /// In en, this message translates to:
  /// **'Subjects & Curriculum'**
  String get subjectsAndCurriculum;

  /// No description provided for @classSubjectsOverview.
  ///
  /// In en, this message translates to:
  /// **'Class Subjects Overview'**
  String get classSubjectsOverview;

  /// No description provided for @keyTopics.
  ///
  /// In en, this message translates to:
  /// **'Key Topics'**
  String get keyTopics;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @gujaratiLanguage.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get gujaratiLanguage;

  /// No description provided for @activeAssignments.
  ///
  /// In en, this message translates to:
  /// **'Active assignments'**
  String get activeAssignments;

  /// No description provided for @belowThreshold.
  ///
  /// In en, this message translates to:
  /// **'Below 40% threshold'**
  String get belowThreshold;

  /// No description provided for @coveragePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% coverage'**
  String coveragePercent(int percent);

  /// No description provided for @tapStudentDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Tap a student to view learning gaps & diagnostics'**
  String get tapStudentDiagnostics;

  /// No description provided for @latestEvaluations.
  ///
  /// In en, this message translates to:
  /// **'Latest evaluations submitted'**
  String get latestEvaluations;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @allSubjectsInGrade.
  ///
  /// In en, this message translates to:
  /// **'All {count} subjects taught in this grade'**
  String allSubjectsInGrade(int count);

  /// No description provided for @myAssignedSubjects.
  ///
  /// In en, this message translates to:
  /// **'My Assigned Subjects'**
  String get myAssignedSubjects;

  /// No description provided for @allCurriculumSubjects.
  ///
  /// In en, this message translates to:
  /// **'All Curriculum Subjects'**
  String get allCurriculumSubjects;

  /// No description provided for @searchStudentHint.
  ///
  /// In en, this message translates to:
  /// **'Search student by name or enrollment ID...'**
  String get searchStudentHint;

  /// No description provided for @noStudentsFound.
  ///
  /// In en, this message translates to:
  /// **'No Students Found'**
  String get noStudentsFound;

  /// No description provided for @superviseQuiz.
  ///
  /// In en, this message translates to:
  /// **'Supervise Quiz'**
  String get superviseQuiz;

  /// No description provided for @startHomeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Home Quiz'**
  String get startHomeQuiz;

  /// No description provided for @quizAssignedObserver.
  ///
  /// In en, this message translates to:
  /// **'Quiz Assigned (Supervised by Teacher / Parent)'**
  String get quizAssignedObserver;

  /// No description provided for @practiceWeakTopic.
  ///
  /// In en, this message translates to:
  /// **'Practice Weak Topic'**
  String get practiceWeakTopic;

  /// No description provided for @remedialObservation.
  ///
  /// In en, this message translates to:
  /// **'Remedial quizzes are conducted by teachers in class or parents at home.'**
  String get remedialObservation;

  /// No description provided for @selectSchool.
  ///
  /// In en, this message translates to:
  /// **'Select School'**
  String get selectSchool;

  /// No description provided for @allSchools.
  ///
  /// In en, this message translates to:
  /// **'All Schools'**
  String get allSchools;

  /// No description provided for @allClasses.
  ///
  /// In en, this message translates to:
  /// **'All Classes'**
  String get allClasses;

  /// No description provided for @curriculumOverview.
  ///
  /// In en, this message translates to:
  /// **'Curriculum Overview'**
  String get curriculumOverview;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @assignRemedial.
  ///
  /// In en, this message translates to:
  /// **'Assign Remedial'**
  String get assignRemedial;

  /// No description provided for @remedialInterventions.
  ///
  /// In en, this message translates to:
  /// **'Remedial Interventions'**
  String get remedialInterventions;

  /// No description provided for @noActionsFound.
  ///
  /// In en, this message translates to:
  /// **'No Actions Found'**
  String get noActionsFound;

  /// No description provided for @performanceDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Performance Diagnostic'**
  String get performanceDiagnostic;

  /// No description provided for @generatingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Generating AI-powered analysis...'**
  String get generatingAnalysis;

  /// No description provided for @noPerformanceData.
  ///
  /// In en, this message translates to:
  /// **'No Performance Data'**
  String get noPerformanceData;

  /// No description provided for @selectStudentToAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Select Student to Analyze'**
  String get selectStudentToAnalyze;

  /// No description provided for @viewingStudent.
  ///
  /// In en, this message translates to:
  /// **'Viewing Student'**
  String get viewingStudent;

  /// No description provided for @generalView.
  ///
  /// In en, this message translates to:
  /// **'General View (No student selected)'**
  String get generalView;

  /// No description provided for @selectStudent.
  ///
  /// In en, this message translates to:
  /// **'Select Student'**
  String get selectStudent;

  /// No description provided for @academicPerformanceAvg.
  ///
  /// In en, this message translates to:
  /// **'Academic Performance Average'**
  String get academicPerformanceAvg;

  /// No description provided for @assessmentCoverageRate.
  ///
  /// In en, this message translates to:
  /// **'Assessment Coverage Rate'**
  String get assessmentCoverageRate;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get viewAnalytics;

  /// No description provided for @subjectWiseClassAverages.
  ///
  /// In en, this message translates to:
  /// **'Subject-wise Class Averages'**
  String get subjectWiseClassAverages;

  /// No description provided for @basedOnLatestAssessments.
  ///
  /// In en, this message translates to:
  /// **'Based on latest regular assessment scores across all subjects'**
  String get basedOnLatestAssessments;

  /// No description provided for @ruleBasedNotice.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Diagnostics: Powered by Gemini & Cognitive Pedagogical Engine.'**
  String get ruleBasedNotice;

  /// No description provided for @aiPoweredNotice.
  ///
  /// In en, this message translates to:
  /// **'Analysis and targeted micro-interventions generated using AI diagnostics (Gemini 1.5 Flash & Pedagogical Engine).'**
  String get aiPoweredNotice;

  /// No description provided for @aiPoweredDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Diagnostic'**
  String get aiPoweredDiagnostic;

  /// No description provided for @aiReanalyze.
  ///
  /// In en, this message translates to:
  /// **'AI Re-analyze'**
  String get aiReanalyze;

  /// No description provided for @aiDiagnosticSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnostic Assessment Summary'**
  String get aiDiagnosticSummary;

  /// No description provided for @aiEngine.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnostic Engine'**
  String get aiEngine;

  /// No description provided for @aiEngineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gemini 1.5 Flash & Cognitive Synthesis'**
  String get aiEngineSubtitle;

  /// No description provided for @geminiApiKey.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key (Optional)'**
  String get geminiApiKey;

  /// No description provided for @geminiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Google Gemini API key'**
  String get geminiApiKeyHint;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API Key saved successfully'**
  String get apiKeySaved;

  /// No description provided for @apiKeyCleared.
  ///
  /// In en, this message translates to:
  /// **'API Key cleared'**
  String get apiKeyCleared;

  /// No description provided for @assignedStatus.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assignedStatus;

  /// No description provided for @inProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressStatus;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @needsFollowUpStatus.
  ///
  /// In en, this message translates to:
  /// **'Needs Follow-up'**
  String get needsFollowUpStatus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
