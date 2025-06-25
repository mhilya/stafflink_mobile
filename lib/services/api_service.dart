import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  String? _token;

  Future<void> _initToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    await _initToken();
    if (kDebugMode) {
      print('API GET Request: $_baseUrl/$endpoint');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _buildHeaders(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, {required Map<String, dynamic> body}) async {
    await _initToken();
    if (kDebugMode) {
      print('API POST Request: $_baseUrl/$endpoint');
      print('Request Body: $body');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, {required Map<String, dynamic> body}) async {
    await _initToken();
    if (kDebugMode) {
      print('API PUT Request: $_baseUrl/$endpoint');
      print('Request Body: $body');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders() {
    return {
      'Authorization': _token != null ? 'Bearer $_token' : '',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('API Response [${response.statusCode}]: ${response.body}');
    }

    try {
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Request failed',
          statusCode: response.statusCode,
          data: responseData,
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  void setToken(String token) {
    _token = token;
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  var stackTrace;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}