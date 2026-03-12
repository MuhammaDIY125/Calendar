import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:calendar/features/event/domain/entities/event_color.dart';

/// Доменная сущность события календаря.
class Event extends Equatable {
  final int? id;
  final String name;
  final String description;
  final String location;

  /// Дата события (только дата, без времени)
  final DateTime date;

  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final EventColor color;

  /// Количество минут до события для напоминания. null = без напоминания
  final int? reminderMinutes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.reminderMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  Event copyWith({
    int? id,
    String? name,
    String? description,
    String? location,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    EventColor? color,
    int? reminderMinutes,
    bool clearReminder = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      reminderMinutes:
          clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        location,
        date,
        startTime,
        endTime,
        color,
        reminderMinutes,
        createdAt,
        updatedAt,
      ];
}
