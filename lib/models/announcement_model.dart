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

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? 'Admin',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      isPublished: json['isPublished'] as bool? ?? true,
    );
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
