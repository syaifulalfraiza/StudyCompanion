class ClassroomModel {
  final String id;
  final String name;
  final String section;
  final String teacherId;
  final int studentCount;
  final String semester;
  final String academicYear;
  final List<String> studentIds; // List of student IDs in this classroom

  ClassroomModel({
    required this.id,
    required this.name,
    required this.section,
    required this.teacherId,
    required this.studentCount,
    required this.semester,
    required this.academicYear,
    this.studentIds = const [],
  });

  // Convert ClassroomModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'section': section,
      'teacherId': teacherId,
      'studentCount': studentCount,
      'semester': semester,
      'academicYear': academicYear,
      'studentIds': studentIds,
    };
  }

  // Create ClassroomModel from JSON
  factory ClassroomModel.fromJson(Map<String, dynamic> json, String docId) {
    return ClassroomModel(
      id: (json['id'] ?? docId).toString(),
      name: json['name'] ?? '',
      section: json['section'] ?? '',
      teacherId: json['teacherId'] ?? '',
      studentCount: _parseInt(json['studentCount']),
      semester: json['semester'] ?? '',
      academicYear: json['academicYear'] ?? '',
      studentIds: (json['studentIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Create a copy with modifications
  ClassroomModel copyWith({
    String? id,
    String? name,
    String? section,
    String? teacherId,
    int? studentCount,
    String? semester,
    String? academicYear,
    List<String>? studentIds,
  }) {
    return ClassroomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
      teacherId: teacherId ?? this.teacherId,
      studentCount: studentCount ?? this.studentCount,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      studentIds: studentIds ?? this.studentIds,
    );
  }

  @override
  String toString() {
    return 'ClassroomModel(id: $id, name: $name, section: $section, teacherId: $teacherId, studentCount: $studentCount, semester: $semester, academicYear: $academicYear)';
  }
}
