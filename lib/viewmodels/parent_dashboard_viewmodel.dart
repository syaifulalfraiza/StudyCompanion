import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/models/child_model.dart';
import 'package:studycompanion_app/models/task_model.dart';
import 'package:studycompanion_app/services/firestore_parent_service.dart';
import 'package:studycompanion_app/services/parent_service.dart';
import 'package:studycompanion_app/services/task_service.dart';
import 'package:studycompanion_app/services/sample_child_data.dart';
import 'package:studycompanion_app/services/sample_parent_data.dart';
import 'package:studycompanion_app/services/sample_task_data.dart';

class ParentDashboardViewModel extends ChangeNotifier {
  // 👶 Children Management
  List<ChildModel> _children = [];
  ChildModel? _selectedChild;

  // 📊 State Flags
  bool _isLoading = false;
  String? _error;
  bool _useFirestore = true; // Toggle to use Firestore instead of sample data

  // 🔄 Subscriptions
  StreamSubscription<List<ChildModel>>? _childrenSubscription;

  // 📋 Tasks for selected child
  List<Task> _selectedChildTasks = [];

  // Parent ID
  final String _parentId;
  
  // Firestore service
  final FirestoreParentService _firestoreService = FirestoreParentService();

  ParentDashboardViewModel({String? parentId})
      : _parentId = (parentId != null && parentId.isNotEmpty)
            ? parentId
            : (UserSession.userId.isNotEmpty ? UserSession.userId : 'p1') {
    _initializeChildren();
    _subscribeToChildren();
  }

  // ============================================
  // 🔄 INITIALIZATION & SUBSCRIPTION
  // ============================================

  /// Initialize children from Firestore or sample data
  void _initializeChildren() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<ChildModel> children;
      
      // Use Firestore if enabled
      if (_useFirestore) {
        children = await _firestoreService.getChildrenForParent(_parentId);
      } else {
        children = await ParentService.getChildren(parentId: _parentId);
      }
      
