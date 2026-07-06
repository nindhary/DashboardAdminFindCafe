import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api.dart';

class ReportService {
  final String url = "${Api.baseUrl}/admin/reports";

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${prefs.getString("token")}",
    };
  }

  Future<List<dynamic>> getReports() async {
    final response = await http.get(Uri.parse(url), headers: await _headers());

    print("GET REPORT STATUS: ${response.statusCode}");
    print("GET REPORT BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"];
    }

    return [];
  }

  Future<bool> resolveReport(int id) async {
    final response = await http.patch(
      Uri.parse("$url/$id/resolve"),
      headers: await _headers(),
    );

    print("PATCH STATUS: ${response.statusCode}");
    print("PATCH BODY: ${response.body}");

    return response.statusCode == 200;
  }
}
