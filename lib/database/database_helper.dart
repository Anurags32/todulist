import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todolist/models/todo_model.dart';

class DatabaseHelper {
  static Database? _database;
  final StreamController<List<Todo>> _todoController =
      StreamController<List<Todo>>.broadcast();

  Stream<List<Todo>> get todoStream => _todoController.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, status TEXT, timer INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertTodo(Todo todo) async {
    final db = await database;
    await db.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    _updateTodoStream();
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        status: maps[i]['status'],
        timer: maps[i]['timer'],
      );
    });
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: "id = ?",
      whereArgs: [id],
    );
    _updateTodoStream();
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: "id = ?",
      whereArgs: [todo.id],
    );
    _updateTodoStream();
  }

  void _updateTodoStream() async {
    final todos = await getTodos();
    _todoController.sink.add(todos);
  }

  void dispose() {
    _todoController.close();
  }
}
