import 'package:sqlite3/sqlite3.dart';

///Helper class for interacting with an [sqlite3] database
class DatabaseHelper {
  Database? _db;
  String table = 'auth_keys';

  ///Opens the database
  Future<void> open() async {
    if (_db == null) {
      _db = sqlite3.open('.adire_cli.db');
      _db!.execute('''
    CREATE TABLE IF NOT EXISTS $table (
      id TEXT PRIMARY KEY,
      value TEXT
    );
  ''');
    }
  }

  /// Execute a raw SQL query
  Future<void> execute(String sql) async {
    _db!.execute(sql);
  }

  /// Insert a record into the database
  Future<void> insert(Map<String, dynamic> values) async {
    await open();
    final columns = values.keys.join(', ');
    final placeholders = values.keys.map((_) => '?').join(', ');

    final sql = 'INSERT INTO $table ($columns) VALUES ($placeholders)';

    _db!.execute(sql, values.values.toList());
  }

  /// Update a record in the database
  Future<void> update(
    Map<String, dynamic> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    await open();
    final setClause = values.keys.map((column) => '$column = ?').join(', ');

    final sql = 'UPDATE $table SET $setClause WHERE $where';

    _db!.execute(sql, [...values.values, ...whereArgs]);
  }

  /// Insert or update a record in the database
  Future<void> insertUpdate(Map<String, dynamic> values) async {
    final where = 'id = ?';
    final whereArgs = [values['id']];
    final existing =
        await query(where: where, whereArgs: whereArgs, columns: ['id']);
    if (existing.isEmpty) {
      await insert(values);
    } else {
      await update(values, where: where, whereArgs: whereArgs);
    }
  }

  /// Delete a record from the database
  Future<void> delete(
      {required String where, required List<Object?> whereArgs}) async {
    await open();
    final sql = 'DELETE FROM $table WHERE $where';

    _db!.execute(sql, whereArgs);
  }

  /// Query the database and retrieve records
  Future<List<Map<String, Object?>>> query({
    required String where,
    required List<Object?> whereArgs,
    required List<String> columns,
  }) async {
    await open();
    final columnsStr = columns.isNotEmpty ? columns.join(', ') : '*';
    String sql;
    if (where.isNotEmpty) {
      sql = 'SELECT $columnsStr FROM $table WHERE $where';
    } else {
      sql = 'SELECT $columnsStr FROM $table';
    }
    return _db!.select(sql, whereArgs);
  }
}
