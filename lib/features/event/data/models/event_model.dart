import 'package:flutter/material.dart';

import 'package:calendar/features/event/domain/entities/event.dart';
import 'package:calendar/features/event/domain/entities/event_color.dart';

/// Модель данных события для сериализации/десериализации SQLite.
class EventModel extends Event {
  const EventModel({
    super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.color,
    super.reminderMinutes,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Создать модель из строки SQLite
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      startTime: _parseTime(map['start_time'] as String),
      endTime: _parseTime(map['end_time'] as String),
      color: EventColor.fromValue(map['color'] as String? ?? 'blue'),
      reminderMinutes: map['reminder_minutes'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Создать модель из доменной сущности
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      name: event.name,
      description: event.description,
      location: event.location,
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
      color: event.color,
      reminderMinutes: event.reminderMinutes,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );
  }

  /// Сериализовать в Map для записи в SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'location': location,
      'date': _formatDate(date),
      'start_time': _formatTime(startTime),
      'end_time': _formatTime(endTime),
      'color': color.value,
      'reminder_minutes': reminderMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Парсинг строки 'HH:mm' в TimeOfDay
  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Форматирование TimeOfDay в строку 'HH:mm'
  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  /// Форматирование даты в 'YYYY-MM-DD'
  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
