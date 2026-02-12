// Task types enum
enum TaskType {
  classroom,
  homework,
  assignmentProject,
}

// Extension to convert enum to/from string
extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.classroom:
        return 'Classroom';
      case TaskType.homework:
        return 'Homework';
      case TaskType.assignmentProject:
        return 'Assignment/Project';
    }
  }

  String get value {
    switch (this) {
      case TaskType.classroom:
        return 'classroom';
      case TaskType.homework:
        return 'homework';
      case TaskType.assignmentProject:
        return 'assignment_project';
    }
  }

  static TaskType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'classroom':
        return TaskType.classroom;
      case 'homework':
        return TaskType.homework;
      case 'assignment_project':
      case 'assignmentproject':
        return TaskType.assignmentProject;
      default:
        return TaskType.classroom;
    }
  }
}

class TeacherTaskModel {
  final String id;
  final String title;
  final String description;
  final String subjectId; // Reference to subject
  final String classroomId; // Reference to classroom
  final String teacherId;
  final TaskType type; // Classroom, Homework, or Assignment/Project
  final DateTime dueDate;
  final DateTime createdAt;
  final int totalStudents; // Total number of students who should complete this
  final int submittedCount; // Number of students who have submitted/completed
  final bool isActive; // Whether the task is still active

  TeacherTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.classroomId,
    required this.teacherId,
    required this.type,
    required this.dueDate,
    required this.createdAt,
    this.totalStudents = 0,
    this.submittedCount = 0,
    this.isActive = true,
  });

  // Calculate pending count
  int get pendingCount => totalStudents - submittedCount;

  // Calculate completion percentage
  double get completionPercentage {
    if (totalStudents == 0) return 0.0;
    return (submittedCount / totalStudents) * 100;
  }

  // Convert TeacherTaskModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'classroomId': classroomId,
      'teacherId': teacherId,
      'type': type.value,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'totalStudents': totalStudents,
      'submittedCount': submittedCount,
      'isActive': isActive,
    };
  }

  // Create TeacherTaskModel from JSON
  factory TeacherTaskModel.fromJson(Map<String, dynamic> json, String docId) {
    return TeacherTaskModel(
      id: (json['id'] ?? docId).toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subjectId: json['subjectId'] ?? '',
      classroomId: json['classroomId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      type: TaskTypeExtension.fromString(json['type'] ?? 'classroom'),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : DateTime.now(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      totalStudents: _parseInt(json['totalStudents']),
      submittedCount: _parseInt(json['submittedCount']),
      isActive: json['isActive'] ?? true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Create a copy with modifications
  TeacherTaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    String? classroomId,
    String? teacherId,
    TaskType? type,
    DateTime? dueDate,
    DateTime? createdAt,
    int? totalStudents,
    int? submittedCount,
    bool? isActive,
  }) {
    return TeacherTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      classroomId: classroomId ?? this.classroomId,
      teacherId: teacherId ?? this.teacherId,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      totalStudents: totalStudents ?? this.totalStudents,
      submittedCount: submittedCount ?? this.submittedCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'TeacherTaskModel(id: $id, title: $title, type: ${type.displayName}, subjectId: $subjectId, classroomId: $classroomId, dueDate: $dueDate)';
  }
}
