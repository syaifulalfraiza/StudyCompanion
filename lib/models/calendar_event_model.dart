import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { exam, deadline, event, holiday, meeting, other }

class CalendarEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;
  final String? userId; // Teacher or Student ID
  final String? classroomId; // Optional: link to specific classroom
  final String? subjectId; // Optional: link to specific subject
  final String visibilityScope; // private | role | global | classroom
  final List<String> allowedRoles;
  final List<String> audienceUserIds;
  final String? createdByUserId;
  final String? createdByRole;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.userId,
    this.classroomId,
    this.subjectId,
    this.visibilityScope = 'private',
    this.allowedRoles = const [],
    this.audienceUserIds = const [],
    this.createdByUserId,
    this.createdByRole,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type.toString().split('.').last,
      'userId': userId,
      'classroomId': classroomId,
      'subjectId': subjectId,
      'visibilityScope': visibilityScope,
      'allowedRoles': allowedRoles,
      'audienceUserIds': audienceUserIds,
      'createdByUserId': createdByUserId,
      'createdByRole': createdByRole,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory CalendarEventModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return CalendarEventModel(
      id: map['id'] ?? documentId ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => EventType.other,
      ),
      userId: map['userId'],
      classroomId: map['classroomId'],
      subjectId: map['subjectId'],
      visibilityScope: map['visibilityScope'] ?? 'private',
      allowedRoles: (map['allowedRoles'] as List?)?.cast<String>() ?? [],
      audienceUserIds: (map['audienceUserIds'] as List?)?.cast<String>() ?? [],
      createdByUserId: map['createdByUserId'],
      createdByRole: map['createdByRole'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create copy with updated fields
  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    EventType? type,
    String? userId,
    String? classroomId,
    String? subjectId,
    String? visibilityScope,
    List<String>? allowedRoles,
    List<String>? audienceUserIds,
    String? createdByUserId,
    String? createdByRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      classroomId: classroomId ?? this.classroomId,
      subjectId: subjectId ?? this.subjectId,
      visibilityScope: visibilityScope ?? this.visibilityScope,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      audienceUserIds: audienceUserIds ?? this.audienceUserIds,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByRole: createdByRole ?? this.createdByRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
