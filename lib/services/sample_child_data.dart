import 'package:studycompanion_app/models/child_model.dart';

class SampleChildData {
  /// Generate sample children data for testing parent dashboard
  static List<ChildModel> generateSampleChildren() {
    return [
      // Form 4A Students
      ChildModel(
        id: 's1',
        name: 'Amir Abdullah',
        grade: 'Form 4A',
        gpa: 3.8,
        homework: 'Mathematics Worksheet - Page 45-50 (Due Tomorrow)',
        quiz: 'Science Quiz on Friday (Topics: Photosynthesis & Respiration)',
        reminder: 'Submit English Essay on "My Best Friend" by Wednesday',
      ),
      // Form 4B Students
      ChildModel(
        id: 's2',
        name: 'Muhammad Azhar',
        grade: 'Form 4B',
        gpa: 3.7,
        homework: 'History Research Project on "Ancient Civilizations" (5 pages)',
        quiz: 'Biology Quiz on Monday (Topics: Cell Structure & Functions)',
        reminder: 'Chemistry practical on Tuesday - Bring lab coat and safety goggles',
      ),
      // Form 4C Students
      ChildModel(
        id: 's3',
        name: 'Nur Azlina',
        grade: 'Form 4C',
        gpa: 3.5,
        homework: 'Geography Mapping Project - Malaysia Regional Analysis',
        quiz: 'Physics Quiz on Thursday (Topics: Motion & Forces)',
        reminder: 'Moral Education presentation on "Integrity" next Monday',
      ),
      // Form 4A Students (continued)
      ChildModel(
        id: 's4',
        name: 'Siti Mariah',
        grade: 'Form 4A',
        gpa: 3.9,
        homework: 'Biology Chapter 5-6 Study Notes + Mindmap',
        quiz: 'Mathematics Quiz on Monday (Topics: Algebra & Geometry)',
        reminder: 'Art project "My Community" due next Friday - Use recycled materials',
      ),
      // Form 4B Students (continued)
      ChildModel(
        id: 's5',
        name: 'Lim Wei Chen',
        grade: 'Form 4B',
        gpa: 3.6,
        homework: 'Physics Practice Problems Set 3 (20 questions)',
        quiz: 'English Literature Quiz on Wednesday (Topics: Shakespeare plays)',
        reminder: 'Register for Math Olympiad by Friday - Talk to Cikgu Ahmad',
      ),
      // Form 4A Students (continued)
      ChildModel(
        id: 's6',
        name: 'Raj Kumar',
        grade: 'Form 4A',
        gpa: 3.1,
        homework: 'Computer Science Programming Assignment - Sorting Algorithms',
        quiz: 'Accounting Quiz on Friday (Topics: Ledgers & Balance Sheet)',
        reminder: 'Economics project on "Supply & Demand" due next Wednesday',
      ),
      // Form 4B Students (continued)
      ChildModel(
        id: 's7',
        name: 'Sophia Wong',
        grade: 'Form 4B',
        gpa: 3.2,
        homework: 'Additional Mathematics Chapter 4 - Integration Problems',
        quiz: 'Chemistry Quiz on Tuesday (Topics: Organic Chemistry & Reactions)',
        reminder: 'Attend Biology Remedial Class on Saturday - Meet at lab',
      ),
      // Form 4C Students (continued)
      ChildModel(
        id: 's8',
        name: 'Priya Sharma',
        grade: 'Form 4C',
        gpa: 3.3,
        homework: 'Modern Chinese Language Composition - "My Future Plans" (500 words)',
        quiz: 'Islamic Education Quiz on Thursday (Topics: Aqidah & Ibadah)',
        reminder: 'Debate Competition rehearsal on Friday - School auditorium',
      ),
      // Form 4A Students (continued)
      ChildModel(
        id: 's9',
        name: 'Adnan Hassan',
        grade: 'Form 4A',
        gpa: 3.4,
        homework: 'Physical Education Project - "Healthy Lifestyle" Research',
        quiz: 'History Quiz on Monday (Topics: Malaysian Independence & Formation)',
        reminder: 'Sports Day trials next week - Register by Wednesday',
      ),
      // Form 4B Students (continued)
      ChildModel(
        id: 's10',
        name: 'Tan Jun Wei',
        grade: 'Form 4B',
        gpa: 3.8,
        homework: 'Technical Drawing - Engineering Design Project (CAD)',
        quiz: 'Business Studies Quiz on Wednesday (Topics: Entrepreneurship)',
        reminder: 'Attend career talk by engineer tomorrow at 2 PM - Room 101',
      ),
      // Form 4C Students (continued)
      ChildModel(
        id: 's11',
        name: 'Nurul Izzah',
        grade: 'Form 4C',
        gpa: 4.0,
        homework: 'Kemahiran Hidup - Culinary Arts Project Presentation Ready',
        quiz: 'English Quiz on Friday (Topics: Grammar & Comprehension)',
        reminder: 'Induction as Form Captain next Monday - Mandatory attendance',
      ),
      // Form 4A Students (continued)
      ChildModel(
        id: 's12',
        name: 'Davina Ooi',
        grade: 'Form 4A',
        gpa: 3.9,
        homework: 'Pendidikan Seni - Visual Arts Portfolio Final Submission',
        quiz: 'Mathematics Quiz on Thursday (Topics: Statistics & Probability)',
        reminder: 'Submit CCA (Astronomy Club) Field Trip Report by Friday',
      ),
    ];
  }

