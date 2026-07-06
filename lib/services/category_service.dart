import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api.dart';

class CategoryService {
  final String url = "${Api.baseUrl}/admin/categories";

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<List<dynamic>> getCategories() async {
    final response = await http.get(Uri.parse(url), headers: await _headers());

    print("GET STATUS: ${response.statusCode}");
    print("GET BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }

    return [];
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    print("POST STATUS: ${response.statusCode}");
    print("POST BODY: ${response.body}");

    return response.statusCode == 201;
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$url/$id"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    print("PUT STATUS: ${response.statusCode}");
    print("PUT BODY: ${response.body}");

    return response.statusCode == 200;
  }

  Future<bool> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse("$url/$id"),
      headers: await _headers(),
    );

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE BODY: ${response.body}");

    return response.statusCode == 200;
  }
}
