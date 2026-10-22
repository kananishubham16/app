import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

/// A reusable wrapper around the Google Gemini Generative AI SDK.
///
/// Provides simple text generation and streaming capabilities.
///
/// Usage:
/// ```dart
/// final gemini = GeminiService(apiKey: 'YOUR_KEY');
/// final response = await gemini.generateText('Explain photosynthesis.');
/// ```
class GeminiService {
  final GenerativeModel _model;

  GeminiService({
    required String apiKey,
    String modelName = 'gemini-flash-latest',
  }) : _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
        );

  /// Returns the underlying [GenerativeModel] for advanced use cases
  /// (e.g., multi-turn chat, custom generation configs).
  GenerativeModel get model => _model;

  /// Generates a text completion for the supplied [prompt].
  ///
  /// Optionally accepts [temperature] (0.0–1.0) and [maxTokens].
  Future<String> generateText(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          temperature: temperature,
          maxOutputTokens: maxTokens,
        ),
      );
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini.');
      }
      return text;
    } catch (e) {
      debugPrint('GeminiService error: $e');
      rethrow;
    }
  }

  /// Generates a JSON-formatted response for the supplied [prompt].
  ///
  /// The prompt should instruct the model to return valid JSON.
  /// This method returns the raw text response for the caller to parse.
  Future<String> generateJson(
    String prompt, {
    double temperature = 0.3,
    int maxTokens = 800,
  }) async {
    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          temperature: temperature,
          maxOutputTokens: maxTokens,
        ),
      );
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw Exception('Empty JSON response from Gemini.');
      }
      return text;
    } catch (e) {
      debugPrint('GeminiService JSON error: $e');
      rethrow;
    }
  }

  /// Streamed generation (token-by-token) — useful for chat-like UIs.
  Stream<String> generateStream(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async* {
    final stream = _model.generateContentStream(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        temperature: temperature,
        maxOutputTokens: maxTokens,
      ),
    );
    await for (final chunk in stream) {
      final text = chunk.text;
      if (text != null) {
        yield text;
      }
    }
  }
}
