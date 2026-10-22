import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Result wrapper for DeepL Translation API.
class DeeplTranslationResult {
  final bool success;
  final String translatedText;
  final String? detectedSourceLang;
  final String? errorMessage;
  final int? statusCode;

  const DeeplTranslationResult({
    required this.success,
    required this.translatedText,
    this.detectedSourceLang,
    this.errorMessage,
    this.statusCode,
  });

  @override
  String toString() =>
      'DeeplTranslationResult(success: $success, translated: "$translatedText", detectedLang: $detectedSourceLang, error: $errorMessage)';
}

/// Service handling automated language translations via DeepL REST API.
/// Defaults to DeepL API Free (`https://api-free.deepl.com/v2/translate`),
/// auto-selecting Pro endpoint if key does not end in `:fx`.
class DeeplTranslationService {
  static const String prefKey = 'deepl_api_key';
  static const String defaultApiKey = '84c3da37-9f70-4cc9-9187-8149259640d2:fx';
  static const String freeEndpoint = 'https://api-free.deepl.com/v2/translate';
  static const String proEndpoint = 'https://api.deepl.com/v2/translate';

  final http.Client _client;
  String? _cachedApiKey;

  DeeplTranslationService({String? apiKey, http.Client? client})
      : _cachedApiKey = apiKey,
        _client = client ?? http.Client();

  /// Gets endpoint based on key type (:fx = free, else pro)
  static String getEndpointForKey(String apiKey) {
    if (apiKey.trim().endsWith(':fx')) {
      return freeEndpoint;
    }
    return proEndpoint;
  }

  /// Retrieves stored DeepL API key from memory cache, SharedPreferences, .env, or defaultApiKey.
  Future<String> getApiKey() async {
    if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
      return _cachedApiKey!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(prefKey);
      if (key != null && key.trim().isNotEmpty) {
        return key.trim();
      }
    } catch (_) {}

    try {
      final envKey = dotenv.env['DEEPL_API_KEY'];
      if (envKey != null && envKey.trim().isNotEmpty) {
        return envKey.trim();
      }
    } catch (_) {}

    return defaultApiKey;
  }

  /// Sets or clears the stored DeepL API key in SharedPreferences.
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

  /// Translates text to target language (e.g. 'GU' for Gujarati, 'EN' for English).
  Future<DeeplTranslationResult> translate({
    required String text,
    required String targetLang,
    String? sourceLang,
    String? apiKeyOverride,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return const DeeplTranslationResult(
        success: true,
        translatedText: '',
      );
    }

    final key = (apiKeyOverride ?? await getApiKey()).trim();
    if (key.isEmpty) {
      return const DeeplTranslationResult(
        success: false,
        translatedText: '',
        errorMessage: 'DeepL API key is not configured.',
      );
    }

    final endpoint = getEndpointForKey(key);

    try {
      final bodyFields = <String, String>{
        'text': trimmedText,
        'target_lang': targetLang.toUpperCase(),
      };
      if (sourceLang != null && sourceLang.isNotEmpty) {
        bodyFields['source_lang'] = sourceLang.toUpperCase();
      }

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'DeepL-Auth-Key $key',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: bodyFields,
      ).timeout(const Duration(seconds: 12));

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200 && data is Map && data['translations'] is List) {
        final translations = data['translations'] as List;
        if (translations.isNotEmpty) {
          final first = translations.first as Map<String, dynamic>;
          final translated = first['text']?.toString() ?? '';
          final detected = first['detected_source_language']?.toString();
          return DeeplTranslationResult(
            success: true,
            translatedText: translated,
            detectedSourceLang: detected,
            statusCode: 200,
          );
        }
      }

      final errorMsg = data is Map
          ? (data['message']?.toString() ?? data['error']?.toString() ?? 'Translation failed')
          : (response.body.isNotEmpty ? response.body : 'HTTP ${response.statusCode}');

      return DeeplTranslationResult(
        success: false,
        translatedText: trimmedText,
        errorMessage: '$errorMsg (Code: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return DeeplTranslationResult(
        success: false,
        translatedText: trimmedText,
        errorMessage: 'Network error connecting to DeepL: $e',
      );
    }
  }

  /// Convenience method to translate English text into Gujarati.
  Future<DeeplTranslationResult> translateToGujarati(String englishText) async {
    return translate(
      text: englishText,
      targetLang: 'GU',
      sourceLang: 'EN',
    );
  }

  /// Convenience method to translate Gujarati text into English.
  Future<DeeplTranslationResult> translateToEnglish(String gujaratiText) async {
    return translate(
      text: gujaratiText,
      targetLang: 'EN',
      sourceLang: 'GU',
    );
  }
}
