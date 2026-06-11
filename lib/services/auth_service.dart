import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password.trim()}),
      );

      print('BASE URL: ${Api.baseUrl}');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['data']?['token'];
        final user = data['data']?['user'];

        print('TOKEN: $token');
        print('USER: $user');

        if (token == null) {
          print('TOKEN NULL');
          return false;
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);
        await prefs.setString('role', user?['role']?.toString() ?? '');
        await prefs.setString('name', user?['name']?.toString() ?? '');

        print('LOGIN SUCCESS');

        return true;
      }

      print('LOGIN FAILED: ${response.body}');
      return false;
    } catch (e, stackTrace) {
      print('ERROR LOGIN: $e');
      print(stackTrace);
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('name');
      
      print('Logout berhasil: Data sesi dihapus');
    } catch (e) {
      print('ERROR LOGOUT: $e');
      rethrow; 
    }
  }
}
