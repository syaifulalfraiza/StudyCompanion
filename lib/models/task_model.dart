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

  factory Task.fromJson(Map<String, dynamic> json, String id) {
    return Task(
      id: id,
      title: (json['title'] ?? '') as String,
      dueDate: (json['dueDate'] ?? '') as String,
      subject: (json['subject'] ?? '') as String,
      isCompleted: (json['isCompleted'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson({required String studentId}) {
    return {
      'studentId': studentId,
      'title': title,
      'subject': subject,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
    };
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, dueDate: $dueDate, subject: $subject, isCompleted: $isCompleted)';
}
