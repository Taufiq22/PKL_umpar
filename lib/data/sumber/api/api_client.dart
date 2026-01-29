import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:umpar_magang_dan_pkl/konfigurasi/konstanta.dart';

/// Response wrapper untuk API calls
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: _parseMessage(json['message']),
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  static String _parseMessage(dynamic message) {
    if (message == null) return '';
    if (message is String) return message;
    if (message is List) {
      return message.join('\n'); // Join list elements with newline
    }
    if (message is Map) {
      // If message is a map (e.g. validation errors), flatten values
      return message.values.join('\n');
    }
    return message.toString();
  }
}

/// API Client untuk komunikasi dengan backend PHP
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;

  /// Set token untuk autentikasi
  void setToken(String? token) {
    _token = token;
  }

  /// Get headers dengan token
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${ApiKonstanta.baseUrl}$endpoint')
          .replace(queryParameters: queryParams);

      // Debug: Log request info
      debugPrint('API GET: $uri');
      debugPrint('Token present: ${_token != null}');

      final response =
          await http.get(uri, headers: _headers).timeout(ApiKonstanta.timeout);

      // Debug: Log response status
      debugPrint('Response status: ${response.statusCode}');

      return _handleResponse(response, fromJson);
    } catch (e) {
      debugPrint('API Error: $e');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiKonstanta.baseUrl}$endpoint');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiKonstanta.timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiKonstanta.baseUrl}$endpoint');

      final response = await http
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiKonstanta.timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiKonstanta.baseUrl}$endpoint');

      final response = await http
          .delete(uri, headers: _headers)
          .timeout(ApiKonstanta.timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// POST multipart request (untuk upload file)
  Future<ApiResponse<T>> upload<T>(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiKonstanta.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse =
          await request.send().timeout(ApiKonstanta.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan upload: ${e.toString()}',
      );
    }
  }

  /// Handle response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      // Debug: Log raw response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint(
          'Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

      final json = jsonDecode(response.body);
      return ApiResponse.fromJson(json, fromJson);
    } catch (e) {
      // Debug: Log the actual error and response
      debugPrint('JSON Parse Error: $e');
      debugPrint('Raw response body: ${response.body}');

      return ApiResponse(
        success: false,
        message: 'Gagal memproses response: ${e.toString()}',
      );
    }
  }
}