      if (children.isNotEmpty) {
        _children = children;
        _selectedChild = _children.first;
        await _loadTasksForSelectedChild();
        _error = null;
      } else {
        _error = 'No children found';
        // Fallback to sample data
        _loadSampleChildren();
      }
    } catch (e) {
      print('Error initializing children: $e');
      _error = 'Failed to load children: $e';
      // Attempt to load sample data
      _loadSampleChildren();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Subscribe to real-time children updates
  void _subscribeToChildren() {
    _childrenSubscription?.cancel();
    
    // Use Firestore if enabled
    if (_useFirestore) {
      _childrenSubscription =
          _firestoreService.streamChildrenForParent(_parentId).listen(
        (children) {
          _handleChildrenUpdate(children);
        },
        onError: (error) {
          print('Error streaming children: $error');
          _error = 'Failed to stream children: $error';
          notifyListeners();
        },
      );
    } else {
      _childrenSubscription =
          ParentService.streamChildren(parentId: _parentId).listen(
        (children) {
          _handleChildrenUpdate(children);
        },
        onError: (error) {
          print('Error streaming children: $error');
          _error = 'Failed to stream children: $error';
          notifyListeners();
        },
      );
    }
  }
  
  /// Handle children update from stream
  void _handleChildrenUpdate(List<ChildModel> children) {
    if (children.isNotEmpty) {
      _children = children;
      // If no child was selected, select the first one
      if (_selectedChild == null) {
        _selectedChild = _children.first;
        _loadTasksForSelectedChild();
      } else {
        // Update the selected child if it's in the new list
        final updatedChild = _children.firstWhere(
          (c) => c.id == _selectedChild!.id,
          orElse: () => _children.first,
        );
        _selectedChild = updatedChild;
      }
      _error = null;
    }
    notifyListeners();
  }

  /// Load sample children (fallback for offline mode)
  void _loadSampleChildren() {
    _children = SampleChildData.getSampleChildrenForParent(_parentId);

    if (_children.isEmpty) {
      // If no children assigned to this parent, use first 2 from all sample children
      _children = SampleChildData.generateSampleChildren().take(2).toList();
    }

    if (_children.isNotEmpty) {
      _selectedChild = _children.first;
      _loadTasksForSelectedChild();
    }
  }

  // ============================================
  // 👶 CHILDREN MANAGEMENT
  // ============================================

  /// Select a child and load their tasks
  Future<void> selectChild(String childId) async {
    try {
      final child = _children.firstWhere(
        (c) => c.id == childId,
        orElse: () => throw Exception('Child not found'),
      );
      _selectedChild = child;
      await _loadTasksForSelectedChild();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to select child: $e';
      notifyListeners();
    }
  }

  /// Load tasks for selected child
  Future<void> _loadTasksForSelectedChild() async {
    if (_selectedChild == null) return;

    try {
      List<Task> tasks;
      
      // Use Firestore if enabled
      if (_useFirestore) {
        final taskMaps = await _firestoreService.getChildTasks(_selectedChild!.id);
        tasks = taskMaps.map((map) => Task.fromJson(map, map['id'] ?? '')).toList();
      } else {
        tasks = await TaskService.getStudentTasks(_selectedChild!.id);
      }
      
      _selectedChildTasks = tasks;
    } catch (e) {
      print('Error loading tasks for child: $e');
      _selectedChildTasks = SampleTaskData.getTasksForStudent(_selectedChild!.id);
    }
  }

  /// Refresh children list
  Future<void> refreshChildren() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<ChildModel> children;
      
      // Use Firestore if enabled
      if (_useFirestore) {
        children = await _firestoreService.getChildrenForParent(_parentId);
      } else {
        children = await ParentService.getChildren(parentId: _parentId);
      }
      
      _children = children;
      if (_selectedChild != null) {
        await _loadTasksForSelectedChild();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh children: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update child information
  Future<void> updateChild(
    String childId,
    Map<String, dynamic> updates,
  ) async {
    try {
      bool success;
      
      // Use Firestore if enabled
      if (_useFirestore) {
        success = await _firestoreService.updateChild(childId, updates);
      } else {
        await ParentService.updateChild(childId, updates);
        success = true;
      }
      
      if (success) {
        await refreshChildren();
        _error = null;
      } else {
        _error = 'Failed to update child';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update child: $e';
      notifyListeners();
    }
  }

  /// Update subject performance
  Future<void> updateSubjectPerformance(
    String childId,
    String subjectName,
    int score,
  ) async {
    try {
      bool success;
      
      // Use Firestore if enabled
      if (_useFirestore) {
        success = await _firestoreService.updateSubjectPerformance(
          childId: childId,
          subjectName: subjectName,
          score: score,
        );
      } else {
        await ParentService.updateSubjectPerformance(
          childId,
          subjectName,
          score,
        );
        success = true;
      }
      
      if (success) {
        await refreshChildren();
        _error = null;
      } else {
        _error = 'Failed to update subject performance';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update subject performance: $e';
      notifyListeners();
    }
  }

  // ============================================
  // 📊 GETTERS
  // ============================================

  List<ChildModel> get children => _children;
  ChildModel? get selectedChild => _selectedChild;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Task> get selectedChildTasks => _selectedChildTasks;

  /// Get completed tasks count for selected child
  int get completedTasksCount =>
      _selectedChildTasks.where((task) => task.isCompleted).length;

  /// Get total tasks count for selected child
  int get totalTasksCount => _selectedChildTasks.length;

  /// Get pending tasks count for selected child
  int get pendingTasksCount =>
      _selectedChildTasks.where((task) => !task.isCompleted).length;

  /// Get overall progress percentage for selected child
  int get selectedChildProgress {
    if (_selectedChildTasks.isEmpty) return 0;
    int completed = _selectedChildTasks.where((t) => t.isCompleted).length;
    return ((completed / _selectedChildTasks.length) * 100).toInt();
  }

  /// Check if any children exist
  bool get hasChildren => _children.isNotEmpty;

  /// Get children count
  int get childrenCount => _children.length;

  /// Get parent info by ID
  dynamic getParentInfo() {
    return SampleParentData.getFormattedParentInfo(_parentId);
  }

  /// Get parent name
  String getParentName() {
    final parent = SampleParentData.getSampleParentById(_parentId);
    return parent?.name ?? 'Parent';
  }

  /// Get parent email
  String getParentEmail() {
    final parent = SampleParentData.getSampleParentById(_parentId);
    return parent?.email ?? 'N/A';
  }

  /// Get parent phone
  String getParentPhone() {
    final parent = SampleParentData.getSampleParentById(_parentId);
    return parent?.phone ?? 'N/A';
  }

  /// Get parent address
  String getParentAddress() {
    final parent = SampleParentData.getSampleParentById(_parentId);
    return parent?.address ?? 'N/A';
  }

  /// Get parent occupation
  String getParentOccupation() {
    final parent = SampleParentData.getSampleParentById(_parentId);
    return parent?.occupation ?? 'Not specified';
  }

  /// Get emergency contact info
  Map<String, String> getEmergencyContact() {
    final parent = SampleParentData.getSampleParentById(_parentId);
    return {
      'name': parent?.emergencyContact ?? 'Not specified',
      'phone': parent?.emergencyPhone ?? 'Not specified',
    };
  }

  /// Get parent contact summary
  String getParentContactSummary() {
    return SampleParentData.getContactSummary(_parentId);
  }

  /// Check if parent has multiple children
  bool hasMultipleChildren() {
    return _children.length > 1;
  }

  // ============================================
  // 📋 SAMPLE DATA GENERATION (FALLBACK)
  // ============================================

  /// Generate sample tasks for offline mode
  List<Task> _generateSampleTasks() {
    if (_selectedChild == null) return [];
    return SampleTaskData.getTasksForStudent(_selectedChild!.id);
  }

  // ============================================
  // 🔥 FIRESTORE MODE CONTROL
  // ============================================

  /// Toggle between Firestore and fallback mode
  void setFirestoreMode(bool useFirestore) {
    if (_useFirestore != useFirestore) {
      _useFirestore = useFirestore;
      _subscribeToChildren();
      _initializeChildren();
    }
  }

  /// Check if using Firestore
  bool get isUsingFirestore => _useFirestore;

  // ============================================
  // 🧹 CLEANUP
  // ============================================

  @override
  void dispose() {
    _childrenSubscription?.cancel();
    super.dispose();
  }
}
