import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api/auth';
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final user = responseData['user'];
      
      await Future.wait([
        prefs.setString('token', responseData['access_token']),
        prefs.setString('user_id', user['id'].toString()),
        prefs.setString('name', user['name'] ?? ''),
        prefs.setString('email', user['email'] ?? ''),
        prefs.setString('role', user['role'] ?? ''),
        if (user['karyawan'] != null) ...[
          prefs.setString('karyawan_id', user['karyawan']['id']?.toString() ?? ''),
          prefs.setString('nip', user['karyawan']['nip'] ?? ''),
          prefs.setString('nama', user['karyawan']['nama'] ?? ''),
        ]
      ]);
      
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(
    String name, 
    String email, 
    String password,
    String passwordConfirmation,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200 || response.statusCode == 201) { 
      final prefs = await SharedPreferences.getInstance();
      final user = responseData['user'];

      await Future.wait([
        prefs.setString('token', responseData['access_token']),
        prefs.setString('user_id', user['id'].toString()),
        prefs.setString('name', user['name'] ?? ''),
        prefs.setString('email', user['email'] ?? ''),
      ]);
      // ---------------------------------------------------
      
      return responseData;
    } else {
      String errorMessage = 'Registration failed';
      if (responseData.containsKey('errors')) {
        errorMessage = responseData['errors'].entries.first.value[0];
      } else if (responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      }
      throw Exception(errorMessage);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }
    
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}