import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api.dart';

class AdminService {
  Future<List<dynamic>> getPlaces([String status = '']) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      String url = '${Api.baseUrl}/admin/places';

      if (status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['data'];
      }

      return [];
    } catch (e) {
      print('ERROR GET PLACES: $e');
      return [];
    }
  }

  Future<bool> approvePlace(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.patch(
        Uri.parse('${Api.baseUrl}/admin/places/$id/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> rejectPlace(String id, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.patch(
        Uri.parse('${Api.baseUrl}/admin/places/$id/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rejectionReason': reason}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
