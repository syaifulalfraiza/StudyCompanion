import 'package:flutter/foundation.dart';
import 'package:studycompanion_app/models/announcement_model.dart';
import 'package:studycompanion_app/services/announcement_service.dart';
import 'package:studycompanion_app/services/firestore_student_service.dart';

class AnnouncementViewModel extends ChangeNotifier {
  List<AnnouncementModel> _announcements = [];
  final Set<String> _readAnnouncementIds = {};
  bool _isLoading = false;
  String? _error;
  bool _useFirestore = true; // Use Firestore by default
  
  final FirestoreStudentService _firestoreService = FirestoreStudentService();

  AnnouncementViewModel() {
    _initializeAnnouncements();
  }

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get announcementCount => _announcements.length;
  int get unreadCount =>
      _announcements.where((a) => !_readAnnouncementIds.contains(a.id)).length;

  /// Initialize announcements from service
  Future<void> _initializeAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> announcementMaps;
      
      // Use Firestore if enabled
      if (_useFirestore) {
        announcementMaps = await _firestoreService.getPublishedAnnouncements();
      } else {
        // Fallback to AnnouncementService
        final data = await AnnouncementService.getPublishedAnnouncements();
        _announcements = data;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Convert Firestore maps to AnnouncementModel
      _announcements = announcementMaps
          .map((map) => AnnouncementModel.fromJson(map))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load announcements: $e';
      print('Error loading announcements: $e');
      // Fallback to sample data
      try {
        final data = await AnnouncementService.getPublishedAnnouncements();
        _announcements = data;
      } catch (e2) {
        print('Fallback also failed: $e2');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh announcements
  Future<void> refreshAnnouncements() async {
    await _initializeAnnouncements();
  }

  /// Stream announcements for real-time updates
  Stream<List<AnnouncementModel>> streamAnnouncements() {
    return AnnouncementService.streamPublishedAnnouncements();
  }

  /// Get announcements sorted by date (newest first)
  List<AnnouncementModel> get sortedAnnouncements {
    final sorted = List<AnnouncementModel>.from(_announcements);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Get announcement by ID
  AnnouncementModel? getAnnouncementById(String id) {
    try {
      return _announcements.firstWhere((ann) => ann.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mark announcement as read (local only)
  void markAsRead(String announcementId) {
    if (_readAnnouncementIds.add(announcementId)) {
      notifyListeners();
    }
  }

  /// Check if announcement is read
  bool isRead(String announcementId) {
    return _readAnnouncementIds.contains(announcementId);
  }

  /// Get recent announcements (last 5)
  List<AnnouncementModel> get recentAnnouncements {
    final sorted = sortedAnnouncements;
    return sorted.take(5).toList();
  }

  /// Toggle between Firestore and fallback mode
  void setFirestoreMode(bool useFirestore) {
    if (_useFirestore != useFirestore) {
      _useFirestore = useFirestore;
      _initializeAnnouncements();
    }
  }

  /// Check if using Firestore
  bool get isUsingFirestore => _useFirestore;
}
