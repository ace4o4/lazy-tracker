import 'dart:convert';

class StudyEntry {
  final DateTime date;
  final double hours;

  StudyEntry({
    required this.date,
    required this.hours,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'hours': hours,
    };
  }

  factory StudyEntry.fromMap(Map<String, dynamic> map) {
    return StudyEntry(
      date: DateTime.parse(map['date']),
      hours: map['hours']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StudyEntry.fromJson(String source) => 
      StudyEntry.fromMap(json.decode(source));
}
