import 'package:studycompanion_app/models/teacher_model.dart';

class TeacherService {
  static Future<List<TeacherModel>> getTeachersForChildSubjects(
    List<String> subjects,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allTeachers = [
      TeacherModel(id: "t1", name: "Cikgu Ahmad", subject: "Math"),
      TeacherModel(id: "t2", name: "Cikgu Suhana", subject: "English"),
      TeacherModel(id: "t3", name: "Cikgu Ravi", subject: "Science"),
      TeacherModel(id: "t4", name: "Cikgu Mei Ling", subject: "History"),
      TeacherModel(id: "t5", name: "Cikgu Farah", subject: "Bahasa Melayu"),
      TeacherModel(id: "t6", name: "Cikgu Zainul", subject: "Islamic Studies"),
    ];

    return allTeachers
        .where((teacher) => subjects.contains(teacher.subject))
        .toList();
  }
}
