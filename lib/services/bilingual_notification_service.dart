import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/services/deepl_translation_service.dart';
import 'package:learning_setu/services/textbee_service.dart';

/// Service responsible for constructing bilingual (English + Gujarati) notification
/// messages for student assessment results, quiz marks, and remedial alerts.
class BilingualNotificationService {
  /// Translates text using DeepL Translation API (defaults to Gujarati)
  static Future<String> translateWithDeepL(String text, {String targetLang = 'GU'}) async {
    final deepl = DeeplTranslationService();
    final res = await deepl.translate(text: text, targetLang: targetLang);
    if (res.success && res.translatedText.isNotEmpty) {
      return res.translatedText;
    }
    return text;
  }

  /// Maps English subject IDs/names to Gujarati translations
  static String getGujaratiSubjectName(String subjectNameOrId) {
    final lower = subjectNameOrId.toLowerCase();
    if (lower.contains('math')) return 'ગણિત';
    if (lower.contains('guj')) return 'ગુજરાતી';
    if (lower.contains('eng')) return 'અંગ્રેજી';
    if (lower.contains('evs') || lower.contains('environ')) {
      return 'પર્યાવરણ અભ્યાસ';
    }
    return subjectNameOrId;
  }

  /// Maps school name to Gujarati transliteration if standard
  static String getGujaratiSchoolName(String schoolName) {
    if (schoolName.contains('Sector 7')) {
      return 'જીપીએસ સેક્ટર ૭ પ્રાથમિક શાળા';
    } else if (schoolName.contains('Sector 21')) {
      return 'જીપીએસ સેક્ટર ૨૧ પ્રાથમિક શાળા';
    } else if (schoolName.contains('Sector 14')) {
      return 'જીપીએસ સેક્ટર ૧૪ પ્રાથમિક શાળા';
    }
    return 'પ્રાથમિક શાળા (ગાંધીનગર)';
  }

  /// Generates a bilingual message for regular assessment / exam marks declaration
  static String buildBilingualAssessmentMessage({
    required String studentName,
    required String className,
    required String subjectName,
    required double obtainedMarks,
    required double totalMarks,
    required String schoolName,
    String? teacherNotes,
  }) {
    final subjectGu = getGujaratiSubjectName(subjectName);
    final schoolGu = getGujaratiSchoolName(schoolName);
    final percent = totalMarks > 0
        ? ((obtainedMarks / totalMarks) * 100).round()
        : 0;

    String grade = 'A';
    String gradeGu = 'એ (A)';
    if (percent < 40) {
      grade = 'Needs Support (C)';
      gradeGu = 'વધારાના માર્ગદર્શનની જરૂર (C)';
    } else if (percent < 70) {
      grade = 'Average (B)';
      gradeGu = 'સામાન્ય (B)';
    } else {
      grade = 'Strong (A)';
      gradeGu = 'ઉત્તમ (A)';
    }

    final notesSectionEn = teacherNotes != null && teacherNotes.isNotEmpty
        ? '\nTeacher Note: $teacherNotes'
        : '';
    final notesSectionGu = teacherNotes != null && teacherNotes.isNotEmpty
        ? '\nશિક્ષકની નોંધ: $teacherNotes'
        : '';

    return '''Learning Setu Exam Result / પરીક્ષા પરિણામ 📋

Dear Parent, assessment result declared for $studentName (Class $className):
Subject: $subjectName
Marks: ${obtainedMarks.toStringAsFixed(0)}/${totalMarks.toStringAsFixed(0)} ($percent%)
Grade: $grade$notesSectionEn
View Full Report: https://learningsetu.gujarat.gov.in/r/${studentName.replaceAll(' ', '').toLowerCase()}

---

પ્રિય વાલી, $studentName (ધોરણ $className) નું મૂલ્યાંકન પરિણામ જાહેર થયેલ છે:
વિષય: $subjectGu
ગુણ: ${obtainedMarks.toStringAsFixed(0)}/${totalMarks.toStringAsFixed(0)} ($percent%)
ગ્રેડ: $gradeGu$notesSectionGu
વિગતવાર અહેવાલ: https://learningsetu.gujarat.gov.in/r/${studentName.replaceAll(' ', '').toLowerCase()}

- $schoolName / $schoolGu
- Teacher Contact / શિક્ષક સંપર્ક: +91 98796 67097''';
  }

