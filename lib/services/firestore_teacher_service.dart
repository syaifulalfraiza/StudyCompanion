import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studycompanion_app/models/class_model.dart';
import 'package:studycompanion_app/models/assignment_model.dart';
import 'package:studycompanion_app/models/grade_model.dart';
import 'package:studycompanion_app/models/announcement_model.dart';

/// Service to handle all Firestore operations for Teacher Module
class FirestoreTeacherService {
  static final FirestoreTeacherService _instance = FirestoreTeacherService._internal();
  
  factory FirestoreTeacherService() {
    return _instance;
  }
  
  FirestoreTeacherService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ========== TEACHERS COLLECTION ==========
  
  /// Get teacher details by ID
  Future<Map<String, dynamic>?> getTeacherDetails(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection('teachers')
          .where('userId', isEqualTo: teacherId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting teacher details: $e');
      return null;
    }
  }
  
  // ========== CLASSES COLLECTION ==========
  
  /// Get all classes for a teacher
  Future<List<ClassModel>> getClassesForTeacher(String teacherId) async {
    try {
      print('🔍 Querying classes for teacherId: $teacherId');
      final snapshot = await _firestore
          .collection('classes')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      print('📊 Found ${snapshot.docs.length} classes for teacher $teacherId');
      if (snapshot.docs.isEmpty) {
        print('⚠️ No classes found! Checking all documents in classes collection...');
        final allClasses = await _firestore.collection('classes').get();
        print('📋 Total classes in database: ${allClasses.docs.length}');
        for (var doc in allClasses.docs.take(3)) {
          print('   Sample: ${doc.id} -> teacherId: ${doc.data()['teacherId']}');
        }
      }
      
      final classes = snapshot.docs
          .map((doc) => ClassModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort by name in code (avoids need for composite indexes)
      classes.sort((a, b) => a.name.compareTo(b.name));
      
      return classes;
    } catch (e) {
      print('❌ Error getting classes: $e');
      return [];
    }
  }
  
  /// Get a specific class by ID
  Future<ClassModel?> getClassById(String classId) async {
    try {
      final doc = await _firestore.collection('classes').doc(classId).get();
      if (doc.exists) {
        return ClassModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting class: $e');
      return null;
    }
  }
  
  // ========== ASSIGNMENTS COLLECTION ==========
  
  /// Get all assignments for a teacher
  Future<List<AssignmentModel>> getAssignmentsForTeacher(String teacherId) async {
    try {
      print('🔍 Querying assignments for teacherId: $teacherId');
      final snapshot = await _firestore
          .collection('assignments')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      print('📊 Found ${snapshot.docs.length} assignments for teacher $teacherId');
      if (snapshot.docs.isEmpty) {
        print('⚠️ No assignments found! Checking all documents in assignments collection...');
        final allAssignments = await _firestore.collection('assignments').get();
        print('📋 Total assignments in database: ${allAssignments.docs.length}');
        for (var doc in allAssignments.docs.take(3)) {
          print('   Sample: ${doc.id} -> teacherId: ${doc.data()['teacherId']}');
        }
      }
      
      final assignments = snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort by dueDate in code (avoids need for composite indexes)
      assignments.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      
      return assignments;
    } catch (e) {
      print('❌ Error getting assignments: $e');
      return [];
    }
  }
  
  /// Get assignments for a specific class
  Future<List<AssignmentModel>> getAssignmentsForClass(String classId) async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .where('classId', isEqualTo: classId)
          .get();
      
      final assignments = snapshot.docs
          .map((doc) => AssignmentModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort by dueDate in code (avoids need for composite indexes)
      assignments.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      
      return assignments;
    } catch (e) {
      print('❌ Error getting class assignments: $e');
      return [];
    }
  }
  
  /// Get a specific assignment by ID
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    try {
      final doc = await _firestore.collection('assignments').doc(assignmentId).get();
      if (doc.exists) {
        return AssignmentModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting assignment: $e');
      return null;
    }
  }
  
  /// Create a new assignment
  Future<String?> createAssignment({
    required String classId,
    required String title,
    required String description,
    required String subject,
    required String teacherId,
    required DateTime dueDate,
  }) async {
    try {
      // Get class to get student count
      final classModel = await getClassById(classId);
      if (classModel == null) {
        throw Exception('Class not found');
      }

      final docRef = await _firestore.collection('assignments').add({
        'title': title,
        'description': description,
        'classId': classId,
        'teacherId': teacherId,
        'subject': subject,
        'dueDate': dueDate.toIso8601String(),
        'createdDate': DateTime.now().toIso8601String(),
        'submittedCount': 0,
        'totalStudents': classModel.studentCount,
        'isPublished': true,
      });

      print('✅ Assignment created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating assignment: $e');
      return null;
    }
  }
  
  /// Update an assignment
  Future<bool> updateAssignment(
    String assignmentId, {
    required String title,
    required String description,
    required DateTime dueDate,
    required bool isPublished,
  }) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).update({
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'isPublished': isPublished,
      });

