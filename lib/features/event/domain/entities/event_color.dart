import 'package:flutter/material.dart';

/// Цвет приоритета события.
///
/// Каждый цвет имеет акцентный оттенок (для полосы, точки, заголовка)
/// и фоновый (для тела карточки).
enum EventColor {
  blue,
  red,
  orange,
  green;

  /// Акцентный цвет — используется для левой полосы, точки, текста заголовка
  Color get accentColor => switch (this) {
        EventColor.blue => const Color(0xFF42A5F5),
        EventColor.red => const Color(0xFFEF5350),
        EventColor.orange => const Color(0xFFFFA726),
        EventColor.green => const Color(0xFF66BB6A),
      };

  /// Фоновый цвет карточки — акцент с прозрачностью
  Color get backgroundColor => accentColor.withValues(alpha: 0.15);

  /// Название цвета для отображения в UI
  String get displayName => switch (this) {
        EventColor.blue => 'Blue',
        EventColor.red => 'Red',
        EventColor.orange => 'Orange',
        EventColor.green => 'Green',
      };

  /// Сериализация в строку для SQLite
  String get value => name;

  /// Десериализация из строки SQLite
  static EventColor fromValue(String value) => switch (value) {
        'red' => EventColor.red,
        'orange' => EventColor.orange,
        'green' => EventColor.green,
        _ => EventColor.blue,
      };
}
