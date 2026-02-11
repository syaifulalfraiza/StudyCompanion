import 'package:studycompanion_app/models/task_model.dart';

class SampleTaskData {
  static final Map<String, List<Task>> _tasksByStudent = {
    's1': [
      Task(id: 's1-t1', title: 'Algebra Practice', dueDate: 'Due Today', subject: 'Mathematics'),
      Task(id: 's1-t2', title: 'Reading Chapter 4', dueDate: 'Due Tomorrow', subject: 'English'),
      Task(id: 's1-t3', title: 'Lab Notes Draft', dueDate: 'Due Friday', subject: 'Science'),
    ],
    's2': [
      Task(id: 's2-t1', title: 'Cell Diagram', dueDate: 'Due Today', subject: 'Biology'),
      Task(id: 's2-t2', title: 'Source Analysis', dueDate: 'Due Thursday', subject: 'History'),
      Task(id: 's2-t3', title: 'Problem Set 7', dueDate: 'Next Week', subject: 'Mathematics'),
    ],
    's3': [
      Task(id: 's3-t1', title: 'Forces Worksheet', dueDate: 'Due Tomorrow', subject: 'Physics'),
      Task(id: 's3-t2', title: 'Map Sketch', dueDate: 'Due Friday', subject: 'Geography'),
      Task(id: 's3-t3', title: 'Essay Outline', dueDate: 'Next Week', subject: 'Moral'),
    ],
    's4': [
      Task(id: 's4-t1', title: 'Genetics Notes', dueDate: 'Due Today', subject: 'Biology'),
      Task(id: 's4-t2', title: 'Geometry Quiz Prep', dueDate: 'Due Thursday', subject: 'Mathematics'),
      Task(id: 's4-t3', title: 'Art Reflection', dueDate: 'Next Week', subject: 'Art'),
    ],
    's5': [
      Task(id: 's5-t1', title: 'Kinematics Problems', dueDate: 'Due Today', subject: 'Physics'),
      Task(id: 's5-t2', title: 'Literature Notes', dueDate: 'Due Friday', subject: 'English'),
      Task(id: 's5-t3', title: 'Math Olympiad Form', dueDate: 'Next Week', subject: 'Mathematics'),
    ],
    's6': [
      Task(id: 's6-t1', title: 'Sorting Algorithms', dueDate: 'Due Tomorrow', subject: 'Computer Science'),
      Task(id: 's6-t2', title: 'Balance Sheet', dueDate: 'Due Friday', subject: 'Accounting'),
      Task(id: 's6-t3', title: 'Supply & Demand', dueDate: 'Next Week', subject: 'Economics'),
    ],
    's7': [
      Task(id: 's7-t1', title: 'Integration Practice', dueDate: 'Due Today', subject: 'Add Maths'),
      Task(id: 's7-t2', title: 'Organic Reactions', dueDate: 'Due Thursday', subject: 'Chemistry'),
      Task(id: 's7-t3', title: 'Biology Revision', dueDate: 'Next Week', subject: 'Biology'),
    ],
    's8': [
      Task(id: 's8-t1', title: 'Composition Draft', dueDate: 'Due Today', subject: 'Chinese'),
      Task(id: 's8-t2', title: 'Aqidah Notes', dueDate: 'Due Friday', subject: 'Islamic Education'),
      Task(id: 's8-t3', title: 'Debate Prep', dueDate: 'Next Week', subject: 'Co-Curriculum'),
    ],
    's9': [
      Task(id: 's9-t1', title: 'Independence Essay', dueDate: 'Due Today', subject: 'History'),
      Task(id: 's9-t2', title: 'Fitness Log', dueDate: 'Due Thursday', subject: 'Physical Education'),
      Task(id: 's9-t3', title: 'Trial Registration', dueDate: 'Next Week', subject: 'Sports'),
    ],
    's10': [
      Task(id: 's10-t1', title: 'CAD Draft', dueDate: 'Due Tomorrow', subject: 'Technical Drawing'),
      Task(id: 's10-t2', title: 'Entrepreneurship Quiz', dueDate: 'Due Friday', subject: 'Business'),
      Task(id: 's10-t3', title: 'Career Talk Notes', dueDate: 'Next Week', subject: 'Guidance'),
    ],
    's11': [
      Task(id: 's11-t1', title: 'Culinary Presentation', dueDate: 'Due Today', subject: 'Life Skills'),
      Task(id: 's11-t2', title: 'Grammar Practice', dueDate: 'Due Thursday', subject: 'English'),
      Task(id: 's11-t3', title: 'Form Captain Briefing', dueDate: 'Next Week', subject: 'Leadership'),
    ],
    's12': [
      Task(id: 's12-t1', title: 'Art Portfolio', dueDate: 'Due Today', subject: 'Visual Arts'),
      Task(id: 's12-t2', title: 'Statistics Practice', dueDate: 'Due Friday', subject: 'Mathematics'),
      Task(id: 's12-t3', title: 'Field Trip Report', dueDate: 'Next Week', subject: 'Astronomy Club'),
    ],
  };

  static List<Task> getTasksForStudent(String studentId) {
    return List<Task>.from(_tasksByStudent[studentId] ?? const []);
  }
}
