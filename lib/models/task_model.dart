class Task {
  final String id;
  final String title;
  final String dueDate;
  final String subject;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.subject,
    this.isCompleted = false,
  });

  // Create a copy with modifications
  Task copyWith({
    String? id,
    String? title,
    String? dueDate,
    String? subject,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      subject: subject ?? this.subject,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, dueDate: $dueDate, subject: $subject, isCompleted: $isCompleted)';
}
