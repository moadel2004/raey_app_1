import 'package:flutter/material.dart';

const _dayMap = {
  'sunday': 0, 'monday': 1, 'tuesday': 2, 'wednesday': 3,
  'thursday': 4, 'friday': 5, 'saturday': 6,
};

const kDayNamesAr = [
  'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
];

class AvailabilityModel {
  const AvailabilityModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  final int id;
  final int dayOfWeek; // stored as int internally
  final String startTime; // "09:00:00"
  final String endTime;
  final bool isActive;

  String get dayNameAr => (dayOfWeek >= 0 && dayOfWeek < kDayNamesAr.length)
      ? kDayNamesAr[dayOfWeek]
      : 'غير محدد';

  TimeOfDay get startTimeOfDay => _parseTime(startTime);
  TimeOfDay get endTimeOfDay   => _parseTime(endTime);

  Map<String, dynamic> toCreateJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      };

  Map<String, dynamic> toUpdateJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'isActive': isActive,
      };

  factory AvailabilityModel.fromJson(Map<String, dynamic> j) {
    final raw = j['dayOfWeek'];
    final int day;
    if (raw is int) {
      day = (raw >= 0 && raw <= 6) ? raw : -1;
    } else if (raw is String) {
      day = _dayMap[raw.toLowerCase()] ?? -1;
    } else {
      day = -1;
    }

    return AvailabilityModel(
      id:        (j['id'] as num?)?.toInt() ?? 0,
      dayOfWeek: day,
      startTime: j['startTime'] as String? ?? '09:00:00',
      endTime:   j['endTime']   as String? ?? '17:00:00',
      isActive:  j['isActive']  as bool?   ?? true,
    );
  }
}

TimeOfDay _parseTime(String t) {
  final parts = t.split(':');
  if (parts.length >= 2) {
    return TimeOfDay(
      hour:   int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
  return const TimeOfDay(hour: 9, minute: 0);
}

/// Converts [TimeOfDay] to `"HH:mm:00"` for the API.
String timeOfDayToApi(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

/// Formats a time string for display: `"09:00:00"` → `"09:00"`.
String formatTimeDisplay(String t) {
  final parts = t.split(':');
  if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
  return t;
}
