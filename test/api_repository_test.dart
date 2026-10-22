import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learning_setu/models/models.dart';
import 'package:learning_setu/repositories/api/api_client.dart';
import 'package:learning_setu/repositories/api/api_auth_repository.dart';
import 'package:learning_setu/repositories/api/api_school_repository.dart';
import 'package:learning_setu/repositories/api/api_student_repository.dart';
import 'package:learning_setu/repositories/api/api_assessment_repository.dart';
import 'package:learning_setu/repositories/api/api_remedial_repository.dart';
import 'package:learning_setu/repositories/api/api_quiz_repository.dart';

void main() {
  group('Live API Repositories Test Suite', () {
    test('ApiAuthRepository logs in and parses UserModel', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          final body = jsonDecode(request.body);
          if (body['emailOrPhone'] == 'teacher@demo.com') {
            return http.Response(
              jsonEncode({
                'id': 'user_teacher',
                'name': 'Anita Sharma',
                'email': 'teacher@demo.com',
                'phone': '+91 98796 67097',
                'role': 'teacher',
                'schoolId': 'school_1',
                'classIds': ['class_3a_s1'],
                'subjectIds': ['subject_math'],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
        }
        return http.Response('{"detail": "Unauthorized"}', 401);
      });

      final apiClient = ApiClient(baseUrl: 'http://test-server/api', httpClient: mockClient);
      final repo = ApiAuthRepository(client: apiClient);

      final user = await repo.login('teacher@demo.com', 'demo123');
      expect(user, isNotNull);
      expect(user!.name, 'Anita Sharma');
      expect(user.role, UserRole.teacher);
      expect(await repo.getCurrentUser(), equals(user));
    });

    test('ApiSchoolRepository fetches schools and classes', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/schools')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'school_1',
                'name': 'GPS Sector 7 Primary School',
                'blockId': 'block_1',
                'blockName': 'Gandhinagar Block',
                'address': 'Sector 7, Gandhinagar',
                'principalId': 'user_principal',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(baseUrl: 'http://test-server/api', httpClient: mockClient);
      final repo = ApiSchoolRepository(client: apiClient);

      final schools = await repo.getSchoolsByBlock('block_1');
      expect(schools.length, 1);
      expect(schools.first.name, 'GPS Sector 7 Primary School');
    });

    test('ApiStudentRepository fetches student by class', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/students')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'student_1',
                'name': 'Aarav Kumar',
                'studentId': 'GN-2026-3001',
                'classId': 'class_3a_s1',
                'className': 'Class 3',
                'section': 'A',
                'schoolId': 'school_1',
                'schoolName': 'GPS Sector 7 Primary School',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(baseUrl: 'http://test-server/api', httpClient: mockClient);
      final repo = ApiStudentRepository(client: apiClient);

      final students = await repo.getStudentsByClass('class_3a_s1');
      expect(students.length, 1);
      expect(students.first.name, 'Aarav Kumar');
    });

    test('ApiAssessmentRepository fetches assessments', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/assessments')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'asmt_1',
                'studentId': 'student_1',
                'subjectId': 'subject_math',
                'type': 'regular',
                'date': '2026-09-15T00:00:00.000',
                'totalMarks': 100.0,
                'obtainedMarks': 34.0,
                'topicScores': [
                  {
                    'topicId': 'topic_math_sub',
                    'topicName': 'Subtraction',
                    'totalMarks': 50.0,
                    'obtainedMarks': 12.0,
                  }
                ],
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(baseUrl: 'http://test-server/api', httpClient: mockClient);
      final repo = ApiAssessmentRepository(client: apiClient);

      final asmts = await repo.getAssessmentsByStudent('student_1');
      expect(asmts.length, 1);
      expect(asmts.first.percentage, 34.0);
    });

    test('ApiRemedialRepository and ApiQuizRepository work seamlessly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/remedials')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'remedial_1',
                'studentId': 'student_1',
                'subjectId': 'subject_math',
                'topicId': 'topic_math_sub',
                'topicName': 'Subtraction',
                'activityDescription': 'Practice subtraction',
                'hasQuiz': true,
                'assignedDate': '2026-09-16T00:00:00.000',
                'dueDate': '2026-09-23T00:00:00.000',
                'status': 'assigned',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/quizzes/questions')) {
          return http.Response(
            jsonEncode([
              {
                'id': 'q_1',
                'classId': 'class_3',
                'subjectId': 'subject_math',
                'topicId': 'topic_math_sub',
                'difficulty': 'easy',
                'questionText': '45 - 18?',
                'options': ['27', '37', '23', '33'],
                'correctAnswerIndex': 0,
                'explanation': 'Borrow 1 ten',
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('OK', 200);
      });

      final apiClient = ApiClient(baseUrl: 'http://test-server/api', httpClient: mockClient);
      final remedialRepo = ApiRemedialRepository(client: apiClient);
      final quizRepo = ApiQuizRepository(client: apiClient);

      final remedials = await remedialRepo.getRemedialsByStudent('student_1');
      expect(remedials.length, 1);
      expect(remedials.first.status, RemedialStatus.assigned);

      final questions = await quizRepo.getQuestions(
        classId: 'class_3a_s1',
        subjectId: 'subject_math',
        topicId: 'topic_math_sub',
      );
      expect(questions.length, 1);
      expect(questions.first.correctAnswerIndex, 0);
    });
  });
}
