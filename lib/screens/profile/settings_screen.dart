import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_setu/l10n/app_localizations.dart';

import 'package:learning_setu/app/theme.dart';
import 'package:learning_setu/providers/assessment_provider.dart';
import 'package:learning_setu/providers/locale_provider.dart';
import 'package:learning_setu/providers/performance_provider.dart';
import 'package:learning_setu/providers/quiz_provider.dart';
import 'package:learning_setu/providers/remedial_provider.dart';
import 'package:learning_setu/providers/student_provider.dart';
import 'package:learning_setu/services/storage_service.dart';
import 'package:learning_setu/services/ai_analysis_service.dart';
import 'package:learning_setu/services/textbee_service.dart';

/// Settings screen for configuring language preferences (English / Gujarati),
/// reviewing hackathon problem metadata, resetting demo datasets, and reading
/// transparent compliance and methodology disclosures.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isResetting = false;
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  final _textBeeKeyController = TextEditingController();
  bool _obscureTextBeeKey = true;
  bool _isTestingSms = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final aiService = AiAnalysisService();
    final key = await aiService.getApiKey();
    final textBee = TextBeeService();
    final smsKey = await textBee.getApiKey();
    if (mounted) {
      setState(() {
        if (key != null) _apiKeyController.text = key;
        if (smsKey != null) _textBeeKeyController.text = smsKey;
      });
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _textBeeKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final l10n = AppLocalizations.of(context);
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final text = _apiKeyController.text.trim();
    final aiService = AiAnalysisService();
    await aiService.setApiKey(text.isEmpty ? null : text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text.isEmpty
                ? (l10n?.apiKeyCleared ?? (isGu ? 'API કી દૂર કરવામાં આવી' : 'API Key cleared'))
                : (l10n?.apiKeySaved ?? (isGu ? 'API કી સફળતાપૂર્વક સાચવવામાં આવી' : 'API Key saved successfully')),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      setState(() {});
    }
  }

  Future<void> _saveTextBeeKey() async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final text = _textBeeKeyController.text.trim();
    final textBee = TextBeeService();
    await textBee.setApiKey(text.isEmpty ? null : text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text.isEmpty
                ? (isGu ? 'TextBee કી દૂર કરવામાં આવી' : 'TextBee API Key cleared')
                : (isGu ? 'TextBee કી સફળતાપૂર્વક સાચવવામાં આવી' : 'TextBee API Key saved successfully'),
          ),
          backgroundColor: const Color(0xFFE11D48),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _testTextBee() async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final key = _textBeeKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isGu ? 'કૃપા કરીને પહેલાં TextBee API કી દાખલ કરો' : 'Please enter a TextBee API Key first'),
          backgroundColor: Colors.amber.shade800,
        ),
      );
      return;
    }

    final phoneController = TextEditingController(text: '9879667097');
    final targetPhone = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFFE11D48)),
            const SizedBox(width: 8),
            Text(isGu ? 'ટેસ્ટ SMS મોકલો' : 'Send Test SMS'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isGu
                  ? 'TextBee ગેટવે ચકાસવા માટે ૧૦ આંકડાનો ભારતીય મોબાઈલ નંબર દાખલ કરો:'
                  : 'Enter 10-digit Indian mobile number to test TextBee gateway:',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: isGu ? 'મોબાઈલ નંબર' : 'Mobile Number',
                prefixText: '+91 ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isGu ? 'રદ કરો' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, phoneController.text.trim()),
            child: Text(isGu ? 'ટેસ્ટ SMS મોકલો' : 'Send Test'),
          ),
        ],
      ),
    );

    if (targetPhone == null || targetPhone.isEmpty || !mounted) return;

    setState(() => _isTestingSms = true);
    final textBee = TextBeeService(apiKey: key);
    final result = await textBee.sendSms(
      phone: targetPhone,
      message: isGu
          ? 'લર્નિંગ સેતુ: TextBee ગેટવે ટેસ્ટ સફળ! વિદ્યાર્થી પ્રગતિ સૂચનાઓ સક્રિય છે.'
          : 'Learning Setu: TextBee gateway test successful! Automated parent alerts active.',
    );

    if (!mounted) return;
    setState(() => _isTestingSms = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  Future<void> _resetDemoData() async {
    final isGu = Localizations.localeOf(context).languageCode == 'gu';
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isGu ? 'તમામ ડેમો ડેટા રીસેટ કરવો છે?' : 'Reset All Demo Data?',
        ),
        content: Text(
          isGu
              ? 'આ ક્રિયા તમામ સ્થાનિક રીતે નોંધાયેલા મૂલ્યાંકનો, ઉપચારાત્મક કાર્યો અને ક્વિઝ પ્રયાસોને સાફ કરશે.'
              : 'This action will clear all locally recorded assessments, remedial actions, and quiz attempts, restoring initial prototype state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? (isGu ? 'રદ કરો' : 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(isGu ? 'બધું રીસેટ કરો' : 'Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final studentProv = context.read<StudentProvider>();
      final assessProv = context.read<AssessmentProvider>();
      final quizProv = context.read<QuizProvider>();
      final remedialProv = context.read<RemedialProvider>();
      final perfProv = context.read<PerformanceProvider>();
      final messenger = ScaffoldMessenger.of(context);

      setState(() {
        _isResetting = true;
      });

      final storage = StorageService();
      await storage.resetDemoData();

      quizProv.resetQuiz();
      perfProv.clear();

      if (studentProv.selectedStudent != null) {
        await Future.wait([
          assessProv.loadAssessmentsByStudent(studentProv.selectedStudent!.id),
          remedialProv.loadRemedialsByStudent(studentProv.selectedStudent!.id),
          perfProv.loadPerformance(studentProv.selectedStudent!.id),
        ]);
      }

      if (mounted) {
        setState(() {
          _isResetting = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              isGu
                  ? 'ડેમો ડેટા મૂળભૂત સ્થિતિમાં રીસેટ થઈ ગયો છે.'
                  : 'Demo data has been reset to defaults.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeProv = context.watch<LocaleProvider>();
    final currentLanguageCode = localeProv.locale.languageCode;
    final isGu = currentLanguageCode == 'gu';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settings ?? (isGu ? 'સેટિંગ્સ' : 'Settings'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Language Selection Section
          Text(
            'Language Preference / ભાષા પસંદગી',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.dividerColor),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text(
                    'English (Default)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Standard English interface'),
                  value: 'en',
                  groupValue: currentLanguageCode,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      localeProv.setLocale(Locale(val));
                    }
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text(
                    'ગુજરાતી (Gujarati)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'પ્રાથમિક શાળા શિક્ષણ માટે ગુજરાતી માધ્યમ',
                  ),
                  value: 'gu',
                  groupValue: currentLanguageCode,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      localeProv.setLocale(Locale(val));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About Section
          Text(
            'About Learning Setu',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.school_rounded,
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
                              'Learning Setu (લર્નિંગ સેતુ)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Version 1.0.0+1 • SFIC Hackathon 2026',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Smart Tracking and Remedial Action System for Student Learning Gaps in Primary Schools (Problem ID: PS000060). Developed for Gujarat primary education.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // AI Diagnostic Engine Configuration Section
          Text(
            l10n?.aiEngine ?? (isGu ? 'AI નિદાન એન્જિન' : 'AI Diagnostic Engine'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFC7D7FE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Google Gemini 1.5 Flash',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              isGu
                                  ? 'હાઇબ્રિડ મોડલ (ઑફલાઇન સંજ્ઞાનાત્મક શૈક્ષણિક એન્જિન સાથે)'
                                  : 'Hybrid Model (with on-device cognitive pedagogical AI fallback)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    decoration: InputDecoration(
                      labelText: l10n?.geminiApiKey ??
                          (isGu ? 'Gemini API કી (વૈકલ્પિક)' : 'Gemini API Key (Optional)'),
                      hintText: l10n?.geminiApiKeyHint ??
                          (isGu ? 'તમારી Google Gemini API કી દાખલ કરો' : 'Enter your Google Gemini API key'),
                      prefixIcon: const Icon(Icons.key_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureApiKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: Text(l10n?.save ?? (isGu ? 'સાચવો' : 'Save')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: _saveApiKey,
                      ),
                      const SizedBox(width: 8),
                      if (_apiKeyController.text.isNotEmpty)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          label: Text(isGu ? 'દૂર કરો' : 'Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            _apiKeyController.clear();
                            _saveApiKey();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // TextBee Automated Gateway Section
          Text(
            isGu ? 'ઓટોમેટેડ SMS ગેટવે (TextBee API)' : 'Automated SMS Gateway (TextBee API)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFFECDD3)), // Light rose border
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFE11D48),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Flexible(
                                  child: Text(
                                    'TextBee SMS Gateway',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade300),
                                  ),
                                  child: Text(
                                    isGu ? 'મફત ટ્રાયલ' : 'Free Trial',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isGu
                                  ? 'TextBee ગેટવે દ્વારા વાલીઓને આપમેળે સીધો SMS મોકલો'
                                  : 'Auto-dispatch SMS to parents via TextBee gateway',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _textBeeKeyController,
                    obscureText: _obscureTextBeeKey,
                    decoration: InputDecoration(
                      labelText: isGu ? 'TextBee API કી' : 'TextBee API Key',
                      hintText: isGu ? 'તમારી TextBee API કી દાખલ કરો' : 'Enter your TextBee API key',
                      prefixIcon: const Icon(Icons.vpn_key_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextBeeKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureTextBeeKey = !_obscureTextBeeKey),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isGu
                        ? '💡 textbee.dev પર સાઇન-અપ કરીને તમારી API કી મેળવો. તમારા Android ફોનને SMS ગેટવે તરીકે વાપરો.'
                        : '💡 Sign up at textbee.dev and link your Android phone to use it as an SMS gateway.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: Text(l10n?.save ?? (isGu ? 'સાચવો' : 'Save')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: _saveTextBeeKey,
                      ),
                      OutlinedButton.icon(
                        icon: _isTestingSms
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded, size: 16),
                        label: Text(isGu ? 'ટેસ્ટ SMS મોકલો' : 'Test SMS'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: _isTestingSms ? null : _testTextBee,
                      ),
                      if (_textBeeKeyController.text.isNotEmpty)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          label: Text(isGu ? 'દૂર કરો' : 'Clear'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            _textBeeKeyController.clear();
                            _saveTextBeeKey();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Prototype Disclaimers & Methodology',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDisclosureItem(
                    Icons.security_rounded,
                    'Demo Authentication',
                    'This prototype uses demo authentication only. Production authentication and role authorization must be enforced by the backend.',
                  ),
                  const Divider(height: 20),
                  _buildDisclosureItem(
                    Icons.rule_rounded,
                    'Performance Thresholds',
                    'Performance classifications use configurable demo thresholds (<40% Weak, 40-69% Average, >=70% Strong), not official education policy values.',
                  ),
                  const Divider(height: 20),
                  _buildDisclosureItem(
                    Icons.auto_awesome,
                    isGu ? 'AI-સંચાલિત નિદાન' : 'AI-Powered Diagnostics',
                    isGu
                        ? 'વિશ્લેષણ સારાંશ અને ભલામણ કરાયેલ ઉપચારાત્મક હસ્તક્ષેપ Google Gemini 1.5 Flash અને સંજ્ઞાનાત્મક શિક્ષણ પદ્ધતિ દ્વારા તૈયાર કરવામાં આવે છે.'
                        : 'Analysis summaries and recommended remedial interventions are generated via an AI-powered diagnostic engine (Google Gemini 1.5 Flash & Cognitive Pedagogical Model).',
                  ),
                  const Divider(height: 20),
                  _buildDisclosureItem(
                    Icons.menu_book_outlined,
                    'Illustrative Curriculum',
                    'Sample learning content and competencies shown are illustrative prototypes and not officially verified GCERT/NCERT syllabus.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Demo Data Reset Section
          Text(
            'Demo Data Management',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.red.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Prototype Demo State',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wipes all local changes and custom tests, restoring default Gandhinagar school sample records.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: _isResetting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore_rounded, size: 18),
                      label: Text(l10n?.resetDemoData ?? (isGu ? 'ડેમો ડેટા રીસેટ કરો' : 'Reset Demo Data')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                        minimumSize: const Size(double.infinity, 46),
                      ),
                      onPressed: _isResetting ? null : _resetDemoData,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDisclosureItem(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
