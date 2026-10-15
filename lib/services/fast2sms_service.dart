import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Result wrapper for Fast2SMS API requests
class Fast2SmsResult {
  final bool success;
  final String message;
  final String? requestId;
  final int? statusCode;

  const Fast2SmsResult({
    required this.success,
    required this.message,
    this.requestId,
    this.statusCode,
  });

  @override
  String toString() => 'Fast2SmsResult(success: $success, message: $message, requestId: $requestId)';
}

/// Service handling automated SMS dispatch via Fast2SMS India Developer API.
/// Supports both English and Gujarati (Unicode) SMS via Quick Developer route (`route: 'q'`).
class Fast2SmsService {
  static const String prefKey = 'fast2sms_api_key';
  static const String endpoint = 'https://www.fast2sms.com/dev/bulkV2';

  final http.Client _client;
  String? _cachedApiKey;

  Fast2SmsService({String? apiKey, http.Client? client})
      : _cachedApiKey = apiKey,
        _client = client ?? http.Client();

  /// Gets the currently stored Fast2SMS API key from SharedPreferences.
  Future<String?> getApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(prefKey);
    } catch (_) {
      return null;
    }
  }

  /// Sets or updates the Fast2SMS API key.
  Future<void> setApiKey(String? apiKey) async {
    _cachedApiKey = apiKey?.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (apiKey == null || apiKey.trim().isEmpty) {
        await prefs.remove(prefKey);
      } else {
        await prefs.setString(prefKey, apiKey.trim());
      }
    } catch (_) {
      // Ignored in headless/test environments
    }
  }

  /// Formats an Indian phone number to 10 digits
  static String cleanIndianPhoneNumber(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  /// Sends an automated SMS to an Indian 10-digit mobile number using Fast2SMS Dev API.
  Future<Fast2SmsResult> sendSms({
    required String phone,
    required String message,
    String? apiKeyOverride,
  }) async {
    final apiKey = (apiKeyOverride ?? await getApiKey())?.trim();

    if (apiKey == null || apiKey.isEmpty) {
      return const Fast2SmsResult(
        success: false,
        message: 'Fast2SMS API key is not configured. Please set it in Settings or enter it when prompted.',
      );
    }

    final cleanNumber = cleanIndianPhoneNumber(phone);
    if (cleanNumber.length != 10) {
      return Fast2SmsResult(
        success: false,
        message: 'Invalid Indian phone number ($phone). Expected 10 digits.',
      );
    }

    // Zero-signup 1-free SMS route via Textbelt public test key
    if (apiKey.toLowerCase() == 'textbelt') {
      return await _sendViaTextbelt(cleanNumber, message);
    }

    // Fast2SMS requires "unicode" parameter when Gujarati or non-ASCII characters are present
    final isUnicode = RegExp(r'[^\x00-\x7F]').hasMatch(message);

    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {
          'authorization': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'route': 'q', // Quick developer route (no DLT approval required for testing)
          'message': message,
          'language': isUnicode ? 'unicode' : 'english',
          'flash': 0,
          'numbers': cleanNumber,
        }),
      ).timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['return'] == true) {
        String? reqId = data['request_id']?.toString();
        String successMsg = 'SMS sent successfully';

        if (data['message'] is List && (data['message'] as List).isNotEmpty) {
          successMsg = (data['message'] as List).first.toString();
        } else if (data['message'] is String) {
          successMsg = data['message'];
        }

        return Fast2SmsResult(
          success: true,
          message: successMsg,
          requestId: reqId,
          statusCode: 200,
        );
      } else {
        String errorMsg = 'Failed to send SMS';
        if (data['message'] is List && (data['message'] as List).isNotEmpty) {
          errorMsg = (data['message'] as List).join(', ');
        } else if (data['message'] is String) {
          errorMsg = data['message'];
        }

        return Fast2SmsResult(
          success: false,
          message: '$errorMsg (Code: ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return Fast2SmsResult(
        success: false,
        message: 'Network or parsing error connecting to Fast2SMS: $e',
      );
    }
  }

  /// Sends a zero-signup free SMS via Textbelt (1 free SMS per day per IP)
  Future<Fast2SmsResult> _sendViaTextbelt(String cleanNumber, String message) async {
    try {
      final response = await _client.post(
        Uri.parse('https://textbelt.com/text'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'phone': '+91$cleanNumber',
          'message': message,
          'key': 'textbelt',
        },
      ).timeout(const Duration(seconds: 12));

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Fast2SmsResult(
          success: true,
          message: 'SMS sent via Textbelt free tier (Quota remaining: ${data['quotaRemaining']})',
          requestId: data['textId']?.toString(),
          statusCode: 200,
        );
      } else {
        return Fast2SmsResult(
          success: false,
          message: data['error']?.toString() ?? 'Textbelt free daily quota limit reached',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return Fast2SmsResult(
        success: false,
        message: 'Textbelt network error: $e',
      );
    }
  }
}
