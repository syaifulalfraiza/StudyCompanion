import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String createdBy;
  final DateTime date;
  final bool isPublished;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdBy,
    required this.date,
    this.isPublished = true,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return AnnouncementModel(
      id: (json['id'] ?? docId ?? '').toString(),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? 'Admin',
      date: _parseDate(json['date']),
      isPublished: json['isPublished'] as bool? ?? true,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdBy': createdBy,
      'date': date.toIso8601String(),
      'isPublished': isPublished,
    };
  }

  /// Getter for content (alias for message)
  String get content => message;

  /// Getter for formatted date
  String get formattedDate {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.year == now.year) {
      return '${date.month}/${date.day}';
    }
    return '${date.year}-${date.month}-${date.day}';
  }
}
