import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_entry.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class StudyProvider with ChangeNotifier {
  List<StudyEntry> _entries = [];
  bool _isLoading = true;

  List<StudyEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  StudyProvider() {
    _loadData();
  }

  // --- Core Methods ---

  Future<void> logHours(double hours) async {
    final now = DateTime.now();
    // Normalize date to ignore time for daily aggregation
    final today = DateTime(now.year, now.month, now.day);

    // Check if we already have an entry for today
    final index = _entries.indexWhere(
      (e) =>
          e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day,
    );

    if (index != -1) {
      // Add to existing hours for today
      _entries[index] = StudyEntry(
        date: today,
        hours: _entries[index].hours + hours,
      );
    } else {
      // Create new entry
      _entries.add(StudyEntry(date: today, hours: hours));
    }

    // Sort entries by date
    _entries.sort((a, b) => a.date.compareTo(b.date));

    await _saveData();
    notifyListeners();
  }

  // --- Computed Properties for UI ---

  double get todayHours {
    final now = DateTime.now();
    final today = _entries.where(
      (e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day,
    );

    if (today.isEmpty) return 0.0;
    return today.first.hours;
  }

  int get currentStreak {
    if (_entries.isEmpty) return 0;

    int streak = 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if Last entry is today or yesterday. If older, streak is 0.
    final lastEntryDate = _entries.last.date;
    final diffToLastEntry = today.difference(lastEntryDate).inDays;

    if (diffToLastEntry > 1) {
      return 0; // Streak broken
    }

    // Traverse backwards and count consecutive days
    for (int i = _entries.length - 1; i > 0; i--) {
      final currentDay = _entries[i].date;
      final prevDay = _entries[i - 1].date;

      if (currentDay.difference(prevDay).inDays == 1) {
        streak++;
      } else {
        break; // Gap found, streak ends
      }
    }

    // If diffToLastEntry == 1 (meaning last log was yesterday, haven't logged today yet),
    // the streak is mathematically correct as calculated. Check for edge case if length was 1.
    return streak;
  }

  // Returns data for the last 7 days formatted for a chart
  // List of maps containing {day: 'Mon', hours: 2.5}
  List<Map<String, dynamic>> get weeklyData {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));

      final entry = _entries.firstWhere(
        (e) =>
            e.date.year == targetDate.year &&
            e.date.month == targetDate.month &&
            e.date.day == targetDate.day,
        orElse: () => StudyEntry(date: targetDate, hours: 0.0),
      );

      data.add({
        'day': DateFormat('E').format(targetDate), // e.g., 'Mon'
        'hours': entry.hours,
      });
    }
    return data;
  }

  // --- Local Storage (SharedPreferences) ---

  static const String _storageKey = 'lazy_tracker_entries';

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? dataString = prefs.getString(_storageKey);

      if (dataString != null) {
        final List<dynamic> decodedList = json.decode(dataString);
        _entries = decodedList
            .map((item) => StudyEntry.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encodedList = _entries.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(encodedList));
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }
}
