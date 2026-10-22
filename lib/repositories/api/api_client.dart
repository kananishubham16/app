import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({String? baseUrl, http.Client? httpClient})
      : baseUrl = baseUrl ?? _resolveDefaultBaseUrl(),
        _httpClient = httpClient ?? http.Client();

  static String _resolveDefaultBaseUrl() {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback to host machine
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {
      // Fallback
    }
    return 'http://localhost:8000/api';
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final uri = _buildUri(path, queryParameters);
    final response = await _httpClient.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    final uri = _buildUri(path, null);
    final response = await _httpClient.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    final uri = _buildUri(path, null);
    final response = await _httpClient.patch(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final urlStr = '$base$cleanPath';

    final uri = Uri.parse(urlStr);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final sanitizedParams = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        sanitizedParams[key] = value.toString();
      }
    });

    return uri.replace(queryParameters: sanitizedParams);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    throw ApiException(
      response.statusCode,
      response.body.isNotEmpty ? response.body : response.reasonPhrase ?? 'Request failed',
    );
  }
}
