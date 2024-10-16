import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'todo_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskName TEXT,
            taskCompleted INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    final Database db = await database;
    await db.insert('todos', task, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final Database db = await database;
    return await db.query('todos');
  }

  Future<void> updateTask(Map<String, dynamic> task) async {
    final Database db = await database;
    await db.update('todos', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<void> deleteTask(int id) async {
    final Database db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