  /// Get sample children for a specific parent
  static List<ChildModel> getSampleChildrenForParent(String parentId) {
    // Mapping of parent IDs to children (all 11 parents with correct mappings)
    final parentChildMapping = {
      'p1': ['s4'],        // Abdullah Hassan → Siti Mariah
      'p2': ['s1'],        // Encik Karim Ahmad → Amir Abdullah
      'p3': ['s2'],        // Puan Norhaida Mahmud → Muhammad Azhar
      'p4': ['s5'],        // Encik Lim Chen Hao → Lim Wei Chen
      'p5': ['s6'],        // Mr. Raj Nair Kumar → Raj Kumar (CORRECTED from s3)
      'p6': ['s7'],        // Encik Wong Tian Huat → Sophia Wong
      'p7': ['s8'],        // Mr. Viswanathan Sharma → Priya Sharma
      'p8': ['s3', 's11'], // Puan Siti Nur Azizah → Nur Azlina & Nurul Izzah (SPECIAL: 2 children)
      'p9': ['s12'],       // Encik Ooi Seng Keat → Davina Ooi
      'p10': ['s10'],      // Encik Tan Cheng Huat → Tan Jun Wei
      'p11': ['s9'],       // Encik Rashid Abdullah → Adnan Hassan
    };

    final children = generateSampleChildren();
    final assignedChildIds = parentChildMapping[parentId] ?? [];

    return children.where((child) => assignedChildIds.contains(child.id)).toList();
  }

  /// Get a specific child by ID
  static ChildModel? getSampleChildById(String childId) {
    try {
      return generateSampleChildren().firstWhere((child) => child.id == childId);
    } catch (e) {
      return null;
    }
  }

  /// Search children by name
  static List<ChildModel> searchChildren(String keyword) {
    final all = generateSampleChildren();
    final lowerKeyword = keyword.toLowerCase();

    return all
        .where((child) =>
            child.name.toLowerCase().contains(lowerKeyword) ||
            child.grade.toLowerCase().contains(lowerKeyword))
        .toList();
  }

  /// Get children by grade
  static List<ChildModel> getChildrenByGrade(String grade) {
    final all = generateSampleChildren();
    return all.where((child) => child.grade == grade).toList();
  }

  /// Get top performing children (by GPA)
  static List<ChildModel> getTopPerformers({int limit = 3}) {
    final all = generateSampleChildren();
    all.sort((a, b) => b.gpa.compareTo(a.gpa));
    return all.take(limit).toList();
  }

  /// Update child (mock update for sample data)
  static ChildModel updateChildMock(
    String childId,
    Map<String, dynamic> updates,
  ) {
    final child = getSampleChildById(childId);
    if (child == null) throw Exception('Child not found');

    return ChildModel(
      id: child.id,
      name: updates['name'] ?? child.name,
      grade: updates['grade'] ?? child.grade,
      gpa: (updates['gpa'] ?? child.gpa).toDouble(),
      homework: updates['homework'] ?? child.homework,
      quiz: updates['quiz'] ?? child.quiz,
      reminder: updates['reminder'] ?? child.reminder,
    );
  }
}
