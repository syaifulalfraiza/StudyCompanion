import 'package:studycompanion_app/models/class_model.dart';
import 'package:studycompanion_app/models/assignment_model.dart';
import 'package:studycompanion_app/models/grade_model.dart';
import 'package:studycompanion_app/models/announcement_model.dart';

class SampleTeacherData {
  // Sample Teachers Data (6 teachers from TeacherService)
  static final Map<String, Map<String, dynamic>> _teacherDetails = {
    't1': {
      'name': 'Cikgu Ahmad',
      'subject': 'Mathematics',
      'email': 'ahmad@school.edu.my',
      'phone': '012-3456789',
      'qualification': 'Degree in Mathematics',
      'yearsExperience': 8,
    },
    't2': {
      'name': 'Cikgu Suhana',
      'subject': 'English',
      'email': 'suhana@school.edu.my',
      'phone': '012-3456790',
      'qualification': 'Degree in English Literature',
      'yearsExperience': 6,
    },
    't3': {
      'name': 'Cikgu Ravi',
      'subject': 'Science',
      'email': 'ravi@school.edu.my',
      'phone': '012-3456791',
      'qualification': 'Degree in Biology',
      'yearsExperience': 10,
    },
    't4': {
      'name': 'Cikgu Mei Ling',
      'subject': 'History',
      'email': 'meiling@school.edu.my',
      'phone': '012-3456792',
      'qualification': 'Degree in History',
      'yearsExperience': 7,
    },
    't5': {
      'name': 'Cikgu Farah',
      'subject': 'Bahasa Melayu',
      'email': 'farah@school.edu.my',
      'phone': '012-3456793',
      'qualification': 'Degree in Bahasa Melayu',
      'yearsExperience': 5,
    },
    't6': {
      'name': 'Cikgu Zainul',
      'subject': 'Islamic Studies',
      'email': 'zainul@school.edu.my',
      'phone': '012-3456794',
      'qualification': 'Degree in Islamic Studies',
      'yearsExperience': 9,
    },
  };

