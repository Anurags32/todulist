class Todo {
  final int id;
  final String title;
  final String description;
  String status;
  int timer;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.timer,
  });

  void incrementTimer() {
    timer++;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'timer': timer,
    };
  }
}
