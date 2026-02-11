import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility to inspect and debug Firestore database contents
/// Use this to check what data exists in your Firestore collections
class FirestoreDataInspector {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if Firestore database has any data
  static Future<Map<String, dynamic>> inspectDatabase() async {
    print('\n🔍 ===============================================');
    print('🔍 FIRESTORE DATABASE INSPECTION STARTED');
    print('🔍 ===============================================\n');

    Map<String, dynamic> report = {
      'timestamp': DateTime.now().toIso8601String(),
      'collections': <String, dynamic>{},
      'totalDocuments': 0,
      'isEmpty': true,
    };

    // List of collections to check
    final collections = [
      'users',
      'teachers',
      'students',
      'parents',
      'classes',
      'assignments',
      'grades',
      'announcements',
      'notifications',
    ];

    for (String collectionName in collections) {
      try {
        final snapshot = await _firestore.collection(collectionName).get();
        final docCount = snapshot.docs.length;
        
        print('📊 Collection: $collectionName');
        print('   Documents: $docCount');
        
        if (docCount > 0) {
          report['isEmpty'] = false;
          report['totalDocuments'] = (report['totalDocuments'] as int) + docCount;
          
          // Show first 3 document IDs as sample
          final sampleIds = snapshot.docs
              .take(3)
              .map((doc) => doc.id)
              .toList();
          print('   Sample IDs: ${sampleIds.join(", ")}');
          
          (report['collections'] as Map<String, dynamic>)[collectionName] = <String, dynamic>{
            'count': docCount,
            'sampleIds': sampleIds,
          };
        } else {
          print('   ❌ EMPTY');
          (report['collections'] as Map<String, dynamic>)[collectionName] = <String, dynamic>{'count': 0};
        }
        print('');
      } catch (e) {
        print('   ⚠️  Error reading collection: $e\n');
        (report['collections'] as Map<String, dynamic>)[collectionName] = <String, dynamic>{'error': e.toString()};
      }
    }

    print('🔍 ===============================================');
    print('📈 SUMMARY:');
    print('   Total Documents: ${report['totalDocuments']}');
    print('   Database Status: ${report['isEmpty'] ? '❌ EMPTY' : '✅ HAS DATA'}');
    print('🔍 ===============================================\n');

    return report;
  }

  /// Check specific collection in detail
  static Future<void> inspectCollection(String collectionName) async {
    print('\n🔍 Inspecting Collection: $collectionName\n');
    
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      
      if (snapshot.docs.isEmpty) {
        print('❌ Collection "$collectionName" is EMPTY\n');
        return;
      }

      print('✅ Found ${snapshot.docs.length} documents:\n');
      
      for (var doc in snapshot.docs) {
        print('📄 Document ID: ${doc.id}');
        print('   Data: ${doc.data()}');
        print('');
      }
    } catch (e) {
      print('❌ Error reading collection: $e\n');
    }
  }

  /// Check if specific teacher exists
  static Future<bool> checkTeacherExists(String teacherId) async {
    try {
      final doc = await _firestore.collection('teachers').doc(teacherId).get();
      
      if (doc.exists) {
        print('✅ Teacher $teacherId EXISTS');
        print('   Data: ${doc.data()}');
        return true;
      } else {
        print('❌ Teacher $teacherId NOT FOUND');
        return false;
      }
    } catch (e) {
      print('❌ Error checking teacher: $e');
      return false;
    }
  }

  /// Check if specific user exists
  static Future<bool> checkUserExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        print('✅ User $userId EXISTS');
        print('   Data: ${doc.data()}');
        return true;
      } else {
        print('❌ User $userId NOT FOUND');
        return false;
      }
    } catch (e) {
      print('❌ Error checking user: $e');
      return false;
    }
  }

  /// Count documents in each collection
  static Future<void> quickCount() async {
    print('\n📊 QUICK COUNT OF ALL COLLECTIONS\n');
    
    final collections = [
      'users', 'teachers', 'students', 'parents',
      'classes', 'assignments', 'grades',
      'announcements', 'notifications'
    ];

    int total = 0;
    
    for (String collection in collections) {
      try {
        final count = (await _firestore.collection(collection).get()).docs.length;
        total += count;
        
        String status = count > 0 ? '✅' : '❌';
        print('$status $collection: $count documents');
      } catch (e) {
        print('⚠️  $collection: Error - $e');
      }
    }
    
    print('\n📈 Total Documents: $total');
    print(total > 0 ? '✅ Database has data\n' : '❌ Database is EMPTY\n');
  }
}
