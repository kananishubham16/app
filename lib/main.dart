import 'package:flutter/material.dart';
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

import 'package:learning_setu/repositories/mock/mock_auth_repository.dart';
import 'package:learning_setu/repositories/mock/mock_student_repository.dart';
import 'package:learning_setu/repositories/mock/mock_assessment_repository.dart';
import 'package:learning_setu/repositories/mock/mock_quiz_repository.dart';
import 'package:learning_setu/repositories/mock/mock_remedial_repository.dart';
import 'package:learning_setu/repositories/mock/mock_school_repository.dart';

import 'package:learning_setu/services/performance_service.dart';
import 'package:learning_setu/services/storage_service.dart';

import 'package:flutter/services.dart';

/// Learning Setu - Smart Tracking and Remedial Action System
/// for Student Learning Gaps in Primary Schools.
///
/// Problem ID: PS000060 | SFIC Hackathon 2026
///
/// Redesigned specifically for Android Mobile:
/// - Locked to portrait mode for standard Android phones
/// - Material 3 system bar integration with transparent navigation
/// - Zero-overflow layouts adapted for compact to large Android viewports
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env file with GEMINI_API_KEY etc.)
  await dotenv.load(fileName: '.env').catchError((_) {
    // .env file may not exist in production; keys can be set via Settings UI
  });

  // Android Mobile specific configuration: Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Android Material 3 system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const LearningSetu());
}

class LearningSetu extends StatelessWidget {
  const LearningSetu({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories (mock implementations)
    final authRepo = MockAuthRepository();
    final studentRepo = MockStudentRepository();
    final assessmentRepo = MockAssessmentRepository();
    final quizRepo = MockQuizRepository();
    final remedialRepo = MockRemedialRepository();
    final schoolRepo = MockSchoolRepository();

    // Initialize services
    final storageService = StorageService();
    final performanceService = PerformanceService(assessmentRepo, schoolRepo);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepo, storageService),
        ),
        ChangeNotifierProvider(create: (_) => StudentProvider(studentRepo)),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(assessmentRepo, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(quizRepo, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => RemedialProvider(remedialRepo, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PerformanceProvider(performanceService),
        ),
        ChangeNotifierProvider(create: (_) => SchoolProvider(schoolRepo)),
        ChangeNotifierProvider(
          create: (_) => ParentReviewProvider(storageService),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'Learning Setu',
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
