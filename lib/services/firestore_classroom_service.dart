import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classroom_model.dart';
import '../models/subject_model.dart';
import '../models/teacher_task_model.dart';

class FirestoreClassroomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CLASSROOM CRUD ====================

  /// Get all classrooms for a teacher
  Future<List<ClassroomModel>> getClassroomsForTeacher(String teacherId) async {
    try {
      print('📚 Fetching classrooms for teacher: $teacherId');
      
      final snapshot = await _firestore
          .collection('classes')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      final classrooms = snapshot.docs
          .map((doc) => ClassroomModel.fromJson(doc.data(), doc.id))
          .toList();

      print('✅ Found ${classrooms.length} classrooms');
      return classrooms;
    } catch (e) {
      print('❌ Error getting classrooms: $e');
      return [];
    }
  }

  /// Get a specific classroom by ID
  Future<ClassroomModel?> getClassroomById(String classroomId) async {
    try {
      final doc = await _firestore.collection('classes').doc(classroomId).get();
      
      if (doc.exists && doc.data() != null) {
        return ClassroomModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting classroom: $e');
      return null;
    }
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
    try {
      print('📝 Creating classroom: $name - $section');
      
      final docRef = await _firestore.collection('classes').add({
        'name': name,
        'section': section,
        'teacherId': teacherId,
        'studentCount': studentIds.length,
        'semester': semester,
        'academicYear': academicYear,
        'studentIds': studentIds,
      });

      print('✅ Classroom created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating classroom: $e');
      return null;
    }
  }

  /// Update an existing classroom
  Future<bool> updateClassroom({
    required String classroomId,
    String? name,
    String? section,
    String? semester,
    String? academicYear,
    List<String>? studentIds,
  }) async {
    try {
      print('📝 Updating classroom: $classroomId');
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (section != null) updates['section'] = section;
      if (semester != null) updates['semester'] = semester;
      if (academicYear != null) updates['academicYear'] = academicYear;
      if (studentIds != null) {
        updates['studentIds'] = studentIds;
        updates['studentCount'] = studentIds.length;
      }

      await _firestore.collection('classes').doc(classroomId).update(updates);
      
      print('✅ Classroom updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating classroom: $e');
      return false;
    }
  }

  /// Delete a classroom
  Future<bool> deleteClassroom(String classroomId) async {
    try {
      print('🗑️ Deleting classroom: $classroomId');
      
      // Delete all subjects in this classroom
      final subjects = await getSubjectsForClassroom(classroomId);
      for (var subject in subjects) {
        await deleteSubject(subject.id);
      }
      
      // Delete the classroom
      await _firestore.collection('classes').doc(classroomId).delete();
      
      print('✅ Classroom deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting classroom: $e');
      return false;
    }
  }

  // ==================== SUBJECT CRUD ====================

  /// Get all subjects for a classroom
  Future<List<SubjectModel>> getSubjectsForClassroom(String classroomId) async {
    try {
      print('📚 Fetching subjects for classroom: $classroomId');
      
      final snapshot = await _firestore
          .collection('subjects')
          .where('classroomId', isEqualTo: classroomId)
          .get();

      final subjects = snapshot.docs
          .map((doc) => SubjectModel.fromJson(doc.data(), doc.id))
          .toList();

      print('✅ Found ${subjects.length} subjects');
      
      // Fallback to sample subjects if none found
      if (subjects.isEmpty) {
        print('📝 No subjects found, using sample subjects');
        return _getSampleSubjects(classroomId);
      }
      
      return subjects;
    } catch (e) {
      print('❌ Error getting subjects: $e, using sample subjects');
      return _getSampleSubjects(classroomId);
    }
  }

  /// Get sample subjects for a classroom
  List<SubjectModel> _getSampleSubjects(String classroomId) {
    return [
      SubjectModel(
        id: 'subject_math_101',
        name: 'Mathematics',
        code: 'MATH101',
        classroomId: classroomId,
        teacherId: 'teacher_1',
        description: 'Comprehensive mathematics covering algebra, geometry, and calculus.',
      ),
      SubjectModel(
        id: 'subject_english_101',
        name: 'English Literature',
        code: 'ENG101',
        classroomId: classroomId,
        teacherId: 'teacher_1',
        description: 'Classic and contemporary literature analysis and writing skills.',
      ),
      SubjectModel(
        id: 'subject_science_101',
        name: 'Physics',
        code: 'PHY101',
        classroomId: classroomId,
        teacherId: 'teacher_1',
        description: 'Fundamentals of physics including mechanics, waves, and energy.',
      ),
      SubjectModel(
        id: 'subject_history_101',
        name: 'History',
        code: 'HIST101',
        classroomId: classroomId,
        teacherId: 'teacher_1',
        description: 'World history, cultural heritage, and historical analysis.',
      ),
    ];
  }

  /// Get a specific subject by ID
  Future<SubjectModel?> getSubjectById(String subjectId) async {
    try {
      final doc = await _firestore.collection('subjects').doc(subjectId).get();
      
      if (doc.exists && doc.data() != null) {
        return SubjectModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting subject: $e');
      return null;
    }
  }

  /// Create a new subject
  Future<String?> createSubject({
    required String name,
    required String classroomId,
    required String teacherId,
    required String code,
    String description = '',
  }) async {
    try {
      print('📝 Creating subject: $name ($code)');
      
      final docRef = await _firestore.collection('subjects').add({
        'name': name,
        'classroomId': classroomId,
        'teacherId': teacherId,
        'code': code,
        'description': description,
      });

      print('✅ Subject created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating subject: $e');
      return null;
    }
  }

  /// Update an existing subject
  Future<bool> updateSubject({
    required String subjectId,
    String? name,
    String? code,
    String? description,
  }) async {
    try {
      print('📝 Updating subject: $subjectId');
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (code != null) updates['code'] = code;
      if (description != null) updates['description'] = description;

      await _firestore.collection('subjects').doc(subjectId).update(updates);
      
      print('✅ Subject updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating subject: $e');
      return false;
    }
  }

  /// Delete a subject
  Future<bool> deleteSubject(String subjectId) async {
    try {
      print('🗑️ Deleting subject: $subjectId');
      
      // Delete all tasks for this subject
      final tasks = await getTasksForSubject(subjectId);
      for (var task in tasks) {
        await deleteTask(task.id);
      }
      
      // Delete the subject
      await _firestore.collection('subjects').doc(subjectId).delete();
      
      print('✅ Subject deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting subject: $e');
      return false;
    }
  }

  // ==================== TEACHER TASK CRUD ====================

  /// Get all tasks for a subject
  Future<List<TeacherTaskModel>> getTasksForSubject(String subjectId) async {
    try {
      print('📚 Fetching tasks for subject: $subjectId');
      
      final snapshot = await _firestore
          .collection('teacher_tasks')
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('createdAt', descending: true)
          .get();

      final tasks = snapshot.docs
          .map((doc) => TeacherTaskModel.fromJson(doc.data(), doc.id))
          .toList();

      print('✅ Found ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      print('❌ Error getting tasks: $e');
      return [];
    }
  }

  /// Get a specific task by ID
  Future<TeacherTaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore.collection('teacher_tasks').doc(taskId).get();
      
      if (doc.exists && doc.data() != null) {
        return TeacherTaskModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting task: $e');
      return null;
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
    try {
      print('📝 Creating task: $title (${type.displayName})');
      
      final docRef = await _firestore.collection('teacher_tasks').add({
        'title': title,
        'description': description,
        'subjectId': subjectId,
        'classroomId': classroomId,
        'teacherId': teacherId,
        'type': type.value,
        'dueDate': dueDate.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'totalStudents': totalStudents,
        'submittedCount': 0,
        'isActive': true,
      });

      print('✅ Task created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating task: $e');
      return null;
    }
  }

  /// Update an existing task
  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    TaskType? type,
    DateTime? dueDate,
    bool? isActive,
  }) async {
    try {
      print('📝 Updating task: $taskId');
      
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (type != null) updates['type'] = type.value;
      if (dueDate != null) updates['dueDate'] = dueDate.toIso8601String();
      if (isActive != null) updates['isActive'] = isActive;

      await _firestore.collection('teacher_tasks').doc(taskId).update(updates);
      
      print('✅ Task updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating task: $e');
      return false;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      print('🗑️ Deleting task: $taskId');
      
      await _firestore.collection('teacher_tasks').doc(taskId).delete();
      
      print('✅ Task deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting task: $e');
      return false;
    }
  }

  /// Update task submission count (when a student submits)
  Future<bool> updateTaskSubmissionCount(String taskId, int submittedCount) async {
    try {
      await _firestore.collection('teacher_tasks').doc(taskId).update({
        'submittedCount': submittedCount,
      });
      
      return true;
    } catch (e) {
      print('❌ Error updating submission count: $e');
      return false;
    }
  }

  /// Toggle task completion status
  Future<bool> toggleTaskStatus(String taskId, bool isActive) async {
    try {
      await _firestore.collection('teacher_tasks').doc(taskId).update({
        'isActive': isActive,
      });
      
      print('✅ Task status toggled: $isActive');
      return true;
    } catch (e) {
      print('❌ Error toggling task status: $e');
      return false;
    }
  }

  // ==================== STUDENT MANAGEMENT ====================

  /// Add a student to a classroom
  Future<bool> addStudentToClassroom(String classroomId, String studentId) async {
    try {
      final classroom = await getClassroomById(classroomId);
      if (classroom == null) return false;

      final updatedStudentIds = List<String>.from(classroom.studentIds);
      if (!updatedStudentIds.contains(studentId)) {
        updatedStudentIds.add(studentId);
        
        await updateClassroom(
          classroomId: classroomId,
          studentIds: updatedStudentIds,
        );
      }
      
      return true;
    } catch (e) {
      print('❌ Error adding student to classroom: $e');
      return false;
    }
  }

  /// Remove a student from a classroom
  Future<bool> removeStudentFromClassroom(String classroomId, String studentId) async {
    try {
      final classroom = await getClassroomById(classroomId);
      if (classroom == null) return false;

      final updatedStudentIds = List<String>.from(classroom.studentIds);
      updatedStudentIds.remove(studentId);
      
      await updateClassroom(
        classroomId: classroomId,
        studentIds: updatedStudentIds,
      );
      
      return true;
    } catch (e) {
      print('❌ Error removing student from classroom: $e');
      return false;
    }
  }
}
