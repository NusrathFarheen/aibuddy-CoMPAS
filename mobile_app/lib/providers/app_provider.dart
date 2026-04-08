import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  List<Map<String, dynamic>> goals = [];
  List<Map<String, dynamic>> routines = [];
  List<Map<String, dynamic>> journal = [];
  List<Map<String, dynamic>> creations = [];
  List<Map<String, dynamic>> chatMessages = [];
  Map<String, dynamic>? briefing;
  
  bool isFocusMode = false;
  String selectedAmbience = "Silence";
  bool isLoading = false;
  String? error;

  // ── AUDIO & TIMER ───────────────────────────────────
  final AudioPlayer _ambiencePlayer = AudioPlayer();
  final AudioPlayer _alarmPlayer = AudioPlayer();
  
  Timer? _focusTimer;
  int focusSeconds = 0;
  int initialFocusMinutes = 15;
  bool isTimerRunning = false;

  // ── LOAD ALL ───────────────────────────────────────────

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();
    try {
      goals = await ApiService.getGoals();
      routines = await ApiService.getRoutines();
      journal = await ApiService.getJournal();
      creations = await ApiService.getCreations();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // ── DIRECTOR & FOCUS ───────────────────────────────────

  Future<void> loadBriefing() async {
    try {
      briefing = await ApiService.getBriefing();
      notifyListeners();
    } catch (e) {
      briefing = {'briefing': 'Director is offline. Connect to backend.', 'error': e.toString()};
      notifyListeners();
    }
  }

  void toggleFocusMode() {
    isFocusMode = !isFocusMode;
    if (!isFocusMode) {
      _ambiencePlayer.stop();
      stopTimer();
    } else {
      _refreshAmbience();
    }
    notifyListeners();
  }

  void setAmbience(String ambience) {
    selectedAmbience = ambience;
    if (isFocusMode) {
      _refreshAmbience();
    }
    notifyListeners();
  }

  Future<void> _refreshAmbience() async {
    await _ambiencePlayer.stop();
    if (selectedAmbience == "Silence") return;
    
    String fileName = "${selectedAmbience.toLowerCase()}.mp3";
    try {
      await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
      await _ambiencePlayer.play(AssetSource("audio/$fileName"));
    } catch (e) {
      debugPrint("Error playing ambience: $e");
    }
  }

  // ── TIMER LOGIC ──────────────────────────────────────

  void setTimerMinutes(int minutes) {
    initialFocusMinutes = minutes;
    focusSeconds = minutes * 60;
    notifyListeners();
  }

  void startTimer() {
    if (isTimerRunning) return;
    
    if (focusSeconds == 0) {
      focusSeconds = initialFocusMinutes * 60;
    }
    
    isTimerRunning = true;
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (focusSeconds > 0) {
        focusSeconds--;
        notifyListeners();
      } else {
        _handleTimerEnd();
      }
    });
    notifyListeners();
  }

  void stopTimer() {
    isTimerRunning = false;
    _focusTimer?.cancel();
    _alarmPlayer.stop();
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    focusSeconds = initialFocusMinutes * 60;
    notifyListeners();
  }

  void _handleTimerEnd() {
    stopTimer();
    _playAlarm();
  }

  Future<void> _playAlarm() async {
    try {
      await _alarmPlayer.play(AssetSource("audio/timer go off music.mp3"));
    } catch (e) {
      debugPrint("Error playing alarm: $e");
    }
  }

  String get timerString {
    int minutes = focusSeconds ~/ 60;
    int seconds = focusSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // ── GOALS ──────────────────────────────────────────────

  Future<void> loadGoals() async {
    try {
      goals = await ApiService.getGoals();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addGoal(String title, String desc, String? deadline, String? templateId) async {
    try {
      final finalDeadline = deadline ?? _parseDeadlineToDate(title);
      await ApiService.createGoal(title, desc, finalDeadline, templateId);
      await loadGoals();
    } catch (_) {}
  }

  String _parseDeadlineToDate(String title) {
    final lower = title.toLowerCase();
    final now = DateTime.now();
    
    // Improved Regex to catch "in 2 months", "2 months left", etc.
    final monthMatch = RegExp(r'(\d+)\s*month').firstMatch(lower);
    if (monthMatch != null) {
      final months = int.parse(monthMatch.group(1)!);
      return now.add(Duration(days: months * 30)).toIso8601String().split('T')[0];
    }
    
    final weekMatch = RegExp(r'(\d+)\s*week').firstMatch(lower);
    if (weekMatch != null) {
      final weeks = int.parse(weekMatch.group(1)!);
      return now.add(Duration(days: weeks * 7)).toIso8601String().split('T')[0];
    }
    
    final dayMatch = RegExp(r'(\d+)\s*day').firstMatch(lower);
    if (dayMatch != null) {
      final days = int.parse(dayMatch.group(1)!);
      return now.add(Duration(days: days)).toIso8601String().split('T')[0];
    }

    if (lower.contains('today')) {
       return now.toIso8601String().split('T')[0];
    }
    if (lower.contains('tomorrow')) {
      return now.add(const Duration(days: 1)).toIso8601String().split('T')[0];
    }

    // Dynamic default: 30 days if no match
    return now.add(const Duration(days: 30)).toIso8601String().split('T')[0];
  }

  Future<void> deleteGoal(int id) async {
    try {
      await ApiService.deleteGoal(id);
      await loadGoals();
    } catch (_) {}
  }

  Future<void> updateGoal(int id, String title, String desc, String? deadline) async {
    try {
      final finalDeadline = deadline ?? _parseDeadlineToDate(title);
      await ApiService.updateGoal(id, {
        'title': title,
        'description': desc,
        'deadline': finalDeadline,
      });
      await loadGoals();
    } catch (_) {}
  }

  Future<void> archiveGoal(int id) async {
    try {
      await ApiService.updateGoal(id, {'is_archived': 1});
      await loadGoals();
    } catch (_) {}
  }

  // ── ROUTINES ───────────────────────────────────────────

  Future<void> loadRoutines() async {
    try {
      routines = await ApiService.getRoutines();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addRoutine(String title, String category) async {
    try {
      await ApiService.createRoutine(title, category);
      await loadRoutines();
    } catch (_) {}
  }

  Future<void> completeRoutine(int id) async {
    try {
      await ApiService.completeRoutine(id);
      await loadRoutines();
    } catch (_) {}
  }

  // ── JOURNAL ────────────────────────────────────────────

  Future<void> loadJournal() async {
    try {
      journal = await ApiService.getJournal();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addJournal(String content, int mood) async {
    try {
      await ApiService.createJournal(content, mood);
      await loadJournal();
    } catch (_) {}
  }

  // ── CREATIONS ──────────────────────────────────────────

  Future<void> loadCreations() async {
    try {
      creations = await ApiService.getCreations();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addCreation(String title, String content, String type) async {
    try {
      await ApiService.createCreation(title, content, type);
      await loadCreations();
    } catch (_) {}
  }

  Future<void> updateCreation(int id, Map<String, dynamic> data) async {
    try {
      await ApiService.updateCreation(id, data);
      await loadCreations();
    } catch (_) {}
  }

  Future<void> deleteCreation(int id) async {
    try {
      await ApiService.deleteCreation(id);
      await loadCreations();
    } catch (_) {}
  }

  Future<void> archiveCreation(int id) async {
    try {
      await ApiService.updateCreation(id, {'is_archived': 1});
      await loadCreations();
    } catch (_) {}
  }

  // ── CHAT ───────────────────────────────────────────────

  Future<void> loadChatHistory() async {
    try {
      chatMessages = await ApiService.getChatHistory();
      notifyListeners();
    } catch (_) {}
  }

  Future<String> sendChat(String message) async {
    try {
      final result = await ApiService.sendChat(message);
      await loadChatHistory();
      return result['response'] ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