      print('✅ Assignment updated: $assignmentId');
      return true;
    } catch (e) {
      print('❌ Error updating assignment: $e');
      return false;
    }
  }
  
  /// Delete an assignment
  Future<bool> deleteAssignment(String assignmentId) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).delete();
      print('✅ Assignment deleted: $assignmentId');
      return true;
    } catch (e) {
      print('❌ Error deleting assignment: $e');
      return false;
    }
  }
  
  // ========== GRADES COLLECTION ==========
  
  /// Get all grades for an assignment
  Future<List<GradeModel>> getGradesForAssignment(String assignmentId) async {
    try {
      final snapshot = await _firestore
          .collection('grades')
          .where('assignmentId', isEqualTo: assignmentId)
          .get();
      
      final grades = snapshot.docs
          .map((doc) => GradeModel.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort by recordedDate in code
      grades.sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
      
      return grades;
    } catch (e) {
      print('❌ Error getting grades: $e');
      return [];
    }
  }
  
  /// Get grade for a specific student in an assignment
  Future<GradeModel?> getGradeForStudent(String assignmentId, String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('grades')
          .where('assignmentId', isEqualTo: assignmentId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return GradeModel.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting student grade: $e');
      return null;
    }
  }
  
  /// Record or update a grade
  Future<String?> recordGrade({
    required String studentId,
    required String assignmentId,
    required String classId,
    required String teacherId,
    required double score,
    required double maxScore,
    required String grade,
    String? feedback,
    String? rubricNotes,
  }) async {
    try {
      // Check if grade already exists
      final snapshot = await _firestore
          .collection('grades')
          .where('studentId', isEqualTo: studentId)
          .where('assignmentId', isEqualTo: assignmentId)
          .limit(1)
          .get();

      final gradeData = {
        'studentId': studentId,
        'assignmentId': assignmentId,
        'classId': classId,
        'teacherId': teacherId,
        'score': score,
        'maxScore': maxScore,
        'grade': grade,
        'feedback': feedback,
        'recordedDate': DateTime.now().toIso8601String(),
        'rubricNotes': rubricNotes,
      };

      String docId;
      if (snapshot.docs.isNotEmpty) {
        // Update existing grade
        docId = snapshot.docs.first.id;
        await _firestore.collection('grades').doc(docId).update(gradeData);
        print('✅ Grade updated: $docId');
      } else {
        // Create new grade
        final docRef = await _firestore.collection('grades').add(gradeData);
        docId = docRef.id;
        print('✅ Grade created: $docId');
      }
      return docId;
    } catch (e) {
      print('❌ Error recording grade: $e');
      return null;
    }
  }
  
  // ========== ANNOUNCEMENTS COLLECTION ==========
  
  /// Get all announcements for a teacher
  Future<List<AnnouncementModel>> getAnnouncementsForTeacher(String teacherId) async {
    try {
      final snapshot = await _firestore
        .collection('announcements')
        .where('createdBy', isEqualTo: teacherId)
        .get();
      
      var announcements = snapshot.docs
        .map((doc) => AnnouncementModel.fromJson(doc.data(), docId: doc.id))
        .toList();

      if (announcements.isEmpty) {
      final allSnapshot = await _firestore.collection('announcements').get();
      announcements = allSnapshot.docs
        .map((doc) => AnnouncementModel.fromJson(doc.data(), docId: doc.id))
        .toList();
      }
      
      // Sort by date in code
      announcements.sort((a, b) => b.date.compareTo(a.date));
      
      return announcements;
    } catch (e) {
      print('❌ Error getting announcements: $e');
      return [];
    }
  }
  
  /// Get published announcements for a teacher
  Future<List<AnnouncementModel>> getPublishedAnnouncementsForTeacher(String teacherId) async {
    try {
      final snapshot = await _firestore
        .collection('announcements')
        .where('createdBy', isEqualTo: teacherId)
        .where('isPublished', isEqualTo: true)
        .get();
      
      var announcements = snapshot.docs
        .map((doc) => AnnouncementModel.fromJson(doc.data(), docId: doc.id))
        .toList();

      if (announcements.isEmpty) {
      final allSnapshot = await _firestore
        .collection('announcements')
        .where('isPublished', isEqualTo: true)
        .get();
      announcements = allSnapshot.docs
        .map((doc) => AnnouncementModel.fromJson(doc.data(), docId: doc.id))
        .toList();
      }
      
      // Sort by date in code
      announcements.sort((a, b) => b.date.compareTo(a.date));
      
      return announcements;
    } catch (e) {
      print('❌ Error getting published announcements: $e');
      return [];
    }
  }
  
  /// Create a new announcement
  Future<String?> createAnnouncement({
    required String title,
    required String message,
    required String createdBy,
    required bool isPublished,
  }) async {
    try {
      final docRef = await _firestore.collection('announcements').add({
        'title': title,
        'message': message,
        'createdBy': createdBy,
        'date': DateTime.now().toIso8601String(),
        'isPublished': isPublished,
      });

      print('✅ Announcement created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating announcement: $e');
      return null;
    }
  }
  
  /// Update an announcement
  Future<bool> updateAnnouncement(
    String announcementId, {
    required String title,
    required String message,
    required bool isPublished,
  }) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).update({
        'title': title,
        'message': message,
        'isPublished': isPublished,
      });

      print('✅ Announcement updated: $announcementId');
      return true;
    } catch (e) {
      print('❌ Error updating announcement: $e');
      return false;
    }
  }
  
  /// Delete an announcement
  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).delete();
      print('✅ Announcement deleted: $announcementId');
      return true;
    } catch (e) {
      print('❌ Error deleting announcement: $e');
      return false;
    }
  }
  
  // ========== UTILITY METHODS ==========
  
  /// Get assignment statistics
  Future<Map<String, dynamic>> getAssignmentStats(String assignmentId) async {
    try {
      final assignment = await getAssignmentById(assignmentId);
      final grades = await getGradesForAssignment(assignmentId);

      if (assignment == null) {
        return {};
      }

      double? averageScore;
      if (grades.isNotEmpty) {
        final scores = grades.map((g) => (g.score / g.maxScore) * 100).toList();
        averageScore = scores.reduce((a, b) => a + b) / scores.length;
      }

      return {
        'title': assignment.title,
        'submittedCount': assignment.submittedCount,
        'totalStudents': assignment.totalStudents,
        'submissionPercentage': assignment.submissionPercentage,
        'gradedCount': grades.length,
        'averageScore': averageScore,
        'dueDate': assignment.dueDate,
        'isOverdue': assignment.isOverdue,
        'isDueSoon': assignment.isDueSoon,
      };
    } catch (e) {
      print('❌ Error getting assignment stats: $e');
      return {};
    }
  }
  
  /// Get dashboard summary for teacher
  Future<Map<String, dynamic>> getDashboardSummary(String teacherId) async {
    try {
      final classes = await getClassesForTeacher(teacherId);
      final assignments = await getAssignmentsForTeacher(teacherId);
      final announcements = await getAnnouncementsForTeacher(teacherId);

      final pendingSubmissions = assignments
          .where((a) => a.submissionPercentage < 100 && !a.isOverdue)
          .length;

      final overdue = assignments.where((a) => a.isOverdue).length;

      return {
        'totalClasses': classes.length,
        'totalAssignments': assignments.length,
        'pendingSubmissions': pendingSubmissions,
        'overdueAssignments': overdue,
        'totalAnnouncements': announcements.length,
      };
    } catch (e) {
      print('❌ Error getting dashboard summary: $e');
      return {};
    }
  }
}
