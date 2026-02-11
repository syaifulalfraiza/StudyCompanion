import 'package:flutter/foundation.dart';
import 'package:studycompanion_app/models/class_model.dart';
import 'package:studycompanion_app/models/assignment_model.dart';
import 'package:studycompanion_app/models/announcement_model.dart';
import 'package:studycompanion_app/models/grade_model.dart';
import 'package:studycompanion_app/services/sample_teacher_data.dart';
import 'package:studycompanion_app/services/firestore_teacher_service.dart';

class TeacherDashboardViewModel extends ChangeNotifier {
  // Service instances
  final FirestoreTeacherService _firestoreService = FirestoreTeacherService();

  // State Variables
  String _teacherId = 't5'; // Default teacher ID (Cikgu Farah)
  String _teacherName = '';
  String _teacherSubject = '';
  String _teacherEmail = '';
  String _selectedClassId = '';

  List<ClassModel> _classes = [];
  List<AssignmentModel> _allAssignments = [];
  List<AssignmentModel> _filteredAssignments = [];
  List<AnnouncementModel> _announcements = [];
  final Map<String, List<GradeModel>> _gradesByAssignment = {};

  bool _isLoading = false;
  String? _errorMessage;
  bool _useFirestore = true; // Use Firestore by default, fallback to sample data
  bool _useSampleData = false; // For explicit sample data mode

  // Getters
  String get teacherId => _teacherId;
  String get teacherName => _teacherName;
  String get teacherSubject => _teacherSubject;
  String get teacherEmail => _teacherEmail;
  String get selectedClassId => _selectedClassId;

  List<ClassModel> get classes => _classes;
  List<AssignmentModel> get allAssignments => _allAssignments;
  List<AssignmentModel> get filteredAssignments => _filteredAssignments;
  List<AnnouncementModel> get teacherAnnouncements => _announcements;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get useSampleData => _useSampleData;
  bool get useFirestore => _useFirestore;

  // Initialize with teacher ID
  void initializeTeacher(String teacherId) {
    _teacherId = teacherId;
    loadTeacherData();
  }

