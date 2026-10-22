import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learning_setu/services/deepl_translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeepL Translation Service Tests', () {
    test('Correctly identifies Free vs Pro endpoints based on API key suffix', () {
      expect(
        DeeplTranslationService.getEndpointForKey('84c3da37-9f70-4cc9-9187-8149259640d2:fx'),
        'https://api-free.deepl.com/v2/translate',
      );
      expect(
        DeeplTranslationService.getEndpointForKey('my_pro_key_without_fx'),
        'https://api.deepl.com/v2/translate',
      );
    });

    test('Initializes with default provided API key', () async {
      final service = DeeplTranslationService();
      final key = await service.getApiKey();
      expect(key, '84c3da37-9f70-4cc9-9187-8149259640d2:fx');
    });

    test('Returns empty translation for empty text without network call', () async {
      final service = DeeplTranslationService();
      final result = await service.translate(text: '   ', targetLang: 'GU');
      expect(result.success, isTrue);
      expect(result.translatedText, isEmpty);
    });

    test('Translates text successfully via MockClient', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://api-free.deepl.com/v2/translate');
        expect(request.headers['Authorization'], 'DeepL-Auth-Key 84c3da37-9f70-4cc9-9187-8149259640d2:fx');
        expect(request.bodyFields['target_lang'], 'GU');
        expect(request.bodyFields['text'], 'Good morning');

        return http.Response(
          jsonEncode({
            'translations': [
              {
                'detected_source_language': 'EN',
                'text': 'સુપ્રભાત',
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = DeeplTranslationService(client: mockClient);
      final result = await service.translateToGujarati('Good morning');

      expect(result.success, isTrue);
      expect(result.translatedText, 'સુપ્રભાત');
      expect(result.detectedSourceLang, 'EN');
    });

    test('Handles DeepL API errors gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Quota exceeded'}),
          429,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = DeeplTranslationService(client: mockClient);
      final result = await service.translate(text: 'Hello', targetLang: 'GU');

      expect(result.success, isFalse);
      expect(result.statusCode, 429);
      expect(result.errorMessage, contains('Quota exceeded'));
    });
  });
}
