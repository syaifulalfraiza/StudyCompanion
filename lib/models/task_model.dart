class TaskModel {
  final String id;
  final String title;
  final String type; // 'classroom','homework','assignment'
  final List<String> submissions; // student ids who submitted
  final List<String> assignedStudents; // student ids assigned to this task

  TaskModel({required this.id, required this.title, required this.type, List<String>? submissions, List<String>? assignedStudents}) :
    submissions = submissions ?? [],
    assignedStudents = assignedStudents ?? [];

  TaskModel copyWith({String? id, String? title, String? type, List<String>? submissions, List<String>? assignedStudents}) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      submissions: submissions ?? this.submissions,
      assignedStudents: assignedStudents ?? this.assignedStudents,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'classroom',
      submissions: (json['submissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      assignedStudents: (json['assignedStudents'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'submissions': submissions,
      'assignedStudents': assignedStudents,
    };
  }
}