  /// Generates a bilingual message for remedial action / home practice assignment
  static String buildBilingualRemedialAlertMessage({
    required String studentName,
    required String className,
    required String subjectName,
    required String topicName,
    required String activityDescription,
    required DateTime dueDate,
    required String schoolName,
    String? parentInstruction,
    String? teacherNote,
  }) {
    final subjectGu = getGujaratiSubjectName(subjectName);
    final schoolGu = getGujaratiSchoolName(schoolName);
    final formattedDate = '${dueDate.day}/${dueDate.month}/${dueDate.year}';

    final parentInstEn = parentInstruction != null && parentInstruction.isNotEmpty
        ? '\nHome Practice: $parentInstruction'
        : '';
    final parentInstGu = parentInstruction != null && parentInstruction.isNotEmpty
        ? '\nઘરકામ સૂચના: $parentInstruction'
        : '';

    final teacherNoteEn = teacherNote != null && teacherNote.isNotEmpty
        ? '\nTeacher Note: $teacherNote'
        : '';
    final teacherNoteGu = teacherNote != null && teacherNote.isNotEmpty
        ? '\nશિક્ષકની નોંધ: $teacherNote'
        : '';

    return '''Learning Setu Remedial Alert / ઉપચારાત્મક શિક્ષણ સૂચના 🎯

Dear Parent, a targeted remedial practice task has been assigned for $studentName (Class $className):
Subject: $subjectName
Topic: $topicName
Activity: $activityDescription
Due Date: $formattedDate$parentInstEn$teacherNoteEn
Please guide your child to practice this topic at home.

---

પ્રિય વાલી, તમારા બાળક $studentName (ધોરણ $className) માટે ઉપચારાત્મક શિક્ષણ પ્રવૃત્તિ સોંપેલ છે:
વિષય: $subjectGu
વિષયાંગ: $topicName
પ્રવૃત્તિ: $activityDescription
પૂર્ણ કરવાની છેલ્લી તારીખ: $formattedDate$parentInstGu$teacherNoteGu
કૃપા કરીને ઘરે આ વિષયાંગનો મહાવરો કરાવવામાં બાળકને માર્ગદર્શન આપો.

- $schoolName / $schoolGu
- Teacher Contact / શિક્ષક સંપર્ક: +91 98796 67097''';
  }

  /// Generates a bilingual message for quiz completion
  static String buildBilingualQuizMessage({
    required String studentName,
    required String className,
    required String subjectName,
    required int score,
    required int totalQuestions,
    required String schoolName,
  }) {
    final subjectGu = getGujaratiSubjectName(subjectName);
    final schoolGu = getGujaratiSchoolName(schoolName);
    final percent = totalQuestions > 0
        ? ((score / totalQuestions) * 100).round()
        : 0;
    final passed = percent >= 70;

    final statusEn = passed
        ? 'Great performance! Ready for reassessment.'
        : 'Needs more practice. Remedial recommended.';
    final statusGu = passed
        ? 'ખૂબ સરસ પ્રદર્શન! પુનઃમૂલ્યાંકન માટે તૈયાર.'
        : 'વધુ અભ્યાસની જરૂર છે. ઉપચારાત્મક કાર્ય ભલામણ.';

    return '''Learning Setu Quiz Alert / ક્વિઝ સૂચના 📚

Dear Parent, your child $studentName (Class $className) completed a quiz in $subjectName.
Score: $score/$totalQuestions ($percent%)
Status: $statusEn
Practice Portal: https://learningsetu.gujarat.gov.in/practice

---

પ્રિય વાલી, તમારા બાળક $studentName (ધોરણ $className) એ $subjectGu વિષયમાં ક્વિઝ પૂર્ણ કરી છે.
સ્કોર: $score/$totalQuestions ($percent%)
સ્થિતિ: $statusGu
અભ્યાસ પોર્ટલ: https://learningsetu.gujarat.gov.in/practice

- $schoolName / $schoolGu
- Teacher Contact / શિક્ષક સંપર્ક: +91 98796 67097''';
  }

