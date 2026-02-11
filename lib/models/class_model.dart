class ClassModel {
  final String id;
  final String name;
  final String section;
  final String teacherId;
  final String subject;
  final int studentCount;
  final String semester;
  final String academicYear;

  ClassModel({
    required this.id,
    required this.name,
    required this.section,
    required this.teacherId,
    required this.subject,
    required this.studentCount,
    required this.semester,
    required this.academicYear,
  });

  // Convert ClassModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'section': section,
      'teacherId': teacherId,
      'subject': subject,
      'studentCount': studentCount,
      'semester': semester,
      'academicYear': academicYear,
    };
  }

  // Create ClassModel from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json, String docId) {
    return ClassModel(
      id: (json['classId'] ?? docId).toString(),
      name: json['name'] ?? '',
      section: json['section'] ?? '',
      teacherId: json['teacherId'] ?? '',
      subject: json['subject'] ?? '',
      studentCount: _parseInt(json['studentCount']),
      semester: json['semester'] ?? '',
      academicYear: json['academicYear'] ?? '',
    );
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
  ClassModel copyWith({
    String? id,
    String? name,
    String? section,
    String? teacherId,
    String? subject,
    int? studentCount,
    String? semester,
    String? academicYear,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      teacherId: teacherId ?? this.teacherId,
      subject: subject ?? this.subject,
      studentCount: studentCount ?? this.studentCount,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
    );
  }

  @override
  String toString() =>
      'ClassModel(id: $id, name: $name, section: $section, teacherId: $teacherId, subject: $subject, studentCount: $studentCount, semester: $semester, academicYear: $academicYear)';
}
