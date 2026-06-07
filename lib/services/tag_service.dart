import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';

class TagService {
  final String url = "${Api.baseUrl}/tags";

  Future<List<dynamic>> getTags() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }

    return [];
  }

  Future<bool> createTag(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateTag(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse("$url/$id"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteTag(int id) async {
    final response = await http.delete(
      Uri.parse("$url/$id"),
    );

    return response.statusCode == 200;
  }
}