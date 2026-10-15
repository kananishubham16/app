import 'package:flutter/material.dart';
import 'package:learning_setu/screens/auth/welcome_screen.dart';
import 'package:learning_setu/screens/auth/login_screen.dart';
import 'package:learning_setu/screens/dashboards/teacher_dashboard.dart';
import 'package:learning_setu/screens/dashboards/principal_dashboard.dart';
import 'package:learning_setu/screens/dashboards/brc_dashboard.dart';
import 'package:learning_setu/screens/dashboards/parent_dashboard.dart';
import 'package:learning_setu/screens/students/student_detail_screen.dart';
import 'package:learning_setu/screens/subjects/subject_detail_screen.dart';
import 'package:learning_setu/screens/subjects/subjects_screen.dart';
import 'package:learning_setu/screens/results/results_screen.dart';
import 'package:learning_setu/screens/results/add_assessment_screen.dart';
import 'package:learning_setu/screens/performance/performance_screen.dart';
import 'package:learning_setu/screens/quizzes/quiz_screen.dart';
import 'package:learning_setu/screens/quizzes/quiz_result_screen.dart';
import 'package:learning_setu/screens/remedial/remedial_screen.dart';
import 'package:learning_setu/screens/remedial/assign_remedial_screen.dart';
import 'package:learning_setu/screens/profile/profile_screen.dart';
import 'package:learning_setu/screens/profile/settings_screen.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/models/subject_model.dart';

class AppRouter {
  static const String welcome = '/';
  static const String login = '/login';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String principalDashboard = '/principal-dashboard';
  static const String brcDashboard = '/brc-dashboard';
  static const String parentDashboard = '/parent-dashboard';
  static const String studentDetail = '/student-detail';
  static const String subjectDetail = '/subject-detail';
  static const String subjects = '/subjects';
  static const String results = '/results';
  static const String addAssessment = '/add-assessment';
  static const String performance = '/performance';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz-result';
  static const String remedial = '/remedial';
  static const String assignRemedial = '/assign-remedial';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static String dashboardRoute(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return teacherDashboard;
      case UserRole.principal:
        return principalDashboard;
      case UserRole.brc:
        return brcDashboard;
      case UserRole.parent:
        return parentDashboard;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        final role = settings.arguments as UserRole;
        return MaterialPageRoute(builder: (_) => LoginScreen(role: role));
      case teacherDashboard:
        return MaterialPageRoute(builder: (_) => const TeacherDashboard());
      case principalDashboard:
        return MaterialPageRoute(builder: (_) => const PrincipalDashboard());
      case brcDashboard:
        return MaterialPageRoute(builder: (_) => const BrcDashboard());
      case parentDashboard:
        return MaterialPageRoute(builder: (_) => const ParentDashboard());
      case studentDetail:
        final studentId = settings.arguments is String
            ? settings.arguments as String
            : (settings.arguments as Map?)?['studentId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => StudentDetailScreen(studentId: studentId),
        );
      case subjectDetail:
        final args = settings.arguments is Map ? settings.arguments as Map : {};
        return MaterialPageRoute(
          builder: (_) => SubjectDetailScreen(
            subjectId: args['subjectId'] as String?,
            studentId: args['studentId'] as String?,
            subject: args['subject'] as SubjectModel?,
          ),
        );
      case AppRouter.subjects:
        return MaterialPageRoute(builder: (_) => const SubjectsScreen());
      case results:
        return MaterialPageRoute(builder: (_) => const ResultsScreen());
      case addAssessment:
        final studentId = settings.arguments is String
            ? settings.arguments as String
            : (settings.arguments as Map?)?['studentId'] as String?;
        return MaterialPageRoute(
          builder: (_) => AddAssessmentScreen(studentId: studentId),
        );
      case performance:
        final studentId = settings.arguments is String
            ? settings.arguments as String
            : (settings.arguments as Map?)?['studentId'] as String?;
        return MaterialPageRoute(
          builder: (_) => PerformanceScreen(studentId: studentId),
        );
      case quiz:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuizScreen(
            studentId: args['studentId'] as String,
            subjectId: args['subjectId'] as String,
            topicId: args['topicId'] as String,
            topicName: args['topicName'] as String,
            classId: args['classId'] as String,
            remedialActionId: args['remedialActionId'] as String?,
          ),
        );
      case quizResult:
        return MaterialPageRoute(builder: (_) => const QuizResultScreen());
      case remedial:
        return MaterialPageRoute(builder: (_) => const RemedialScreen());
      case assignRemedial:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AssignRemedialScreen(
            studentId: args?['studentId'] as String?,
            subjectId: args?['subjectId'] as String?,
            topicId: args?['topicId'] as String?,
          ),
        );
      case AppRouter.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
