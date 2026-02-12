class SubjectModel {
  final String id;
  final String name;
  final String classroomId; // Reference to parent classroom
  final String teacherId;
  final String code; // Subject code (e.g., "MATH101")
  final String description;

  SubjectModel({
    required this.id,
    required this.name,
    required this.classroomId,
    required this.teacherId,
    required this.code,
    this.description = '',
  });

  // Convert SubjectModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'classroomId': classroomId,
      'teacherId': teacherId,
      'code': code,
      'description': description,
    };
  }

  // Create SubjectModel from JSON
  factory SubjectModel.fromJson(Map<String, dynamic> json, String docId) {
    return SubjectModel(
      id: (json['id'] ?? docId).toString(),
      name: json['name'] ?? '',
      classroomId: json['classroomId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
    );
  }

  // Create a copy with modifications
  SubjectModel copyWith({
    String? id,
    String? name,
    String? classroomId,
    String? teacherId,
    String? code,
    String? description,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      classroomId: classroomId ?? this.classroomId,
      teacherId: teacherId ?? this.teacherId,
      code: code ?? this.code,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'SubjectModel(id: $id, name: $name, code: $code, classroomId: $classroomId, teacherId: $teacherId)';
  }
}
