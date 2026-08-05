import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static String cloudflareUrl = 'https://backed-italiano-ends-nec.trycloudflare.com';

  static String baseUrl = 'https://backed-italiano-ends-nec.trycloudflare.com';

  static List<String> get fallbackUrls => [
        if (cloudflareUrl.isNotEmpty) cloudflareUrl,
        'http://192.168.101.70:8000',
        'http://localhost:8000',
        'http://10.0.2.2:8000',
      ];
}

class ApiService {
  static String formatImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://') || rawUrl.startsWith('data:image')) {
      return rawUrl;
    }
    final cleanPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '${ApiConfig.baseUrl}$cleanPath';
  }

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

  static Future<List<dynamic>> fetchDirectUsers({int? currentUserId}) async {
    final hosts = {ApiConfig.baseUrl, ...ApiConfig.fallbackUrls}.toList();
    for (final host in hosts) {
      try {
        final url = currentUserId != null
            ? '$host/api/mobile/user-chats/users?sender_id=$currentUserId'
            : '$host/api/mobile/user-chats/users';
        final res = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          final data = json.decode(res.body);
          if (data is List) return data;
        }
      } catch (e) {
        debugPrint('Error fetch direct users on $host: $e');
      }
    }
    return [];
  }

  static Future<List<dynamic>> fetchDirectHistory(int receiverId, {int? currentUserId}) async {
    final hosts = {ApiConfig.baseUrl, ...ApiConfig.fallbackUrls}.toList();
    for (final host in hosts) {
      try {
        final url = currentUserId != null
            ? '$host/api/mobile/user-chats/$receiverId?sender_id=$currentUserId'
            : '$host/api/mobile/user-chats/$receiverId';
        final res = await http.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          final data = json.decode(res.body);
          if (data is List) return data;
        }
      } catch (e) {
        debugPrint('Error fetch direct history on $host: $e');
      }
    }
    return [];
  }

  static Future<bool> sendDirectMessage(int receiverId, String message, {dynamic file, int? senderId}) async {
    final hosts = {ApiConfig.baseUrl, ...ApiConfig.fallbackUrls}.toList();
    for (final host in hosts) {
      try {
        if (file != null) {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('$host/api/mobile/user-chats?receiver_id=$receiverId&sender_id=${senderId ?? 1}'),
          );
          request.headers['Accept'] = 'application/json';
          request.fields['receiver_id'] = receiverId.toString();
          request.fields['message'] = message;
          if (senderId != null) request.fields['sender_id'] = senderId.toString();
          request.files.add(await http.MultipartFile.fromPath('file', file.path));

          final streamedResponse = await request.send().timeout(const Duration(seconds: 12));
          final res = await http.Response.fromStream(streamedResponse);
          if (res.statusCode == 200 || res.statusCode == 201) {
            ApiConfig.baseUrl = host;
            return true;
          }
        } else {
          final res = await http.post(
            Uri.parse('$host/api/mobile/user-chats?receiver_id=$receiverId&sender_id=${senderId ?? 1}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'receiver_id': receiverId,
              'message': message,
              if (senderId != null) 'sender_id': senderId,
            }),
          ).timeout(const Duration(seconds: 5));
          if (res.statusCode == 200 || res.statusCode == 201) {
            ApiConfig.baseUrl = host;
            return true;
          }
        }
      } catch (e) {
        debugPrint('Error send direct message on $host: $e');
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

  static Future<bool> replyUserMessage(int messageId, String body) async {
    for (final host in [ApiConfig.baseUrl, ...ApiConfig.fallbackUrls]) {
      try {
        final res = await http.post(
          Uri.parse('$host/api/mobile/messages/$messageId/reply'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({'body': body}),
        ).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          ApiConfig.baseUrl = host;
          return true;
        }
      } catch (e) {
        debugPrint('Error reply message on $host: $e');
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
