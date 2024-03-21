import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todolist/Screen/todo_form.dart';
import 'package:todolist/database/database_helper.dart';
import 'package:todolist/enum/enum.dart';
import 'package:todolist/models/todo_model.dart';

class TodoDetailsPage extends StatefulWidget {
  final Todo todo;

  const TodoDetailsPage({Key? key, required this.todo}) : super(key: key);

  @override
  _TodoDetailsPageState createState() => _TodoDetailsPageState();
}

class _TodoDetailsPageState extends State<TodoDetailsPage> {
  late Timer _timer;
  bool _isRunning = false;
  late DatabaseHelper _databaseHelper;
  late List<Todo> _todos;

  @override
  void initState() {
    super.initState();
    if (widget.todo.status == TodoStatus.running) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        widget.todo.incrementTimer();
      });
    });
  }

  void _pauseTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    _startTimer();
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      widget.todo.timer = 0;
      _isRunning = false;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _resumeTimer();
    }
  }

  Future<void> _refreshTodoList() async {
    try {
      final List<Todo> todoList = await _databaseHelper.getTodos();
      setState(() {
        _todos.addAll(todoList);
      });
    } catch (e) {
      print('Error: $e');
      setState(() {});
    }
  }

  void _navigateToEditTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoForm(todo: widget.todo),
      ),
    ).then((value) {
      if (value != null && value) {
        _refreshTodoList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${widget.todo.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${widget.todo.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${widget.todo.status}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Timer: ${widget.todo.timer} seconds',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: _isRunning ? const Text('Pause') : const Text('Play'),
                ),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _navigateToEditTodo();
              },
              child: const Text('Edit Todo'),
            ),
          ],
        ),
      ),
    );
  }
}
