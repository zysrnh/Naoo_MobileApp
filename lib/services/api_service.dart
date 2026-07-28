import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  // IP Laptop kamu di Wi-Fi agar HP fisik Android (2312FPCA6G) bisa tersambung 100% ke backend Laravel
  static String baseUrl = 'http://192.168.101.70:8000';
}

class ApiService {
  static Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/visitors/stats?days=30'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      debugPrint('Error fetch stats: $e');
    }
    return {'total_visitors': 0, 'total_pageviews': 0};
  }

  static Future<List<dynamic>> fetchProjects() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/projects'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List) return data;
        if (data is Map && data.containsKey('data')) return data['data'];
      }
    } catch (e) {
      debugPrint('Error fetch projects: $e');
    }
    return [];
  }

  static Future<bool> createProject(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/projects'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(data),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Error create project: $e');
      return false;
    }
  }

  static Future<String> askAi(String message) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chatbot'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'message': message}),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['reply'] ?? 'Tidak ada balasan.';
      }
    } catch (e) {
      debugPrint('Error AI chat: $e');
    }
    return 'Gagal terhubung ke Naoo Helper AI.';
  }
}
