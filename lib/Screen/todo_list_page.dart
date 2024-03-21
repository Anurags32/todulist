import 'package:flutter/material.dart';
import 'package:todolist/Screen/todo_details_page.dart';
import 'package:todolist/Screen/todo_form.dart';
import 'package:todolist/database/database_helper.dart';
import 'package:todolist/models/todo_model.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late DatabaseHelper _databaseHelper;
  late List<Todo> _todos;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _todos = [];
    _refreshTodoList();
  }

  Future<void> _refreshTodoList() async {
    try {
      final List<Todo> todoList = await _databaseHelper.getTodos();
      setState(() {
        _todos = todoList.toList();
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _handleTodoSaved(Todo newTodo) {
    setState(() {
      _todos.insert(0, newTodo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _todos.isEmpty
              ? const Center(
                  child: Text('No Todos'),
                )
              : ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              title: Text("Todo Name: ${todo.title}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Description: ${todo.description}"),
                                  const SizedBox(height: 4),
                                  Text('Status: ${todo.status}'),
                                  const SizedBox(height: 4),
                                  Text('Timer: ${todo.timer}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _navigateToEditTodo(todo);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteTodoAndRefresh(todo.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _navigateToDetailsPage(todo);
                              },
                              child: const Text("Details Page"),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteTodoAndRefresh(int id) async {
    await _databaseHelper.deleteTodo(id);
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _showAddTodoForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return TodoForm(
          onTodoSaved: _handleTodoSaved,
        );
      },
    ).then((value) {
      if (value != null && value is bool && value) {
        _refreshTodoList();
      }
    });
  }

  void _navigateToEditTodo(Todo todo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoForm(todo: todo),
      ),
    );

    if (result != null && result is bool && result) {
      _refreshTodoList();
    }
  }

  void _navigateToDetailsPage(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoDetailsPage(todo: todo),
      ),
    );
  }
}
