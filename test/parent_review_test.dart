import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_setu/l10n/app_localizations.dart';
import 'package:learning_setu/models/models.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/parent_review_provider.dart';
import 'package:learning_setu/repositories/mock/mock_auth_repository.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:learning_setu/widgets/parent_review_box.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Parent Review Model & Provider Tests', () {
    test('ParentReviewModel serialization and deserialization', () {
      final now = DateTime.now();
      final review = ParentReviewModel(
        id: 'rev_1',
        studentId: 'student_1',
        subjectId: 'subject_math',
        parentName: 'Ramesh Patel',
        reviewText: 'Great improvement in addition.',
        createdAt: now,
        isAcknowledged: true,
        acknowledgedBy: 'Anita Sharma',
      );

      final json = review.toJson();
      final deserialized = ParentReviewModel.fromJson(json);

      expect(deserialized.id, 'rev_1');
      expect(deserialized.studentId, 'student_1');
      expect(deserialized.subjectId, 'subject_math');
      expect(deserialized.parentName, 'Ramesh Patel');
      expect(deserialized.reviewText, 'Great improvement in addition.');
      expect(deserialized.isAcknowledged, true);
      expect(deserialized.acknowledgedBy, 'Anita Sharma');
    });

    test('ParentReviewProvider loads seeds and adds/updates review', () async {
      final storage = StorageService();
      final provider = ParentReviewProvider(storage);
      await provider.loadReviews();

      // Seed reviews exist
      final mathReview = provider.getReview('student_1', 'subject_math');
      expect(mathReview, isNotNull);
      expect(mathReview!.reviewText, contains('Aarav is practicing'));

      // Submit new review
      await provider.submitOrUpdateReview(
        studentId: 'student_3',
        subjectId: 'subject_evs',
        parentName: 'Sunita Verma',
        reviewText: 'Sunita loved the plant labeling activity.',
      );

      final evsReview = provider.getReview('student_3', 'subject_evs');
      expect(evsReview, isNotNull);
      expect(evsReview!.reviewText, 'Sunita loved the plant labeling activity.');
      expect(evsReview.isAcknowledged, false);

      // Acknowledge review
      await provider.toggleAcknowledge(evsReview.id, 'Ramesh Solanki');
      final updated = provider.getReview('student_3', 'subject_evs');
      expect(updated!.isAcknowledged, true);
      expect(updated.acknowledgedBy, 'Ramesh Solanki');
    });
  });

  Widget buildTestWidget({
    required UserRole role,
    String? userId,
    required String studentId,
    required String subjectId,
    required String subjectName,
    required ParentReviewProvider reviewProv,
    Locale? locale,
  }) {
    final authRepo = MockAuthRepository();
    final storageService = StorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final auth = AuthProvider(authRepo, storageService);
            auth.demoLogin(role, userId: userId);
            return auth;
          },
        ),
        ChangeNotifierProvider<ParentReviewProvider>.value(value: reviewProv),
      ],
      child: MaterialApp(
        locale: locale ?? const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ParentReviewBox(
              studentId: studentId,
              subjectId: subjectId,
              subjectName: subjectName,
            ),
          ),
        ),
      ),
    );
  }

  group('ParentReviewBox Privacy & Role Enforcement Widget Tests', () {
    testWidgets('Parent can view review box and write/submit a review',
        (tester) async {
      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.parent,
          studentId: 'student_5',
          subjectId: 'subject_eng',
          subjectName: 'English',
          reviewProv: reviewProv,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Parent sees the review box header
      expect(find.textContaining('Parent Review Box for English Teacher'),
          findsOneWidget);
      expect(
        find.textContaining('Private: Seen exclusively by the assigned English teacher'),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Submit Review'), findsOneWidget);

      // Enter review text
      await tester.enterText(
        find.byType(TextFormField),
        'Needs more practice with short vowel phonics.',
      );
      await tester.tap(find.text('Submit Review'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Review is now displayed
      expect(find.text('“Needs more practice with short vowel phonics.”'),
          findsOneWidget);
    });

    testWidgets(
        'Assigned subject teacher CAN view parent review and acknowledge it',
        (tester) async {
      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      // Anita Sharma is assigned to subject_math
      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.teacher,
          userId: 'user_teacher',
          studentId: 'student_1',
          subjectId: 'subject_math',
          subjectName: 'Mathematics',
          reviewProv: reviewProv,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Teacher sees parent review
      expect(find.textContaining("Parent's Review (Confidential for Your Subject)"),
          findsOneWidget);
      expect(find.textContaining('Aarav is practicing single-digit additions'),
          findsOneWidget);
      expect(find.text('Teacher Only'), findsOneWidget);
      expect(find.text('Acknowledged'), findsOneWidget);
    });

    testWidgets(
        'Teacher of DIFFERENT subject CANNOT view parent review (strictly confidential)',
        (tester) async {
      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      // Bhavna Joshi teaches ONLY Gujarati (subject_guj)
      // Math (subject_math) is NOT taught by Bhavna Joshi!
      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.teacher,
          userId: 'user_teacher_guj',
          studentId: 'student_1',
          subjectId: 'subject_math',
          subjectName: 'Mathematics',
          reviewProv: reviewProv,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Confidential: Nothing should be displayed for unassigned teacher!
      expect(find.textContaining("Parent's Review"), findsNothing);
      expect(find.textContaining('Aarav is practicing'), findsNothing);
      expect(find.text('Teacher Only'), findsNothing);
    });

    testWidgets(
        'Principal CANNOT view private subject teacher reviews (confidential)',
        (tester) async {
      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.principal,
          studentId: 'student_1',
          subjectId: 'subject_math',
          subjectName: 'Mathematics',
          reviewProv: reviewProv,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Confidential: Nothing rendered
      expect(find.textContaining("Parent's Review"), findsNothing);
      expect(find.textContaining('Aarav is practicing'), findsNothing);
    });

    testWidgets(
        'BRC Observer CANNOT view private subject teacher reviews (confidential)',
        (tester) async {
      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.brc,
          studentId: 'student_1',
          subjectId: 'subject_math',
          subjectName: 'Mathematics',
          reviewProv: reviewProv,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Confidential: Nothing rendered
      expect(find.textContaining("Parent's Review"), findsNothing);
      expect(find.textContaining('Aarav is practicing'), findsNothing);
    });
  });

  group('ParentReviewBox Responsive Mobile Viewport Stress Tests', () {
    testWidgets('Teacher section: 320px screen width in Gujarati has zero layout overflows',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.teacher,
          userId: 'user_teacher',
          studentId: 'student_1',
          subjectId: 'subject_math',
          subjectName: 'ગણિત',
          reviewProv: reviewProv,
          locale: const Locale('gu'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ParentReviewBox), findsOneWidget);
      expect(find.text('સ્વીકારેલ છે'), findsOneWidget);
    });

    testWidgets('Teacher section: 360px screen width in Gujarati has zero layout overflows',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.teacher,
          userId: 'user_teacher',
          studentId: 'student_1',
          subjectId: 'subject_math',
          subjectName: 'ગણિત',
          reviewProv: reviewProv,
          locale: const Locale('gu'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ParentReviewBox), findsOneWidget);
    });

    testWidgets('Parents section: existing review on 320px in Gujarati has zero layout overflows',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      // student_1, subject_math has an acknowledged review
      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.parent,
          studentId: 'student_1',
          subjectId: 'subject_math',
          subjectName: 'ગણિત',
          reviewProv: reviewProv,
          locale: const Locale('gu'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ParentReviewBox), findsOneWidget);
      expect(find.text('શિક્ષક દ્વારા વાંચેલ'), findsOneWidget);
    });

    testWidgets('Parents section: writing mode on 320px in Gujarati has zero layout overflows',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final storage = StorageService();
      final reviewProv = ParentReviewProvider(storage);
      await reviewProv.loadReviews();

      // student_5, subject_eng has no initial review
      await tester.pumpWidget(
        buildTestWidget(
          role: UserRole.parent,
          studentId: 'student_5',
          subjectId: 'subject_eng',
          subjectName: 'અંગ્રેજી',
          reviewProv: reviewProv,
          locale: const Locale('gu'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ParentReviewBox), findsOneWidget);
      expect(find.text('પ્રતિભાવ મોકલો'), findsOneWidget);
    });
  });
}
