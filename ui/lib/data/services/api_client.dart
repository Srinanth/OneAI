import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class ApiClient {
  static Future<Map<String, String>> _getHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('User not logged in');
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  static Future<Map<String, dynamic>> startChat(String title, String modelId,String apiKey) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/chat/start');
    final headers = await _getHeaders();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final body = jsonEncode({
      'title': title, 
      'modelId': modelId,
      'userId': user.id,
      'apiKey': apiKey,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Start Chat Failed: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendMessage(
    String chatId, 
    String message, 
    String modelId, 
    String apiKey
  ) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/chat/$chatId/message');
    final headers = await _getHeaders();
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final body = jsonEncode({
      'message': message,
      'modelId': modelId,
      'apiKey': apiKey,
      'userId': user.id,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Send Message Failed: ${response.body}');
    }

    return jsonDecode(response.body);
  }
  
  static Future<int> fetchUsage(String modelId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 0;

    final url = Uri.parse('${AppConstants.apiBaseUrl}/usage/${user.id}/$modelId');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['usage'] as int;
    }
    return 0;
  }
}