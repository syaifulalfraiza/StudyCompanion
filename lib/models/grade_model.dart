class GradeModel {
  final String id;
  final String studentId;
  final String assignmentId;
  final String classId;
  final String teacherId;
  final double score;
  final double maxScore;
  final String grade;
  final String? feedback;
  final DateTime recordedDate;
  final String? rubricNotes;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.assignmentId,
    required this.classId,
    required this.teacherId,
    required this.score,
    required this.maxScore,
    required this.grade,
    this.feedback,
    required this.recordedDate,
    this.rubricNotes,
  });

  // Calculate percentage
  double get percentage => (score / maxScore) * 100;

  // Calculate GPA equivalent (0-4.0 scale)
  double get gpaEquivalent {
    final percentage = this.percentage;
    if (percentage >= 90) return 4.0;
    if (percentage >= 85) return 3.75;
    if (percentage >= 80) return 3.5;
    if (percentage >= 75) return 3.25;
    if (percentage >= 70) return 3.0;
    if (percentage >= 65) return 2.75;
    if (percentage >= 60) return 2.5;
    if (percentage >= 55) return 2.25;
    if (percentage >= 50) return 2.0;
    return 1.0;
  }

  // Convert GradeModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'assignmentId': assignmentId,
      'classId': classId,
      'teacherId': teacherId,
      'score': score,
      'maxScore': maxScore,
      'grade': grade,
      'feedback': feedback,
      'recordedDate': recordedDate.toIso8601String(),
      'rubricNotes': rubricNotes,
    };
  }

  // Create GradeModel from JSON
  factory GradeModel.fromJson(Map<String, dynamic> json, String docId) {
    return GradeModel(
      id: docId,
      studentId: json['studentId'] ?? '',
      assignmentId: json['assignmentId'] ?? '',
      classId: json['classId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      maxScore: (json['maxScore'] ?? 100).toDouble(),
      grade: json['grade'] ?? 'N/A',
      feedback: json['feedback'],
      recordedDate: json['recordedDate'] != null
          ? DateTime.parse(json['recordedDate'].toString())
          : DateTime.now(),
      rubricNotes: json['rubricNotes'],
    );
  }

  // Copy with method for immutability
  GradeModel copyWith({
    String? id,
    String? studentId,
    String? assignmentId,
    String? classId,
    String? teacherId,
    double? score,
    double? maxScore,
    String? grade,
    String? feedback,
    DateTime? recordedDate,
    String? rubricNotes,
  }) {
    return GradeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      assignmentId: assignmentId ?? this.assignmentId,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
      recordedDate: recordedDate ?? this.recordedDate,
      rubricNotes: rubricNotes ?? this.rubricNotes,
    );
  }

  @override
  String toString() =>
      'GradeModel(id: $id, studentId: $studentId, assignmentId: $assignmentId, classId: $classId, score: $score/$maxScore, grade: $grade, recordedDate: $recordedDate)';
}
