import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for User in the users collection
class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.isActive,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      userId: json['userId'] ?? docId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

/// Service for admin user management operations
class AdminUserManagementService {
  static final AdminUserManagementService _instance = AdminUserManagementService._internal();
  
  factory AdminUserManagementService() {
    return _instance;
  }
  
  AdminUserManagementService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Get all users from Firestore
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }
  
  /// Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role.toLowerCase())
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error getting users by role: $e');
      return [];
    }
  }
  
  /// Stream all users for real-time updates
  Stream<List<UserModel>> streamAllUsers() {
    return _firestore.collection('users').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList(),
    );
  }
  
  /// Stream users by role
  Stream<List<UserModel>> streamUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role.toLowerCase())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }
  
  /// Toggle user active status
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
      });
      print('✅ User $userId status updated to: $isActive');
      return true;
    } catch (e) {
      print('❌ Error updating user status: $e');
      return false;
    }
  }
  
  /// Delete user (from Firestore only - Firebase Auth deletion requires re-authentication)
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('✅ User $userId deleted from Firestore');
      return true;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }
  
  /// Update user details
  Future<bool> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userId).update({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.toLowerCase(),
        'isActive': user.isActive,
      });
      print('✅ User ${user.userId} updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating user: $e');
      return false;
    }
  }
  
  /// Create new user (Firestore only - Firebase Auth user should be created separately)
  Future<bool> createUser(UserModel user, String password) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      
      // Create Firestore user document
      await _firestore.collection('users').doc(user.email).set({
        'userId': user.email,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.toLowerCase(),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ User ${user.email} created successfully');
      return true;
    } catch (e) {
      print('❌ Error creating user: $e');
      return false;
    }
  }
  
  /// Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      
      final stats = {
        'total': snapshot.docs.length,
        'students': 0,
        'teachers': 0,
        'parents': 0,
        'admins': 0,
        'active': 0,
        'inactive': 0,
      };
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final role = (data['role'] ?? '').toString().toLowerCase();
        final isActive = data['isActive'] ?? true;
        
        if (role == 'student') stats['students'] = (stats['students'] ?? 0) + 1;
        if (role == 'teacher') stats['teachers'] = (stats['teachers'] ?? 0) + 1;
        if (role == 'parent') stats['parents'] = (stats['parents'] ?? 0) + 1;
        if (role == 'admin') stats['admins'] = (stats['admins'] ?? 0) + 1;
        
        if (isActive) {
          stats['active'] = (stats['active'] ?? 0) + 1;
        } else {
          stats['inactive'] = (stats['inactive'] ?? 0) + 1;
        }
      }
      
      return stats;
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      return {
        'total': 0,
        'students': 0,
        'teachers': 0,
        'parents': 0,
        'admins': 0,
        'active': 0,
        'inactive': 0,
      };
    }
  }
}
