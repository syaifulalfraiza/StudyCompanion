import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String classId;
  final String teacherId;
  final String subject;
  final DateTime dueDate;
  final DateTime createdDate;
  final int submittedCount;
  final int totalStudents;
  final bool isPublished;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.classId,
    required this.teacherId,
    required this.subject,
    required this.dueDate,
    required this.createdDate,
    required this.submittedCount,
    required this.totalStudents,
    required this.isPublished,
  });

  // Calculate submission percentage
  double get submissionPercentage =>
      totalStudents > 0 ? (submittedCount / totalStudents) * 100 : 0;

  // Check if assignment is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  // Check if assignment is due soon (within 3 days)
  bool get isDueSoon {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }

  // Convert AssignmentModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'classId': classId,
      'teacherId': teacherId,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'submittedCount': submittedCount,
      'totalStudents': totalStudents,
      'isPublished': isPublished,
    };
  }

  // Create AssignmentModel from JSON
  factory AssignmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return AssignmentModel(
      id: docId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      classId: json['classId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      subject: json['subject'] ?? '',
      dueDate: _parseDate(json['dueDate']),
      createdDate: _parseDate(json['createdDate']),
      submittedCount: _parseInt(json['submittedCount']),
      totalStudents: _parseInt(json['totalStudents']),
      isPublished: json['isPublished'] ?? false,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is Map) {
      final seconds = value['seconds'] ?? value['_seconds'];
      final nanoseconds = value['nanoseconds'] ?? value['_nanoseconds'];
      if (seconds is int && nanoseconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
          isUtc: true,
        ).toLocal();
      }
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
      final match = RegExp(r'Timestamp\(seconds=(\d+),\s*nanoseconds=(\d+)\)')
          .firstMatch(value);
      if (match != null) {
        final seconds = int.tryParse(match.group(1) ?? '');
        final nanoseconds = int.tryParse(match.group(2) ?? '');
        if (seconds != null && nanoseconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000),
            isUtc: true,
          ).toLocal();
        }
      }
    }
    return DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  // Copy with method for immutability
  AssignmentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? classId,
    String? teacherId,
    String? subject,
    DateTime? dueDate,
    DateTime? createdDate,
    int? submittedCount,
    int? totalStudents,
    bool? isPublished,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      submittedCount: submittedCount ?? this.submittedCount,
      totalStudents: totalStudents ?? this.totalStudents,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  @override
  String toString() =>
      'AssignmentModel(id: $id, title: $title, classId: $classId, teacherId: $teacherId, subject: $subject, dueDate: $dueDate, submittedCount: $submittedCount, totalStudents: $totalStudents, isPublished: $isPublished)';
}
