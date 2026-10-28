import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/repositories/mock/mock_auth_repository.dart';
import 'package:learning_setu/repositories/mock/mock_student_repository.dart';
import 'package:learning_setu/screens/auth/welcome_screen.dart';
import 'package:learning_setu/screens/students/students_list_screen.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:learning_setu/widgets/add_student_dialog.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

void main() {
  group('Student Management & Repository Tests', () {
    test('MockStudentRepository addStudent successfully stores and retrieves student', () async {
      final repo = MockStudentRepository();
      const newStudent = StudentModel(
        id: 'test_student_101',
        name: 'Meera Patel',
        studentId: 'GPS-2026-999',
        classId: 'class_4_a',
        className: 'Class 4',
        section: 'A',
        schoolId: 'school_1',
        schoolName: 'GPS Primary School',
        parentName: 'Girish Patel',
        parentPhone: '9876543210',
      );

      final added = await repo.addStudent(newStudent);
      expect(added.id, 'test_student_101');
      expect(added.name, 'Meera Patel');

      final found = await repo.getStudent('test_student_101');
      expect(found, isNotNull);
      expect(found!.studentId, 'GPS-2026-999');
    });

    test('StudentProvider addStudent updates list and notifies listeners', () async {
      final repo = MockStudentRepository();
      final provider = StudentProvider(repo);
      await provider.loadStudentsBySchool('school_1');

      final initialCount = provider.students.length;
      const student = StudentModel(
        id: 'test_student_102',
        name: 'Arjun Mehta',
        studentId: 'GPS-2026-998',
        classId: 'class_5_b',
        className: 'Class 5',
        section: 'B',
        schoolId: 'school_1',
        schoolName: 'GPS Primary School',
        parentName: 'Hitesh Mehta',
        parentPhone: '9123456780',
      );

      final created = await provider.addStudent(student);
      expect(created.name, 'Arjun Mehta');
      expect(provider.students.length, initialCount + 1);
      expect(provider.students.first.id, 'test_student_102');
    });
  });

  group('StudentsListScreen & AddStudentDialog Widget Tests', () {
    testWidgets('StudentsListScreen renders search, filter chips, and student directory', (tester) async {
      final repo = MockStudentRepository();
      final provider = StudentProvider(repo);
      final authProv = AuthProvider(MockAuthRepository(), StorageService());

      await tester.runAsync(() async {
        await provider.loadStudentsBySchool('school_1');
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider.value(value: authProv),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StudentsListScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('AddStudentDialog displays form fields and cancels cleanly', (tester) async {
      final repo = MockStudentRepository();
      final provider = StudentProvider(repo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ChangeNotifierProvider.value(
              value: provider,
              child: const AddStudentDialog(initialClassId: 'class_4_a'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add New Student'), findsOneWidget);
      expect(find.text('Student Full Name *'), findsOneWidget);
      expect(find.text('Enrollment / Student ID *'), findsOneWidget);
      expect(find.text('Parent / Guardian Name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('Reversed Main Page (WelcomeScreen) Verification', () {
    testWidgets('WelcomeScreen renders EduTrack and all stakeholder role cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authProv = AuthProvider(MockAuthRepository(), StorageService());
      final localeProv = LocaleProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProv),
            ChangeNotifierProvider.value(value: localeProv),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EduTrack'), findsWidgets);
      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
