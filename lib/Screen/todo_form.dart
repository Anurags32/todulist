import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todolist/database/database_helper.dart';
import 'package:todolist/models/todo_model.dart';

class TodoForm extends StatefulWidget {
  final Todo? todo;
  final void Function(Todo newTodo)? onTodoSaved;

  const TodoForm({Key? key, this.todo, this.onTodoSaved}) : super(key: key);

  @override
  _TodoFormState createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeMinutesController;
  late TextEditingController _timeSecondsController;
  late DatabaseHelper _databaseHelper;
  late StreamSubscription<List<Todo>> _todoSubscription;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _timeMinutesController =
        TextEditingController(text: (widget.todo?.timer ?? 0 ~/ 60).toString());
    _timeSecondsController =
        TextEditingController(text: (widget.todo?.timer ?? 0 % 60).toString());
    _databaseHelper = DatabaseHelper();

    _todoSubscription = _databaseHelper.todoStream.listen((todos) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _timeMinutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Time (minutes)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: TextField(
                      controller: _timeSecondsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Time (seconds)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 50),
                  ElevatedButton(
                    onPressed: _saveTodo,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTodo() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final minutes = int.tryParse(_timeMinutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(_timeSecondsController.text.trim()) ?? 0;

    if (title.isEmpty || description.isEmpty || minutes < 0 || seconds < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields with valid values.'),
        ),
      );
      return;
    }

    final totalSeconds = minutes * 60 + seconds;

    String status = 'TODO';

    if (totalSeconds > 300) {
      status = 'Done';
    } else if (totalSeconds > 0) {
      status = 'In-Progress';
    }

    final newId = DateTime.now().millisecond;

    final updatedTodo = Todo(
      id: widget.todo?.id ?? newId,
      title: title,
      description: description,
      status: status,
      timer: totalSeconds,
    );

    if (widget.todo == null) {
      await _databaseHelper.insertTodo(updatedTodo);
      if (widget.onTodoSaved != null) {
        widget.onTodoSaved!(updatedTodo);
      }
    } else {
      await _databaseHelper.updateTodo(updatedTodo);
      if (widget.onTodoSaved != null) {
        widget.onTodoSaved!(updatedTodo);
      }
    }

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeMinutesController.dispose();
    _timeSecondsController.dispose();
    _todoSubscription.cancel();
    super.dispose();
  }
}
