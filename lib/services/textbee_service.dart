// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Result wrapper for TextBee API requests.
class TextBeeResult {
  final bool success;
  final String message;
  final String? requestId;
  final int? statusCode;

  const TextBeeResult({
    required this.success,
    required this.message,
    this.requestId,
    this.statusCode,
  });

  @override
  String toString() =>
      'TextBeeResult(success: $success, message: $message, requestId: $requestId)';
}

/// Service handling SMS dispatch via TextBee (https://api.textbee.dev).
class TextBeeService {
  static const String prefKey = 'textbee_api_key';
  static const String prefDeviceIdKey = 'textbee_device_id';
  static const String defaultDeviceId = '6ad9a177a4996b8ebf9a713e';
  static const String endpoint = 'https://api.textbee.dev/api/v1/gateway/send-sms';
  static const String devicesEndpoint = 'https://api.textbee.dev/api/v1/gateway/devices';

  final http.Client _client;
  String? _cachedApiKey;
  String? _cachedDeviceId;

  TextBeeService({String? apiKey, String? deviceId, http.Client? client})
      : _cachedApiKey = apiKey,
        _cachedDeviceId = deviceId,
        _client = client ?? http.Client();

  /// Retrieves stored TextBee API key from cache, SharedPreferences, or .env.
  Future<String?> getApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) return _cachedApiKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(prefKey);
      if (key != null && key.trim().isNotEmpty) return key.trim();
    } catch (_) {
      // Ignored in headless/test environments
    }

    try {
      final envKey = dotenv.env['TEXTBEE_API_KEY'];
      if (envKey != null && envKey.trim().isNotEmpty) {
        return envKey.trim();
      }
    } catch (_) {}

    return null;
  }

  /// Persists the provided API key.
  Future<void> setApiKey(String? apiKey) async {
    _cachedApiKey = apiKey?.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (apiKey == null || apiKey.trim().isEmpty) {
        await prefs.remove(prefKey);
      } else {
        await prefs.setString(prefKey, apiKey.trim());
      }
    } catch (_) {}
  }

  /// Retrieves stored Device ID from cache, SharedPreferences, .env, or defaultDeviceId.
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) return _cachedDeviceId!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(prefDeviceIdKey);
      if (id != null && id.trim().isNotEmpty) return id.trim();
    } catch (_) {}

    try {
      final envId = dotenv.env['TEXTBEE_DEVICE_ID'];
      if (envId != null && envId.trim().isNotEmpty) {
        return envId.trim();
      }
    } catch (_) {}

    return defaultDeviceId;
  }

  /// Persists the provided Device ID.
  Future<void> setDeviceId(String? deviceId) async {
    _cachedDeviceId = deviceId?.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (deviceId == null || deviceId.trim().isEmpty) {
        await prefs.remove(prefDeviceIdKey);
      } else {
        await prefs.setString(prefDeviceIdKey, deviceId.trim());
      }
    } catch (_) {}
  }

  /// Helper to strip non-numeric characters and handle Indian country codes.
  static String cleanIndianPhoneNumber(String raw) {
    var cleaned = raw.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  /// Checks the connected devices status on TextBee
  Future<TextBeeResult> checkDeviceStatus({String? apiKeyOverride}) async {
    final apiKey = (apiKeyOverride ?? await getApiKey())?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      return const TextBeeResult(
        success: false,
        message: 'TextBee API key is not configured.',
      );
    }

    try {
      final response = await _client.get(
        Uri.parse(devicesEndpoint),
        headers: {
          'x-api-key': apiKey,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final devices = data['data'] as List?;
        if (devices != null && devices.isNotEmpty) {
          final targetDevId = await getDeviceId();
          final matching = devices.firstWhere(
            (d) => (d['_id'] == targetDevId || d['id'] == targetDevId),
            orElse: () => devices.first,
          );
          final devName = matching['name'] ?? matching['model'] ?? 'Android Phone';
          final enabled = matching['enabled'] == true;
          return TextBeeResult(
            success: true,
            message: 'Device "$devName" is registered (Enabled: $enabled)',
            statusCode: 200,
          );
        } else {
          return const TextBeeResult(
            success: false,
            message: 'No paired Android devices found on your TextBee account.',
            statusCode: 200,
          );
        }
      } else {
        return TextBeeResult(
          success: false,
          message: data['message']?.toString() ?? 'Device check failed (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return TextBeeResult(
        success: false,
        message: 'Network error checking devices: $e',
      );
    }
  }

  /// Sends an SMS via TextBee.
  /// `phone` should be a 10‑digit Indian number (without country code).
  Future<TextBeeResult> sendSms({
    required String phone,
    required String message,
    String? apiKeyOverride,
    String? deviceIdOverride,
  }) async {
    final apiKey = (apiKeyOverride ?? await getApiKey())?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      return const TextBeeResult(
        success: false,
        message:
            'TextBee API key is not configured. Please set it in Settings.',
      );
    }

    // Ensure 10-digit number.
    final cleaned = cleanIndianPhoneNumber(phone);
    if (cleaned.length != 10) {
      return TextBeeResult(
        success: false,
        message: 'Invalid Indian phone number ($phone). Expected 10 digits.',
      );
    }

    final e164 = '+91$cleaned';
    final targetDeviceId = (deviceIdOverride ?? await getDeviceId()).trim();

    try {
      final payload = <String, dynamic>{
        'recipients': [e164],
        'message': message,
      };

      if (targetDeviceId.isNotEmpty) {
        payload['deviceId'] = targetDeviceId;
      }

      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: {
              'x-api-key': apiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && (data['success'] == true || data['status'] == 'success')) {
        final reqId = data['messageId']?.toString() ?? data['id']?.toString();
        return TextBeeResult(
          success: true,
          message: data['message']?.toString() ?? 'SMS sent successfully to gateway',
          requestId: reqId,
          statusCode: response.statusCode,
        );
      } else {
        final err = data['error']?.toString() ??
            data['message']?.toString() ??
            'Failed to dispatch SMS (Code: ${response.statusCode})';
        return TextBeeResult(
          success: false,
          message: err,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return TextBeeResult(
        success: false,
        message: 'Network or parsing error connecting to TextBee: $e',
      );
    }
  }
}
