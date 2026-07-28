import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static String cloudflareUrl = 'https://brunswick-revelation-skirts-within.trycloudflare.com';

  static String baseUrl = 'http://192.168.101.70:8000';

  static List<String> get fallbackUrls => [
        if (cloudflareUrl.isNotEmpty) cloudflareUrl,
        'http://192.168.101.70:8000',
        'http://localhost:8000',
        'http://10.0.2.2:8000',
      ];
}

class ApiService {
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    for (final host in ApiConfig.fallbackUrls) {
      try {
        final res = await http.post(
          Uri.parse('$host/api/mobile/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          final data = json.decode(res.body);
          if (data['ok'] == true) {
            return data['user'];
          }
        }
      } catch (e) {
        debugPrint('Login attempt failed on $host: $e');
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>> fetchDashboardStats() async {
    for (final host in [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls]) {
      try {
        final res = await http.get(
          Uri.parse('$host/api/visitors/stats?days=30'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          return json.decode(res.body);
        }
      } catch (e) {
        debugPrint('Error fetch stats on $host: $e');
      }
    }
    return {'total_visitors': 0, 'total_pageviews': 0};
  }

  static Future<List<dynamic>> fetchProjects() async {
    for (final host in [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls]) {
      try {
        final res = await http.get(
          Uri.parse('$host/api/projects'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          final data = json.decode(res.body);
          if (data is List) return data;
          if (data is Map && data.containsKey('data')) return data['data'];
        }
      } catch (e) {
        debugPrint('Error fetch projects on $host: $e');
      }
    }
    return [];
  }

  static Future<bool> createProject(Map<String, dynamic> data) async {
    for (final host in [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls]) {
      try {
        final res = await http.post(
          Uri.parse('$host/api/mobile/projects'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(data),
        ).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200 || res.statusCode == 201) {
          ApiConfig.baseUrl = host;
          return true;
        }
      } catch (e) {
        debugPrint('Error create project on $host: $e');
      }
    }
    return false;
  }

  static Future<List<dynamic>> fetchUserMessages() async {
    for (final host in [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls]) {
      try {
        final res = await http.get(
          Uri.parse('$host/api/mobile/messages'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          final data = json.decode(res.body);
          if (data is List) return data;
          if (data is Map && data.containsKey('data')) return data['data'];
        }
      } catch (e) {
        debugPrint('Error fetch messages on $host: $e');
      }
    }
    return [];
  }

  static Future<bool> sendUserMessage(Map<String, dynamic> payload) async {
    for (final host in [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls]) {
      try {
        final res = await http.post(
          Uri.parse('$host/api/messages'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(payload),
        ).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200 || res.statusCode == 201) {
          ApiConfig.baseUrl = host;
          return true;
        }
      } catch (e) {
        debugPrint('Error send message on $host: $e');
      }
    }
    return false;
  }

  static Future<String> askAi(String message) async {
    for (final host in [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls]) {
      try {
        final res = await http.post(
          Uri.parse('$host/api/chatbot'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'message': message}),
        ).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          final data = json.decode(res.body);
          return data['reply'] ?? 'Tidak ada balasan.';
        }
      } catch (e) {
        debugPrint('Error AI chat on $host: $e');
      }
    }
    return 'Gagal terhubung ke Naoo Helper AI. Pastikan server Laravel aktif.';
  }
}