  /// Shows an interactive bilingual message preview modal with option to copy or send
  static Future<void> showMessageModal({
    required BuildContext context,
    required String title,
    required String recipientName,
    required String recipientPhone,
    required String message,
  }) async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${isGu ? "વાલી" : "Parent"}: $recipientName ($recipientPhone)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                constraints: const BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(
                  child: SelectableText(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Default Single Action: Send SMS via TextBee API
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: Text(
                    isGu ? '⚡ SMS મોકલો (TextBee API)' : '⚡ Send SMS via TextBee API',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    Navigator.pop(modalContext);
                    await handleTextBeeDispatch(
                      context: context,
                      phone: recipientPhone,
                      message: message,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(modalContext),
                  child: Text(
                    isGu ? 'રદ કરો' : 'Cancel',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  /// Launches device native SMS application with pre-filled recipient and message
  static Future<bool> launchSms({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }

  /// Launches WhatsApp with pre-filled recipient and message
  static Future<bool> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMsg = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMsg');

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// Dispatches message automatically using TextBee API
  static Future<void> handleTextBeeDispatch({
    required BuildContext context,
    required String phone,
    required String message,
  }) async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final textBee = TextBeeService();
    final savedKey = await textBee.getApiKey();

    if (savedKey == null || savedKey.trim().isEmpty) {
      if (!context.mounted) return;
      final keyController = TextEditingController();
      final devId = await textBee.getDeviceId();
      if (!context.mounted) return;
      final deviceController = TextEditingController(text: devId);

      final entered = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFFE11D48)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGu ? 'TextBee API કી દાખલ કરો' : 'Enter TextBee API Key',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGu
                    ? 'વાલીના ફોન પર સીધો SMS મોકલવા માટે તમારી TextBee કી દાખલ કરો (textbee.dev પર સાઇન અપ કરો).'
                    : 'Enter your TextBee API key and Device ID to auto-dispatch SMS directly.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  labelText: isGu ? 'API કી' : 'API Key',
                  hintText: 'e.g. your TextBee API key',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deviceController,
                decoration: InputDecoration(
                  labelText: isGu ? 'ડિવાઇસ ID' : 'Device ID',
                  hintText: 'e.g. 6ad9a177a4996b8ebf9a713e',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(isGu ? 'રદ કરો' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (keyController.text.trim().isNotEmpty) {
                  Navigator.pop(dialogCtx, true);
                }
              },
              child: Text(isGu ? 'સાચવો અને મોકલો' : 'Save & Send'),
            ),
          ],
        ),
      );

      if (entered == true && keyController.text.trim().isNotEmpty) {
        await textBee.setApiKey(keyController.text.trim());
        if (deviceController.text.trim().isNotEmpty) {
          await textBee.setDeviceId(deviceController.text.trim());
        }
      } else {
        return;
      }
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isGu ? 'TextBee દ્વારા SMS મોકલાઈ રહ્યો છે...' : 'Dispatching SMS via TextBee...',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final result = await textBee.sendSms(
      phone: phone,
      message: message,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isGu
                      ? 'SMS સફળતાપૂર્વક મોકલાયો! (${result.message})'
                      : 'SMS sent successfully! (${result.message})',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isGu ? 'TextBee નિષ્ફળ' : 'TextBee Dispatch Failed',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                result.message,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: isGu ? 'મેન્યુઅલ મોકલો' : 'Manual SMS',
            textColor: Colors.white,
            onPressed: () => launchSms(phone: phone, message: message),
          ),
        ),
      );
    }
  }
}