  // Load all teacher data
  Future<void> loadTeacherData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useFirestore && !_useSampleData) {
        // Load from Firestore
        await _loadFromFirestore();
      } else {
        // Load from sample data (fallback or explicit)
        _loadTeacherDetailsFromSample();
        _loadClassesFromSample();
        _loadAssignmentsFromSample();
        _loadAnnouncementsFromSample();
        _loadGradesFromSample();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading teacher data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all data from Firestore
  Future<void> _loadFromFirestore() async {
    try {
      print('🔵 Loading data for teacher: $_teacherId');
      
      // Load teacher details
      final teacherData = await _firestoreService.getTeacherDetails(_teacherId);
      if (teacherData != null) {
        _teacherName = teacherData['name'] ?? '';
        _teacherSubject = teacherData['subject'] ?? '';
        _teacherEmail = teacherData['email'] ?? '';
        print('✅ Teacher details: name=$_teacherName, subject=$_teacherSubject');
      } else {
        print('⚠️ Teacher details not found for $_teacherId');
      }

      // Load classes
      _classes = await _firestoreService.getClassesForTeacher(_teacherId);
      print('✅ Classes loaded: ${_classes.length} classes');
      for (var c in _classes) {
        print('   - ${c.id}: ${c.name}');
      }
      
      if (_classes.isNotEmpty && _selectedClassId.isEmpty) {
        _selectedClassId = _classes[0].id;
      }

      // Load assignments
      _allAssignments = await _firestoreService.getAssignmentsForTeacher(_teacherId);
      _filteredAssignments = _allAssignments;

      // Load announcements
      _announcements = await _firestoreService.getAnnouncementsForTeacher(_teacherId);

      // Load grades for each assignment
      _gradesByAssignment.clear();
      for (var assignment in _allAssignments) {
        final grades = await _firestoreService.getGradesForAssignment(assignment.id);
        _gradesByAssignment[assignment.id] = grades;
      }

      print('✅ Teacher data loaded from Firestore');
    } catch (e) {
      print('❌ Error loading from Firestore: $e');
      print('📦 Falling back to sample data...');
      // Fallback to sample data on error
      _loadTeacherDetailsFromSample();
      _loadClassesFromSample();
      _loadAssignmentsFromSample();
      _loadAnnouncementsFromSample();
      _loadGradesFromSample();
    }
  }

  // Load teacher details from sample data
  void _loadTeacherDetailsFromSample() {
    final details = SampleTeacherData.getTeacherDetails(_teacherId);
    if (details != null) {
      _teacherName = details['name'] ?? '';
      _teacherSubject = details['subject'] ?? '';
      _teacherEmail = details['email'] ?? '';
    }
  }

  // Load classes from sample data
  void _loadClassesFromSample() {
    _classes = SampleTeacherData.getClassesForTeacher(_teacherId);
    if (_classes.isNotEmpty && _selectedClassId.isEmpty) {
      _selectedClassId = _classes[0].id;
    }
  }

  // Load assignments from sample data
  void _loadAssignmentsFromSample() {
    _allAssignments = SampleTeacherData.getAssignmentsForTeacher(_teacherId);
    _filteredAssignments = _allAssignments;
  }

  // Load announcements from sample data
  void _loadAnnouncementsFromSample() {
    _announcements = SampleTeacherData.getAnnouncementsForTeacher(_teacherId);
  }

  // Load grades from sample data
  void _loadGradesFromSample() {
    for (var assignment in _allAssignments) {
      _gradesByAssignment[assignment.id] = 
          SampleTeacherData.getGradesForAssignment(assignment.id);
    }
  }

  // Select a class
  void selectClass(String classId) {
    _selectedClassId = classId;
    filterAssignmentsByClass(classId);
    notifyListeners();
  }

  // Filter assignments by class
  void filterAssignmentsByClass(String classId) {
    if (classId.isEmpty) {
      _filteredAssignments = _allAssignments;
    } else {
      _filteredAssignments = _allAssignments
          .where((assignment) => assignment.classId == classId)
          .toList();
    }
    notifyListeners();
  }

  // Get assignments for a specific class
  List<AssignmentModel> getAssignmentsForClass(String classId) {
    return _allAssignments
        .where((assignment) => assignment.classId == classId)
        .toList();
  }

  // Get class details
  ClassModel? getClassById(String classId) {
    try {
      return _classes.firstWhere((c) => c.id == classId);
    } catch (e) {
      return null;
    }
  }

  // Get assignment details
  AssignmentModel? getAssignmentById(String assignmentId) {
    return SampleTeacherData.getAssignmentById(assignmentId);
  }

  // Get assignment statistics
  Map<String, dynamic> getAssignmentStats(String assignmentId) {
    final assignment = getAssignmentById(assignmentId);
    if (assignment == null) {
      return {};
    }

    return {
      'title': assignment.title,
      'submittedCount': assignment.submittedCount,
      'totalStudents': assignment.totalStudents,
      'submissionPercentage': assignment.submissionPercentage,
      'dueDate': assignment.dueDate,
      'isOverdue': assignment.isOverdue,
      'isDueSoon': assignment.isDueSoon,
    };
  }

  // Get class statistics
  Map<String, dynamic> getClassStats(String classId) {
    final classModel = getClassById(classId);
    if (classModel == null) {
      return {};
    }

    final assignments = getAssignmentsForClass(classId);

    return {
      'className': classModel.name,
      'section': classModel.section,
      'studentCount': classModel.studentCount,
      'totalAssignments': assignments.length,
      'subject': classModel.subject,
      'semester': classModel.semester,
    };
  }

  // Get dashboard summary
  Map<String, dynamic> getDashboardSummary() {
    final recentAssignments = _allAssignments.take(5).toList();
    final pendingSubmissions = _allAssignments
        .where(
          (a) => a.submissionPercentage < 100 && !a.isOverdue,
        )
        .toList();

    final overdue = _allAssignments.where((a) => a.isOverdue).toList();

    return {
      'totalClasses': _classes.length,
      'totalAssignments': _allAssignments.length,
      'pendingSubmissions': pendingSubmissions.length,
      'overdueAssignments': overdue.length,
      'recentAssignments': recentAssignments,
    };
  }

  // Create new assignment (with Firestore support)
  Future<void> createAssignment({
    required String classId,
    required String title,
    required String description,
    required String subject,
    required DateTime dueDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirestore && !_useSampleData) {
        // Create in Firestore
        final assignmentId = await _firestoreService.createAssignment(
          classId: classId,
          title: title,
          description: description,
          subject: subject,
          teacherId: _teacherId,
          dueDate: dueDate,
        );

        if (assignmentId != null) {
          // Reload assignments from Firestore
          _allAssignments = await _firestoreService.getAssignmentsForTeacher(_teacherId);
          filterAssignmentsByClass(_selectedClassId);
        }
      } else {
        // Create in sample data
        final newAssignment = AssignmentModel(
          id: 'a${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          description: description,
          classId: classId,
          teacherId: _teacherId,
          subject: subject,
          dueDate: dueDate,
          createdDate: DateTime.now(),
          submittedCount: 0,
          totalStudents: getClassById(classId)?.studentCount ?? 0,
          isPublished: true,
        );

        _allAssignments.add(newAssignment);
        filterAssignmentsByClass(_selectedClassId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error creating assignment: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get recent assignments
  List<AssignmentModel> getRecentAssignments({int limit = 5}) {
    final sortedAssignments = List<AssignmentModel>.from(_allAssignments)
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return sortedAssignments.take(limit).toList();
  }

  // Toggle sample data usage
  void toggleSampleData(bool useSample) {
    _useSampleData = useSample;
    _useFirestore = !useSample;
    if (useSample) {
      loadTeacherData();
    }
  }

  // Set Firestore mode
  void setFirestoreMode(bool useFirestore) {
    _useFirestore = useFirestore;
    _useSampleData = !useFirestore;
    loadTeacherData();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadTeacherData();
  }

  // ========== ANNOUNCEMENT MANAGEMENT ==========

  // Get announcements by status
  List<AnnouncementModel> getAnnouncementsByStatus(bool isPublished) {
    return _announcements
        .where((announcement) => announcement.isPublished == isPublished)
        .toList();
  }

  // Create new announcement
  Future<void> createAnnouncement({
    required String title,
    required String message,
    bool isPublished = true,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirestore && !_useSampleData) {
        // Create in Firestore
        await _firestoreService.createAnnouncement(
          title: title,
          message: message,
          createdBy: _teacherId,
          isPublished: isPublished,
        );

        // Reload announcements
        _announcements = await _firestoreService.getAnnouncementsForTeacher(_teacherId);
      } else {
        // Create in sample data
        final newAnnouncement = AnnouncementModel(
          id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          message: message,
          createdBy: _teacherName.isNotEmpty ? _teacherName : 'Teacher',
          date: DateTime.now(),
          isPublished: isPublished,
        );

        _announcements.insert(0, newAnnouncement);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error creating announcement: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update announcement
  Future<void> updateAnnouncement(
    String announcementId, {
    required String title,
    required String message,
    required bool isPublished,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirestore && !_useSampleData) {
        // Update in Firestore
        await _firestoreService.updateAnnouncement(
          announcementId,
          title: title,
          message: message,
          isPublished: isPublished,
        );

        // Reload announcements
        _announcements = await _firestoreService.getAnnouncementsForTeacher(_teacherId);
      } else {
        // Update in sample data
        final index = _announcements.indexWhere((a) => a.id == announcementId);
        if (index != -1) {
          final updated = AnnouncementModel(
            id: _announcements[index].id,
            title: title,
            message: message,
            createdBy: _announcements[index].createdBy,
            date: _announcements[index].date,
            isPublished: isPublished,
          );
          _announcements[index] = updated;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating announcement: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete announcement
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirestore && !_useSampleData) {
        // Delete from Firestore
        await _firestoreService.deleteAnnouncement(announcementId);

        // Reload announcements
        _announcements = await _firestoreService.getAnnouncementsForTeacher(_teacherId);
      } else {
        // Delete from sample data
        _announcements.removeWhere((a) => a.id == announcementId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting announcement: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get recent announcements
  List<AnnouncementModel> getRecentAnnouncements({int limit = 5}) {
    final sortedAnnouncements = List<AnnouncementModel>.from(_announcements)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedAnnouncements.take(limit).toList();
  }

  // ========== GRADE VIEWING (Read-Only + Inline Recording) ==========

  // Get grades for an assignment
  List<GradeModel> getGradesForAssignment(String assignmentId) {
    return _gradesByAssignment[assignmentId] ?? [];
  }

  // Get grade for a specific student in an assignment
  GradeModel? getGradeForStudent(String assignmentId, String studentId) {
    final grades = _gradesByAssignment[assignmentId] ?? [];
    try {
      return grades.firstWhere((g) => g.studentId == studentId);
    } catch (e) {
      return null;
    }
  }

  // Record/Update a single grade (inline grading with Firestore support)
  Future<void> recordGrade({
    required String assignmentId,
    required String studentId,
    required String studentName,
    required double percentage,
    String? feedback,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_useFirestore && !_useSampleData) {
        // Get assignment to get classId
        final assignment = await _firestoreService.getAssignmentById(assignmentId);
        if (assignment == null) {
          throw Exception('Assignment not found');
        }

        final maxScore = 100.0;
        final score = (percentage / 100) * maxScore;
        final grade = _calculateLetterGrade(percentage);

        // Record in Firestore
        await _firestoreService.recordGrade(
          studentId: studentId,
          assignmentId: assignmentId,
          classId: assignment.classId,
          teacherId: _teacherId,
          score: score,
          maxScore: maxScore,
          grade: grade,
          feedback: feedback,
        );

        // Reload grades for this assignment
        final grades = await _firestoreService.getGradesForAssignment(assignmentId);
        _gradesByAssignment[assignmentId] = grades;
      } else {
        // Record in sample data
        if (!_gradesByAssignment.containsKey(assignmentId)) {
          _gradesByAssignment[assignmentId] = [];
        }

        final grades = _gradesByAssignment[assignmentId]!;
        final existingIndex = grades.indexWhere((g) => g.studentId == studentId);

        final newGrade = GradeModel(
          id: existingIndex >= 0
              ? grades[existingIndex].id
              : 'g${DateTime.now().millisecondsSinceEpoch}',
          studentId: studentId,
          assignmentId: assignmentId,
          classId: '',
          teacherId: _teacherId,
          score: (percentage / 100) * 100,
          maxScore: 100,
          grade: _calculateLetterGrade(percentage),
          feedback: feedback,
          recordedDate: DateTime.now(),
        );

        if (existingIndex >= 0) {
          grades[existingIndex] = newGrade;
        } else {
          grades.add(newGrade);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error recording grade: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to calculate letter grade
  String _calculateLetterGrade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  // Get assignment progress statistics
  Map<String, dynamic> getAssignmentProgress(String assignmentId) {
    final assignment = getAssignmentById(assignmentId);
    if (assignment == null) {
      return {};
    }

    final grades = getGradesForAssignment(assignmentId);
    final gradedCount = grades.length;
    final totalStudents = assignment.totalStudents;

    double? averageScore;
    if (grades.isNotEmpty) {
      averageScore = grades.map((g) => g.percentage).reduce((a, b) => a + b) / grades.length;
    }

    return {
      'assignment': assignment,
      'totalStudents': totalStudents,
      'submittedCount': assignment.submittedCount,
      'gradedCount': gradedCount,
      'averageScore': averageScore,
      'grades': grades,
    };
  }
}
