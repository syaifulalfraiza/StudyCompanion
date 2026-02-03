import 'package:studycompanion_app/models/child_model.dart';

class ParentService {
  static Future<List<ChildModel>> getChildren() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate API delay

    return [
      ChildModel(
        id: "1",
        name: "Alex Johnson",
        grade: "Grade 5",
        gpa: 3.8,
        homework: "Math Fractions Worksheet",
        quiz: "Science Chapter 5 • Tomorrow",
        reminder: "Bring calculator",
      ),
      ChildModel(
        id: "2",
        name: "Emma Johnson",
        grade: "Grade 3",
        gpa: 4.0,
        homework: "English Essay",
        quiz: "Spelling Test • Friday",
        reminder: "Bring storybook",
      ),
    ];
  }
}
