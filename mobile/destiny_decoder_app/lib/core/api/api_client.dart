"""
HTTP client with automatic error handling and feature gate management.
Catches 403 Forbidden errors and routes to paywall screen.
"""

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';


class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  final Map<String, dynamic>? data;

  ApiException({
    required this.message,
    required this.statusCode,
    this.code,
    this.data,
  });

  bool get isForbidden => statusCode == 403;
  bool get isUnauthorized => statusCode == 401;
  bool get isPaymentRequired => statusCode == 402;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() => '$statusCode: $message';
}


class ApiClient {
  final String baseUrl;
  final Future<String?> Function() getToken;
  final VoidCallback onForbidden; // Navigate to paywall
  final VoidCallback onUnauthorized; // Navigate to login

  ApiClient({
    required this.baseUrl,
    required this.getToken,
    required this.onForbidden,
    required this.onUnauthorized,
  });

  // Helper to get headers with auth token
  Future<Map<String, String>> _getHeaders({
    String contentType = 'application/json',
  }) async {
    final token = await getToken();
    return {
      'Content-Type': contentType,
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle error responses
  ApiException _handleErrorResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiException(
        message: body['detail'] ?? 'Unknown error',
        statusCode: response.statusCode,
        code: body['error'],
        data: body,
      );
    } catch (e) {
      return ApiException(
        message: response.body.isNotEmpty
            ? response.body
            : 'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        onForbidden();
        throw _handleErrorResponse(response);
      } else if (response.statusCode == 401) {
        onUnauthorized();
        throw _handleErrorResponse(response);
      } else if (response.statusCode >= 400) {
        throw _handleErrorResponse(response);
      }

      throw ApiException(
        message: 'Unexpected status code',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        onForbidden();
        throw _handleErrorResponse(response);
      } else if (response.statusCode == 402) {
        // Payment required - premium feature
        onForbidden();
        throw _handleErrorResponse(response);
      } else if (response.statusCode == 401) {
        onUnauthorized();
        throw _handleErrorResponse(response);
      } else if (response.statusCode >= 400) {
        throw _handleErrorResponse(response);
      }

      throw ApiException(
        message: 'Unexpected status code',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        onForbidden();
        throw _handleErrorResponse(response);
      } else if (response.statusCode == 401) {
        onUnauthorized();
        throw _handleErrorResponse(response);
      } else if (response.statusCode >= 400) {
        throw _handleErrorResponse(response);
      }

      throw ApiException(
        message: 'Unexpected status code',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  // DELETE request
  Future<void> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        onForbidden();
        throw _handleErrorResponse(response);
      } else if (response.statusCode == 401) {
        onUnauthorized();
        throw _handleErrorResponse(response);
      } else if (response.statusCode >= 400) {
        throw _handleErrorResponse(response);
      }

      throw ApiException(
        message: 'Unexpected status code',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }
}
