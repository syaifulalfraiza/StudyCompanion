import 'package:flutter/material.dart';
import '../models/classroom_model.dart';
import '../models/subject_model.dart';
import '../models/teacher_task_model.dart';
import '../services/firestore_classroom_service.dart';

class ClassroomViewModel extends ChangeNotifier {
  final FirestoreClassroomService _classroomService = FirestoreClassroomService();

  // State variables
  List<ClassroomModel> _classrooms = [];
  List<SubjectModel> _subjects = [];
  List<TeacherTaskModel> _tasks = [];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ClassroomModel> get classrooms => _classrooms;
  List<SubjectModel> get subjects => _subjects;
  List<TeacherTaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==================== CLASSROOM OPERATIONS ====================

  /// Load all classrooms for a teacher
  Future<void> loadClassrooms(String teacherId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classrooms = await _classroomService.getClassroomsForTeacher(teacherId);
      
      // If no classrooms found, use sample data
      if (_classrooms.isEmpty) {
        _classrooms = _getSampleClassrooms();
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Loading sample classrooms...';
      print('Failed to load classrooms: $e, using sample data');
      // Use sample data as fallback
      _classrooms = _getSampleClassrooms();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get sample classrooms for testing
  List<ClassroomModel> _getSampleClassrooms() {
    return [
      ClassroomModel(
        id: 'class1',
        name: 'Mathematics 101',
        section: '10-A',
        teacherId: 't1',
        semester: 'Fall 2024',
        academicYear: '2024-2025',
        studentCount: 35,
      ),
      ClassroomModel(
        id: 'class2',
        name: 'Physics Advanced',
        section: '12-B',
        teacherId: 't1',
        semester: 'Fall 2024',
        academicYear: '2024-2025',
        studentCount: 28,
      ),
      ClassroomModel(
        id: 'class3',
        name: 'English Literature',
        section: '11-C',
        teacherId: 't1',
        semester: 'Fall 2024',
        academicYear: '2024-2025',
        studentCount: 32,
      ),
    ];
  }

  /// Create a new classroom
  Future<String?> createClassroom({
    required String name,
    required String section,
    required String teacherId,
    required String semester,
    required String academicYear,
    List<String> studentIds = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final classroomId = await _classroomService.createClassroom(
        name: name,
        section: section,
        teacherId: teacherId,
        semester: semester,
        academicYear: academicYear,
        studentIds: studentIds,
      );

      if (classroomId != null) {
        // Reload classrooms
        await loadClassrooms(teacherId);
      }

      return classroomId;
    } catch (e) {
      _errorMessage = 'Failed to create classroom: $e';
      print(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a classroom
  Future<bool> updateClassroom({
    required String classroomId,
    required String teacherId,
    String? name,
    String? section,
    String? semester,
    String? academicYear,
    List<String>? studentIds,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _classroomService.updateClassroom(
        classroomId: classroomId,
        name: name,
        section: section,
        semester: semester,
        academicYear: academicYear,
        studentIds: studentIds,
      );

      if (success) {
        // Reload classrooms
        await loadClassrooms(teacherId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to update classroom: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a classroom
  Future<bool> deleteClassroom(String classroomId, String teacherId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _classroomService.deleteClassroom(classroomId);

      if (success) {
        // Reload classrooms
        await loadClassrooms(teacherId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete classroom: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== SUBJECT OPERATIONS ====================

  /// Load all subjects for a classroom
  Future<void> loadSubjects(String classroomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subjects = await _classroomService.getSubjectsForClassroom(classroomId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Loading sample subjects...';
      print('Failed to load subjects: $e');
      // Use sample subjects as fallback
      _subjects = _getSampleSubjects();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get sample subjects
  List<SubjectModel> _getSampleSubjects() {
    return [
      SubjectModel(
        id: 'subject_math_101',
        name: 'Mathematics',
        code: 'MATH101',
        classroomId: 'class1',
        teacherId: 't1',
        description: 'Comprehensive mathematics covering algebra, geometry, and calculus.',
      ),
      SubjectModel(
        id: 'subject_english_101',
        name: 'English Literature',
        code: 'ENG101',
        classroomId: 'class1',
        teacherId: 't1',
        description: 'Classic and contemporary literature analysis and writing skills.',
      ),
      SubjectModel(
        id: 'subject_science_101',
        name: 'Physics',
        code: 'PHY101',
        classroomId: 'class1',
        teacherId: 't1',
        description: 'Fundamentals of physics including mechanics, waves, and energy.',
      ),
      SubjectModel(
        id: 'subject_history_101',
        name: 'History',
        code: 'HIST101',
        classroomId: 'class1',
        teacherId: 't1',
        description: 'World history, cultural heritage, and historical analysis.',
      ),
    ];
  }

  /// Create a new subject
  Future<String?> createSubject({
    required String name,
    required String classroomId,
    required String teacherId,
    required String code,
    String description = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final subjectId = await _classroomService.createSubject(
        name: name,
        classroomId: classroomId,
        teacherId: teacherId,
        code: code,
        description: description,
      );

      if (subjectId != null) {
        // Reload subjects
        await loadSubjects(classroomId);
      }

      return subjectId;
    } catch (e) {
      _errorMessage = 'Failed to create subject: $e';
      print(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a subject
  Future<bool> updateSubject({
    required String subjectId,
    required String classroomId,
    String? name,
    String? code,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _classroomService.updateSubject(
        subjectId: subjectId,
        name: name,
        code: code,
        description: description,
      );

      if (success) {
        // Reload subjects
        await loadSubjects(classroomId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to update subject: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a subject
  Future<bool> deleteSubject(String subjectId, String classroomId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _classroomService.deleteSubject(subjectId);

      if (success) {
        // Reload subjects
        await loadSubjects(classroomId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete subject: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== TASK OPERATIONS ====================

  /// Load all tasks for a subject
  Future<void> loadTasks(String subjectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _classroomService.getTasksForSubject(subjectId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new task
  Future<String?> createTask({
    required String title,
    required String description,
    required String subjectId,
    required String classroomId,
    required String teacherId,
    required TaskType type,
    required DateTime dueDate,
    int totalStudents = 0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final taskId = await _classroomService.createTask(
        title: title,
        description: description,
        subjectId: subjectId,
        classroomId: classroomId,
        teacherId: teacherId,
        type: type,
        dueDate: dueDate,
        totalStudents: totalStudents,
      );

      if (taskId != null) {
        // Reload tasks
        await loadTasks(subjectId);
      }

      return taskId;
    } catch (e) {
      _errorMessage = 'Failed to create task: $e';
      print(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a task
  Future<bool> updateTask({
    required String taskId,
    required String subjectId,
    String? title,
    String? description,
    TaskType? type,
    DateTime? dueDate,
    bool? isActive,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _classroomService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        type: type,
        dueDate: dueDate,
        isActive: isActive,
      );

      if (success) {
        // Reload tasks
        await loadTasks(subjectId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId, String subjectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _classroomService.deleteTask(taskId);

      if (success) {
        // Reload tasks
        await loadTasks(subjectId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle task status (active/inactive)
  Future<bool> toggleTaskStatus(String taskId, bool isActive, String subjectId) async {
    try {
      final success = await _classroomService.toggleTaskStatus(taskId, isActive);

      if (success) {
        // Reload tasks to reflect changes
        await loadTasks(subjectId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to toggle task status: $e';
      print(_errorMessage);
      return false;
    }
  }

  // ==================== STUDENT MANAGEMENT ====================

  /// Add a student to a classroom
  Future<bool> addStudentToClassroom(String classroomId, String studentId, String teacherId) async {
    try {
      final success = await _classroomService.addStudentToClassroom(classroomId, studentId);

      if (success) {
        // Reload classrooms
        await loadClassrooms(teacherId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to add student: $e';
      print(_errorMessage);
      return false;
    }
  }

  /// Remove a student from a classroom
  Future<bool> removeStudentFromClassroom(String classroomId, String studentId, String teacherId) async {
    try {
      final success = await _classroomService.removeStudentFromClassroom(classroomId, studentId);

      if (success) {
        // Reload classrooms
        await loadClassrooms(teacherId);
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to remove student: $e';
      print(_errorMessage);
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
