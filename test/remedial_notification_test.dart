import 'package:flutter_test/flutter_test.dart';
import 'package:learning_setu/services/bilingual_notification_service.dart';

void main() {
  group('Bilingual Remedial Notification Tests', () {
    test('buildBilingualRemedialAlertMessage generates correct bilingual text', () {
      final msg = BilingualNotificationService.buildBilingualRemedialAlertMessage(
        studentName: 'Aarav Kumar',
        className: '3-A',
        subjectName: 'Mathematics',
        topicName: 'Subtraction',
        activityDescription: 'Two-digit subtraction using visual counters',
        dueDate: DateTime(2026, 10, 29),
        schoolName: 'GPS Sector 7 Primary School',
        parentInstruction: 'Please guide Aarav with 10 practice problems at home.',
        teacherNote: 'Focus on borrowing from tens place.',
      );

      // Verify English section contents
      expect(msg.contains('Learning Setu Remedial Alert / ઉપચારાત્મક શિક્ષણ સૂચના 🎯'), isTrue);
      expect(msg.contains('Dear Parent, a targeted remedial practice task has been assigned for Aarav Kumar (Class 3-A):'), isTrue);
      expect(msg.contains('Subject: Mathematics'), isTrue);
      expect(msg.contains('Topic: Subtraction'), isTrue);
      expect(msg.contains('Activity: Two-digit subtraction using visual counters'), isTrue);
      expect(msg.contains('Due Date: 29/10/2026'), isTrue);
      expect(msg.contains('Home Practice: Please guide Aarav with 10 practice problems at home.'), isTrue);
      expect(msg.contains('Teacher Note: Focus on borrowing from tens place.'), isTrue);

      // Verify Gujarati section contents
      expect(msg.contains('પ્રિય વાલી, તમારા બાળક Aarav Kumar (ધોરણ 3-A) માટે ઉપચારાત્મક શિક્ષણ પ્રવૃત્તિ સોંપેલ છે:'), isTrue);
      expect(msg.contains('વિષય: ગણિત'), isTrue);
      expect(msg.contains('વિષયાંગ: Subtraction'), isTrue);
      expect(msg.contains('ઘરકામ સૂચના: Please guide Aarav with 10 practice problems at home.'), isTrue);
      expect(msg.contains('શિક્ષકની નોંધ: Focus on borrowing from tens place.'), isTrue);
      expect(msg.contains('જીપીએસ સેક્ટર ૭ પ્રાથમિક શાળા'), isTrue);
    });
  });
}
