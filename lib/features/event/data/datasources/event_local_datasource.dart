import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';

import 'package:calendar/core/error/exceptions.dart';
import 'package:calendar/features/event/data/models/event_model.dart';

/// Контракт локального источника данных событий
abstract class EventLocalDatasource {
  Future<EventModel> createEvent(EventModel model);
  Future<EventModel> updateEvent(EventModel model);
  Future<void> deleteEvent(int id);
  Future<List<EventModel>> getEventsForDate(String date);
  Future<List<EventModel>> getEventsForRange(String start, String end);
  Future<EventModel> getEventById(int id);
}

/// Реализация на базе SQLite (sqflite)
class EventLocalDatasourceImpl implements EventLocalDatasource {
  static const _dbName = 'calendar.db';
  static const _dbVersion = 1;
  static const _tableName = 'events';

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        location TEXT NOT NULL DEFAULT '',
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        color TEXT NOT NULL DEFAULT 'blue',
        reminder_minutes INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_events_date ON $_tableName(date)',
    );
  }

  @override
  Future<EventModel> createEvent(EventModel model) async {
    try {
      final db = await _database;
      final map = model.toMap()..remove('id');
      final id = await db.insert(_tableName, map);
      return EventModel.fromMap({...map, 'id': id});
    } catch (e) {
      throw DatabaseException('Failed to create event: $e');
    }
  }

  @override
  Future<EventModel> updateEvent(EventModel model) async {
    try {
      final db = await _database;
      final id = model.id;
      if (id == null) throw const DatabaseException('Event id is null');

      final map = model.toMap();
      final count = await db.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) throw NotFoundException('Event $id not found');
      return model;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update event: $e');
    }
  }

  @override
  Future<void> deleteEvent(int id) async {
    try {
      final db = await _database;
      final count = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) throw NotFoundException('Event $id not found');
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to delete event: $e');
    }
  }

  @override
  Future<List<EventModel>> getEventsForDate(String date) async {
    try {
      final db = await _database;
      final rows = await db.query(
        _tableName,
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'start_time ASC',
      );
      return rows.map(EventModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get events for date $date: $e');
    }
  }

  @override
  Future<List<EventModel>> getEventsForRange(String start, String end) async {
    try {
      final db = await _database;
      final rows = await db.query(
        _tableName,
        where: 'date >= ? AND date <= ?',
        whereArgs: [start, end],
        orderBy: 'date ASC, start_time ASC',
      );
      return rows.map(EventModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get events for range: $e');
    }
  }

  @override
  Future<EventModel> getEventById(int id) async {
    try {
      final db = await _database;
      final rows = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) throw NotFoundException('Event $id not found');
      return EventModel.fromMap(rows.first);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to get event $id: $e');
    }
  }
}
