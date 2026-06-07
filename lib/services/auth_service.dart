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
        body: jsonEncode({'email': email, 'password': password}),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final token = data['data']['token'];

        final user = data['data']['user'];

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);

        await prefs.setString('role', user['role']);

        await prefs.setString('name', user['name']);

        return true;
      }

      return false;
    } catch (e) {
      print('ERROR LOGIN: $e');
      return false;
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