  // Sample Classes Data - Organized by teacher
  static final Map<String, List<ClassModel>> _classesByTeacher = {
    't1': [
      ClassModel(
        id: 'c1',
        name: 'Form 4 Mathematics A',
        section: '4A',
        teacherId: 't1',
        subject: 'Mathematics',
        studentCount: 35,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
      ClassModel(
        id: 'c2',
        name: 'Form 4 Mathematics B',
        section: '4B',
        teacherId: 't1',
        subject: 'Mathematics',
        studentCount: 33,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
    ],
    't2': [
      ClassModel(
        id: 'c3',
        name: 'Form 4 English A',
        section: '4A',
        teacherId: 't2',
        subject: 'English',
        studentCount: 35,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
      ClassModel(
        id: 'c4',
        name: 'Form 4 English C',
        section: '4C',
        teacherId: 't2',
        subject: 'English',
        studentCount: 34,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
    ],
    't3': [
      ClassModel(
        id: 'c5',
        name: 'Form 4 Science A',
        section: '4A',
        teacherId: 't3',
        subject: 'Science',
        studentCount: 35,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
    ],
    't4': [
      ClassModel(
        id: 'c6',
        name: 'Form 4 History A',
        section: '4A',
        teacherId: 't4',
        subject: 'History',
        studentCount: 35,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
    ],
    't5': [
      ClassModel(
        id: 'c7',
        name: 'Form 4 Bahasa Melayu A',
        section: '4A',
        teacherId: 't5',
        subject: 'Bahasa Melayu',
        studentCount: 35,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
    ],
    't6': [
      ClassModel(
        id: 'c8',
        name: 'Form 4 Islamic Studies A',
        section: '4A',
        teacherId: 't6',
        subject: 'Islamic Studies',
        studentCount: 35,
        semester: 'First Semester 2026',
        academicYear: '2026',
      ),
    ],
  };

  // Sample Assignments Data
  static final List<AssignmentModel> _sampleAssignments = [
    // Mathematics Assignments (t1 - Cikgu Ahmad)
    AssignmentModel(
      id: 'a1',
      title: 'Chapter 4 Review - Algebra',
      description: 'Complete all practice problems from Chapter 4. Focus on quadratic equations.',
      classId: 'c1',
      teacherId: 't1',
      subject: 'Mathematics',
      dueDate: DateTime(2026, 2, 14),
      createdDate: DateTime(2026, 2, 8),
      submittedCount: 28,
      totalStudents: 35,
      isPublished: true,
    ),
    AssignmentModel(
      id: 'a2',
      title: 'Civil War Essay',
      description: 'Write a 1000-word essay analyzing causes and consequences of the war.',
      classId: 'c1',
      teacherId: 't1',
      subject: 'Mathematics',
      dueDate: DateTime(2026, 2, 20),
      createdDate: DateTime(2026, 2, 10),
      submittedCount: 11,
      totalStudents: 35,
      isPublished: true,
    ),
    AssignmentModel(
      id: 'a3',
      title: 'Problem Set 7 - Geometry',
      description: 'Solve 25 geometry problems. Show all working.',
      classId: 'c2',
      teacherId: 't1',
      subject: 'Mathematics',
      dueDate: DateTime(2026, 2, 18),
      createdDate: DateTime(2026, 2, 9),
      submittedCount: 31,
      totalStudents: 33,
      isPublished: true,
    ),
    // English Assignments (t2 - Cikgu Suhana)
    AssignmentModel(
      id: 'a4',
      title: 'Reading Comprehension - Chapter 5',
      description: 'Read Chapter 5 and answer all comprehension questions.',
      classId: 'c3',
      teacherId: 't2',
      subject: 'English',
      dueDate: DateTime(2026, 2, 16),
      createdDate: DateTime(2026, 2, 8),
      submittedCount: 33,
      totalStudents: 35,
      isPublished: true,
    ),
    AssignmentModel(
      id: 'a5',
      title: 'Creative Writing - Short Story',
      description: 'Write a short story (500-800 words) with a twist ending.',
      classId: 'c3',
      teacherId: 't2',
      subject: 'English',
      dueDate: DateTime(2026, 2, 22),
      createdDate: DateTime(2026, 2, 10),
      submittedCount: 15,
      totalStudents: 35,
      isPublished: true,
    ),
    // Science Assignments (t3 - Cikgu Ravi)
    AssignmentModel(
      id: 'a6',
      title: 'Lab Report - Photosynthesis Experiment',
      description: 'Complete lab report with methodology, results, and analysis.',
      classId: 'c5',
      teacherId: 't3',
      subject: 'Science',
      dueDate: DateTime(2026, 2, 17),
      createdDate: DateTime(2026, 2, 7),
      submittedCount: 30,
      totalStudents: 35,
      isPublished: true,
    ),
    AssignmentModel(
      id: 'a7',
      title: 'Cell Biology Quiz',
      description: 'Online quiz covering cell structure and function. 20 questions.',
      classId: 'c5',
      teacherId: 't3',
      subject: 'Science',
      dueDate: DateTime(2026, 2, 19),
      createdDate: DateTime(2026, 2, 9),
      submittedCount: 32,
      totalStudents: 35,
      isPublished: true,
    ),
  ];

  // Sample Grades Data
  static final List<GradeModel> _sampleGrades = [
    // Grades for Assignment a1 (Math Chapter 4 Review)
    GradeModel(
      id: 'g1',
      studentId: 's1',
      assignmentId: 'a1',
      classId: 'c1',
      teacherId: 't1',
      score: 85,
      maxScore: 100,
      grade: 'A',
      feedback: 'Good work! Clear understanding of quadratic equations.',
      recordedDate: DateTime(2026, 2, 15),
    ),
    GradeModel(
      id: 'g2',
      studentId: 's2',
      assignmentId: 'a1',
      classId: 'c1',
      teacherId: 't1',
      score: 92,
      maxScore: 100,
      grade: 'A+',
      feedback: 'Excellent! Perfect solutions. Well organized.',
      recordedDate: DateTime(2026, 2, 15),
    ),
    GradeModel(
      id: 'g3',
      studentId: 's3',
      assignmentId: 'a1',
      classId: 'c1',
      teacherId: 't1',
      score: 78,
      maxScore: 100,
      grade: 'B+',
      feedback: 'Good effort. Review factorization methods.',
      recordedDate: DateTime(2026, 2, 15),
    ),
    // Grades for Assignment a4 (English Reading)
    GradeModel(
      id: 'g4',
      studentId: 's1',
      assignmentId: 'a4',
      classId: 'c3',
      teacherId: 't2',
      score: 88,
      maxScore: 100,
      grade: 'A',
      feedback: 'Excellent comprehension. Thoughtful responses.',
      recordedDate: DateTime(2026, 2, 17),
    ),
    GradeModel(
      id: 'g5',
      studentId: 's4',
      assignmentId: 'a4',
      classId: 'c3',
      teacherId: 't2',
      score: 76,
      maxScore: 100,
      grade: 'B',
      feedback: 'Decent understanding. Work on inference skills.',
      recordedDate: DateTime(2026, 2, 17),
    ),
  ];

  // Get teacher details
  static Map<String, dynamic>? getTeacherDetails(String teacherId) {
    return _teacherDetails[teacherId];
  }

  // Get all classes for a teacher
  static List<ClassModel> getClassesForTeacher(String teacherId) {
    return List<ClassModel>.from(_classesByTeacher[teacherId] ?? []);
  }

  // Get all assignments for a class
  static List<AssignmentModel> getAssignmentsForClass(String classId) {
    return _sampleAssignments
        .where((assignment) => assignment.classId == classId)
        .toList();
  }

  // Get all assignments for a teacher
  static List<AssignmentModel> getAssignmentsForTeacher(String teacherId) {
    return _sampleAssignments
        .where((assignment) => assignment.teacherId == teacherId)
        .toList();
  }

  // Get grades for a specific assignment
  static List<GradeModel> getGradesForAssignment(String assignmentId) {
    return _sampleGrades
        .where((grade) => grade.assignmentId == assignmentId)
        .toList();
  }

  // Get grades for a specific student in a class
  static List<GradeModel> getGradesForStudent(String studentId, String classId) {
    return _sampleGrades
        .where((grade) => grade.studentId == studentId && grade.classId == classId)
        .toList();
  }

  // Get all grades for a class
  static List<GradeModel> getGradesForClass(String classId) {
    return _sampleGrades.where((grade) => grade.classId == classId).toList();
  }

  // Get class details by ID
  static ClassModel? getClassById(String classId) {
    for (var classList in _classesByTeacher.values) {
      for (var classModel in classList) {
        if (classModel.id == classId) {
          return classModel;
        }
      }
    }
    return null;
  }

  // Get assignment details by ID
  static AssignmentModel? getAssignmentById(String assignmentId) {
    try {
      return _sampleAssignments
          .firstWhere((assignment) => assignment.id == assignmentId);
    } catch (e) {
      return null;
    }
  }

  // Get average grade for an assignment
  static double getAverageGradeForAssignment(String assignmentId) {
    final grades = getGradesForAssignment(assignmentId);
    if (grades.isEmpty) return 0;
    return grades.map((g) => g.percentage).reduce((a, b) => a + b) / grades.length;
  }

  // Get class average for a teacher
  static Map<String, double> getClassAveragesForTeacher(String teacherId) {
    final classes = getClassesForTeacher(teacherId);
    final averages = <String, double>{};

    for (var classModel in classes) {
      final classGrades = getGradesForClass(classModel.id);
      if (classGrades.isNotEmpty) {
        final avg = classGrades.map((g) => g.percentage).reduce((a, b) => a + b) /
            classGrades.length;
        averages[classModel.name] = avg;
      }
    }

    return averages;
  }

  // Get all teachers
  static List<Map<String, dynamic>> getAllTeachers() {
    return _teacherDetails.entries
        .map((e) => {
          'id': e.key,
          ...e.value,
        })
        .toList();
  }

  // Get all classes
  static List<ClassModel> getAllClasses() {
    return _classesByTeacher.values.expand((classes) => classes).toList();
  }

  // Get all assignments
  static List<AssignmentModel> getAllAssignments() {
    return List<AssignmentModel>.from(_sampleAssignments);
  }

  // Get all grades
  static List<GradeModel> getAllGrades() {
    return List<GradeModel>.from(_sampleGrades);
  }

  // Get announcements for a teacher
  static List<AnnouncementModel> getAnnouncementsForTeacher(String teacherId) {
    final teacherDetails = getTeacherDetails(teacherId);
    final teacherName = teacherDetails?['name'] ?? 'Teacher';
    final now = DateTime.now();

    return [
      AnnouncementModel(
        id: 'tann_1_$teacherId',
        title: 'Form 4 Mid-Term Examination Schedule',
        message: 'Dear students, the mid-term examination for Form 4 will be held from March 1-5, 2026. Please prepare well and refer to the study materials provided in class.',
        createdBy: teacherName,
        date: now.subtract(const Duration(days: 1)),
        isPublished: true,
      ),
      AnnouncementModel(
        id: 'tann_2_$teacherId',
        title: 'Extra Class This Saturday',
        message: 'There will be an extra class this Saturday from 9:00 AM to 12:00 PM to cover additional topics before the examination. Attendance is optional but highly encouraged.',
        createdBy: teacherName,
        date: now.subtract(const Duration(days: 2)),
        isPublished: true,
      ),
      AnnouncementModel(
        id: 'tann_3_$teacherId',
        title: 'Assignment Submission Reminder',
        message: 'Reminder: All pending assignments must be submitted by Friday, February 14, 2026. Late submissions will not be accepted without valid reasons.',
        createdBy: teacherName,
        date: now.subtract(const Duration(days: 3)),
        isPublished: true,
      ),
      AnnouncementModel(
        id: 'tann_4_$teacherId',
        title: 'Draft: New Project Guidelines',
        message: 'Planning to introduce a new group project for students. This will be announced after finalizing the details with the department.',
        createdBy: teacherName,
        date: now.subtract(const Duration(hours: 5)),
        isPublished: false,
      ),
    ];
  }

  // Get students in a class
  static List<Map<String, dynamic>> getStudentsInClass(String classId) {
    // Sample Malaysian student names for each class
    final studentNames = [
      'Ahmad bin Ali',
      'Siti Nurhaliza binti Abdullah',
      'Raj Kumar a/l Suresh',
      'Mei Ling Wong',
      'Fatimah binti Ibrahim',
      'Muhammad Hafiz bin Hassan',
      'Nurul Ain binti Ismail',
      'Vijay a/l Raman',
      'Li Ying Tan',
      'Azman bin Zainuddin',
      'Aishah binti Mohamed',
      'Kumar a/l Selvam',
      'Xiao Mei Chen',
      'Ismail bin Idris',
      'Zaleha binti Zakaria',
      'Ravi a/l Krishnan',
      'Hui Min Lee',
      'Hafiz bin Hamzah',
      'Nadia binti Nasir',
      'Suresh a/l Gopal',
      'Yan Yan Lim',
      'Faizal bin Fadzil',
      'Mariam binti Mahmud',
      'Mohan a/l Murthy',
      'Jia Qi Wong',
      'Zulkifli bin Zakaria',
      'Laila binti Latif',
      'Prakash a/l Pillai',
      'Xin Yi Tan',
      'Razak bin Rahman',
    ];

    final students = <Map<String, dynamic>>[];
    for (int i = 0; i < 30; i++) {
      students.add({
        'id': 's${classId}_$i',
        'name': studentNames[i % studentNames.length],
        'classId': classId,
      });
    }
    
    return students;
  }
}
