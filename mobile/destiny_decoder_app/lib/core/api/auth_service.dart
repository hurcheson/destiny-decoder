"""
Auth service for JWT-based authentication with the backend.
Handles signup, login, token storage, and auto-login.
"""

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => message;
}


class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String subscriptionTier;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.subscriptionTier,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      subscriptionTier: json['subscription_tier'] ?? 'free',
    );
  }
}


class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _subscriptionTierKey = 'subscription_tier';
  
  final FlutterSecureStorage _secureStorage;
  final String _baseUrl;
  
  StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  AuthService({
    required String baseUrl,
    required FlutterSecureStorage secureStorage,
  })  : _baseUrl = baseUrl,
        _secureStorage = secureStorage;

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Get stored JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  // Get stored email
  Future<String?> getEmail() async {
    return await _secureStorage.read(key: _emailKey);
  }

  // Get subscription tier
  Future<String?> getSubscriptionTier() async {
    return await _secureStorage.read(key: _subscriptionTierKey);
  }

  // Sign up new user
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        
        // Store credentials securely
        await _storeAuthData(authResponse);
        _authStateController.add(true);
        
        return authResponse;
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw AuthException(
          message: error['detail'] ?? 'Sign up failed',
          code: 'signup_error',
        );
      } else {
        throw AuthException(
          message: 'Sign up failed: ${response.statusCode}',
          code: 'server_error',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error during sign up: $e',
        code: 'network_error',
      );
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        
        // Store credentials securely
        await _storeAuthData(authResponse);
        _authStateController.add(true);
        
        return authResponse;
      } else if (response.statusCode == 401) {
        throw AuthException(
          message: 'Invalid email or password',
          code: 'invalid_credentials',
        );
      } else {
        throw AuthException(
          message: 'Login failed: ${response.statusCode}',
          code: 'server_error',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Network error during login: $e',
        code: 'network_error',
      );
    }
  }

  // Verify token validity
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/verify?token=$token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Refresh token
  Future<String?> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh?token=$token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['token'] as String;
        
        // Update stored token
        await _secureStorage.write(key: _tokenKey, value: newToken);
        return newToken;
      }
    } catch (e) {
      // Silent fail, let app handle re-login
    }
    return null;
  }

  // Store auth data securely
  Future<void> _storeAuthData(AuthResponse response) async {
    await Future.wait([
      _secureStorage.write(key: _tokenKey, value: response.token),
      _secureStorage.write(key: _userIdKey, value: response.userId),
      _secureStorage.write(key: _emailKey, value: response.email),
      _secureStorage.write(key: _subscriptionTierKey, value: response.subscriptionTier),
    ]);
  }

  // Logout
  Future<void> logout() async {
    await Future.wait([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _emailKey),
      _secureStorage.delete(key: _subscriptionTierKey),
    ]);
    _authStateController.add(false);
  }

  void dispose() {
    _authStateController.close();
  }
}
