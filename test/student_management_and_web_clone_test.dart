import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/models/student_model.dart';
import 'package:learning_setu/models/user_model.dart';
import 'package:learning_setu/providers/auth_provider.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/repositories/mock/mock_auth_repository.dart';
import 'package:learning_setu/repositories/mock/mock_student_repository.dart';
import 'package:learning_setu/screens/auth/welcome_screen.dart';
import 'package:learning_setu/screens/students/students_list_screen.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:learning_setu/widgets/add_student_dialog.dart';

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

      bool notified = false;
      provider.addListener(() => notified = true);

      final result = await provider.addStudent(student);
      expect(result.id, 'test_student_102');
      expect(provider.students.length, initialCount + 1);
      expect(provider.students.first.name, 'Arjun Mehta');
      expect(notified, isTrue);
    });
  });

  group('StudentsListScreen & AddStudentDialog Widget Tests', () {
    testWidgets('StudentsListScreen renders search, filter chips, and student directory', (tester) async {
      final repo = MockStudentRepository();
      final studentProv = StudentProvider(repo);
      final authProv = AuthProvider(MockAuthRepository(), StorageService());
      await tester.runAsync(() async {
        await authProv.demoLogin(UserRole.principal);
        await studentProv.loadStudentsBySchool('school_1');
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProv),
            ChangeNotifierProvider.value(value: studentProv),
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ],
          child: const MaterialApp(
            home: StudentsListScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Elements
      expect(find.text('Students Directory'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Classes'), findsOneWidget);
      expect(find.text('Class 4'), findsWidgets);
      expect(find.text('Add Student'), findsWidgets);
    });

    testWidgets('AddStudentDialog displays form fields and cancels cleanly', (tester) async {
      final repo = MockStudentRepository();
      final studentProv = StudentProvider(repo);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: studentProv),
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AddStudentDialog(
                initialClassId: 'Class 4',
                schoolId: 'school_1',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Add New Student'), findsOneWidget);
      expect(find.text('Student Full Name *'), findsOneWidget);
      expect(find.text('Enrollment / Student ID *'), findsOneWidget);
      expect(find.text('Parent / Guardian Name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('Web Home Clone WelcomeScreen Section Verification', () {
    testWidgets('WelcomeScreen renders all 6 web index.html sections accurately', (tester) async {
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
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Section 1: Site Header
      expect(find.text('EduTrack'), findsWidgets);
      expect(find.text('Smart Performance Monitoring'), findsWidgets);
      expect(find.text('Primary & Middle Academic Portal'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Section 2: Landing Hero Banner
      expect(find.text('Multi-Stakeholder Educational Intelligence Platform'), findsOneWidget);
      expect(find.text('Select Your Portal to Continue'), findsOneWidget);

      // Section 3: 4 Role Cards Grid
      expect(find.text('Teachers'), findsOneWidget);
      expect(find.text('School Principals'), findsOneWidget);
      expect(find.text('Block Resource Coordinators (BRC)'), findsOneWidget);
      expect(find.text('Parents'), findsOneWidget);
      expect(find.text('5 Subjects & Topic breakdown'), findsOneWidget);
      expect(find.text('School-wide performance ledger'), findsOneWidget);
      expect(find.text('Authorized linked child access'), findsOneWidget);

      // Section 4: Current Selection Action Bar
      expect(find.text('CURRENT SELECTION:'), findsOneWidget);
      expect(find.text('Teachers Portal'), findsOneWidget);
      expect(find.text('Continue to Login'), findsOneWidget);

      // Section 5: Standardized Academic Performance Color System
      expect(find.text('Standardized Academic Performance Color System'), findsOneWidget);
      expect(find.text('Green • Excellent (75% – 100%)'), findsOneWidget);
      expect(find.text('Yellow • Average (40% – 74%)'), findsOneWidget);
      expect(find.text('Red • Needs More Improvement (Below 40%)'), findsOneWidget);

      // Section 6: Site Footer
      expect(find.text('Primary & Middle Education Analytics • Designed for Gujarat Primary Schools'), findsOneWidget);

      // Interactive: Tap on School Principals card and verify Action Bar updates
      await tester.tap(find.text('School Principals'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('School Principals Portal'), findsOneWidget);

      // Interactive: Tap on Parents card and verify Action Bar updates
      await tester.tap(find.text('Parents'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Parents Portal'), findsOneWidget);
    });
  });
}
