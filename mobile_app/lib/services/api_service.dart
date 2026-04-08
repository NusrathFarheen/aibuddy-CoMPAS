import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('BACKEND_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    
    // For local dev, use localhost/10.0.2.2.
    // For production, use --dart-define=BACKEND_URL=... during build
    if (kIsWeb) return 'http://127.0.0.1:8000';
    return 'http://10.0.2.2:8000';
  }

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    final groqKey = await AuthService.getGroqKey();
    
    final Map<String, String> h = {
      'Content-Type': 'application/json',
    };
    if (token != null) h['Authorization'] = 'Bearer $token';
    if (groqKey != null) h['X-Groq-Key'] = groqKey;
    return h;
  }

  // ── AUTH ───────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String username, String password) async {
    await AuthService.saveSession('dummy_token_bypassed', username);
    return {'access_token': 'dummy_token_bypassed', 'username': username, 'token_type': 'bearer'};
  }

  static Future<Map<String, dynamic>> register(String username, String password, {String? email}) async {
    await AuthService.saveSession('dummy_token_bypassed', username);
    return {'access_token': 'dummy_token_bypassed', 'username': username, 'email': email, 'token_type': 'bearer'};
  }

  // ── GOALS ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getGoals() async {
    final r = await http.get(Uri.parse('$baseUrl/api/goals'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load goals');
  }

  static Future<Map<String, dynamic>> createGoal(
      String title, String description, String? deadline, String? templateId) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/goals'),
      headers: await _headers(),
      body: json.encode({
        'title': title,
        'description': description,
        'deadline': deadline ?? '2026-12-31',
        'template_id': templateId ?? 'daily'
      }),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create goal');
  }

  static Future<Map<String, dynamic>> updateGoal(
      int id, Map<String, dynamic> updates) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/goals/$id'),
      headers: await _headers(),
      body: json.encode(updates),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to update goal');
  }

  static Future<void> deleteGoal(int id) async {
    await http.delete(Uri.parse('$baseUrl/api/goals/$id'), headers: await _headers());
  }

  // ── TASKS ──────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getTasks(int goalId) async {
    final r = await http.get(Uri.parse('$baseUrl/api/goals/$goalId/tasks'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load tasks');
  }

  static Future<Map<String, dynamic>> updateTask(
      int taskId, Map<String, dynamic> updates) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/tasks/$taskId'),
      headers: await _headers(),
      body: json.encode(updates),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to update task');
  }

  // ── ROUTINES ───────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getRoutines() async {
    final r = await http.get(Uri.parse('$baseUrl/api/routines'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load routines');
  }

  static Future<Map<String, dynamic>> createRoutine(
      String title, String category) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/routines'),
      headers: await _headers(),
      body: json.encode({'title': title, 'category': category}),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create routine');
  }

  static Future<Map<String, dynamic>> completeRoutine(int id) async {
    final r = await http.put(Uri.parse('$baseUrl/api/routines/$id/complete'), headers: await _headers());
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to complete routine');
  }

  // ── JOURNALS / NOTES ───────────────────────────────────

  static Future<List<Map<String, dynamic>>> getJournal() async {
    final r = await http.get(Uri.parse('$baseUrl/api/journal'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load journal');
  }

  static Future<Map<String, dynamic>> createJournal(
      String content, int moodScore) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/journal'),
      headers: await _headers(),
      body: json.encode({'content': content, 'mood_score': moodScore}),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create journal entry');
  }

  static Future<List<Map<String, dynamic>>> getNotes(int goalId) async {
    final r = await http.get(Uri.parse('$baseUrl/api/goals/$goalId/notes'), headers: await _headers());
    if (r.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    }
    return [];
  }

  static Future<Map<String, dynamic>> createNote(
      int goalId, String title, String content) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/notes'),
      headers: await _headers(),
      body:
          json.encode({'goal_id': goalId, 'title': title, 'content': content}),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create note');
  }

  static Future<List<Map<String, dynamic>>> getReferences(int goalId) async {
    final r = await http.get(Uri.parse('$baseUrl/api/goals/$goalId/references'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load references');
  }

  static Future<Map<String, dynamic>> createReference(
      int goalId, String title, String url) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/references'),
      headers: await _headers(),
      body: json.encode({'goal_id': goalId, 'title': title, 'url': url}),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create reference');
  }

  static Future<void> deleteReference(int id) async {
    await http.delete(Uri.parse('$baseUrl/api/references/$id'), headers: await _headers());
  }

  static Future<List<Map<String, dynamic>>> getFitnessLogs(int goalId, {String? type}) async {
    String url = '$baseUrl/api/goals/$goalId/fitness/logs';
    if (type != null) url += '?log_type=$type';
    final r = await http.get(Uri.parse(url), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load fitness logs');
  }

  static Future<Map<String, dynamic>> createFitnessLog(
      int goalId, String date, String type, String category, Map<String, dynamic> value) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/fitness/logs'),
      headers: await _headers(),
      body: json.encode({
        'goal_id': goalId,
        'date': date,
        'type': type,
        'category': category,
        'value': json.encode(value),
      }),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create fitness log');
  }

  static Future<List<Map<String, dynamic>>> getFitnessPhotos(int goalId) async {
    final r = await http.get(Uri.parse('$baseUrl/api/goals/$goalId/fitness/photos'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load fitness photos');
  }

  static Future<Map<String, dynamic>> createFitnessPhoto(
      int goalId, String date, String imagePath, String? caption) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/fitness/photos'),
      headers: await _headers(),
      body: json.encode({
        'goal_id': goalId,
        'date': date,
        'image_path': imagePath,
        'caption': caption,
      }),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create fitness photo');
  }

  static Future<String> uploadFile(List<int> bytes, String fileName) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload'));
    request.headers.addAll(await _headers());
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
      contentType: MediaType('image', fileName.split('.').last == 'png' ? 'png' : 'jpeg'),
    ));

    var response = await request.send();
    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      return json.decode(resBody)['url'];
    }
    throw Exception('Failed to upload file');
  }

  static Future<Map<String, dynamic>> finalizeGoal(int goalId) async {
    final r = await http.post(Uri.parse('$baseUrl/api/goals/$goalId/finalize'), headers: await _headers());
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to finalize goal');
  }

  static Future<List<Map<String, dynamic>>> getCreations() async {
    final r = await http.get(Uri.parse('$baseUrl/api/creations'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load creations');
  }

  static Future<Map<String, dynamic>> createCreation(
      String title, String content, String type) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/creations'),
      headers: await _headers(),
      body: json.encode({'title': title, 'content': content, 'type': type}),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to create creation');
  }

  static Future<Map<String, dynamic>> updateCreation(
      int id, Map<String, dynamic> updates) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/creations/$id'),
      headers: await _headers(),
      body: json.encode(updates),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to update creation');
  }

  static Future<void> deleteCreation(int id) async {
    await http.delete(Uri.parse('$baseUrl/api/creations/$id'), headers: await _headers());
  }

  static Future<Map<String, dynamic>> sendChat(String message,
      {int? goalId, String? role}) async {
    final Map<String, dynamic> body = {'message': message};
    if (goalId != null) body['goal_id'] = goalId;
    if (role != null) body['system_instruction'] = role;

    final r = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: await _headers(),
      body: json.encode(body),
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to send chat');
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(
      {int? goalId}) async {
    String url = '$baseUrl/api/chat/history';
    if (goalId != null) url += '?goal_id=$goalId';
    final r = await http.get(Uri.parse(url), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load chat history');
  }

  static Future<Map<String, dynamic>> getBriefing() async {
    final r = await http.get(Uri.parse('$baseUrl/director/briefing'), headers: await _headers());
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Failed to get briefing');
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final r = await http.get(Uri.parse('$baseUrl/api/notifications'), headers: await _headers());
    if (r.statusCode == 200)
      return List<Map<String, dynamic>>.from(json.decode(r.body));
    throw Exception('Failed to load notifications');
  }
}
