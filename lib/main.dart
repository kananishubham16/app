import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/app/app_router.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/quiz_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/school_provider.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/providers/parent_review_provider.dart';
import 'package:learning_setu/providers/holistic_provider.dart';

import 'package:learning_setu/repositories/repositories.dart';

import 'package:learning_setu/services/performance_service.dart';
import 'package:learning_setu/services/storage_service.dart';

import 'package:flutter/services.dart';

/// EduTrack - Smart Tracking and Remedial Action System
/// for Student Learning Gaps in Primary Schools.
///
/// Problem ID: PS000060 | SFIC Hackathon 2026
///
/// Redesigned specifically for Android Mobile & Web:
/// - Locked to portrait mode for standard Android phones
/// - Material 3 system bar integration with transparent navigation
/// - Zero-overflow layouts adapted for compact to large viewports
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env file with GEMINI_API_KEY etc.)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env file may not exist in production/web; keys can be set via Settings UI
  }

  // Mobile specific configuration: Lock to portrait (safely ignored on web)
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (_) {}

  // System UI overlay style
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  } catch (_) {}

  runApp(const EduTrackApp());
}

class EduTrackApp extends StatelessWidget {
  final AuthRepository? authRepo;
  final StudentRepository? studentRepo;
  final AssessmentRepository? assessmentRepo;
  final QuizRepository? quizRepo;
  final RemedialRepository? remedialRepo;
  final SchoolRepository? schoolRepo;

  const EduTrackApp({
    super.key,
    this.authRepo,
    this.studentRepo,
    this.assessmentRepo,
    this.quizRepo,
    this.remedialRepo,
    this.schoolRepo,
  });

  @override
  Widget build(BuildContext context) {
    bool useLiveApi = false;
    try {
      if (dotenv.isInitialized) {
        useLiveApi = dotenv.env['USE_LIVE_API'] == 'true';
      }
    } catch (_) {}

    // On Web (GitHub Pages / browser), default to complete standalone offline mock mode
    if (kIsWeb) {
      useLiveApi = false;
    }

    final apiClient = ApiClient();

    // Initialize repositories (live API with automatic mock fallback)
    final effectiveAuthRepo = authRepo ??
        (useLiveApi ? ApiAuthRepository(client: apiClient) : MockAuthRepository());
    final effectiveStudentRepo = studentRepo ??
        (useLiveApi ? ApiStudentRepository(client: apiClient) : MockStudentRepository());
    final effectiveAssessmentRepo = assessmentRepo ??
        (useLiveApi ? ApiAssessmentRepository(client: apiClient) : MockAssessmentRepository());
    final effectiveQuizRepo = quizRepo ??
        (useLiveApi ? ApiQuizRepository(client: apiClient) : MockQuizRepository());
    final effectiveRemedialRepo = remedialRepo ??
        (useLiveApi ? ApiRemedialRepository(client: apiClient) : MockRemedialRepository());
    final effectiveSchoolRepo = schoolRepo ??
        (useLiveApi ? ApiSchoolRepository(client: apiClient) : MockSchoolRepository());

    // Initialize services
    final storageService = StorageService();
    final performanceService = PerformanceService(effectiveAssessmentRepo, effectiveSchoolRepo);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(effectiveAuthRepo, storageService),
        ),
        ChangeNotifierProvider(create: (_) => StudentProvider(effectiveStudentRepo)),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(effectiveAssessmentRepo, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(effectiveQuizRepo, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => RemedialProvider(effectiveRemedialRepo, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PerformanceProvider(performanceService),
        ),
        ChangeNotifierProvider(create: (_) => SchoolProvider(effectiveSchoolRepo)),
        ChangeNotifierProvider(
          create: (_) => ParentReviewProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => HolisticProvider(storageService),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'EduTrack',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRouter.welcome,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}


typedef LearningSetu = EduTrackApp;
