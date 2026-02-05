class TeacherModel {
  final String id;
  final String name;
  final String subject;

  TeacherModel({
    required this.id,
    required this.name,
    required this.subject,
  });

  @override
  String toString() => 'TeacherModel(id: $id, name: $name, subject: $subject)';
}
