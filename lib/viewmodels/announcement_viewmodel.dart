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
      List<Map<String, dynamic>> announcementMaps = [];
      
      // Use Firestore if enabled
      if (_useFirestore) {
        announcementMaps = await _firestoreService.getPublishedAnnouncements();
      }
      
      // If Firestore returned empty or error, try fallback service
      if (announcementMaps.isEmpty) {
        try {
          final data = await AnnouncementService.getPublishedAnnouncements();
          _announcements = data;
          _error = null;
          _isLoading = false;
          notifyListeners();
          return;
        } catch (fallbackError) {
          print('Fallback service also failed: $fallbackError');
        }
      }
      
      // Convert Firestore maps to AnnouncementModel if we have data
      if (announcementMaps.isNotEmpty) {
        _announcements = announcementMaps
            .map((map) => AnnouncementModel.fromJson(map))
            .toList();
      } else {
        // Use sample announcements if all else fails
        _announcements = _getSampleAnnouncements();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load announcements: $e';
      print('Error loading announcements: $e');
      // Use sample data as final fallback
      _announcements = _getSampleAnnouncements();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get sample announcements
  List<AnnouncementModel> _getSampleAnnouncements() {
    return [
      AnnouncementModel(
        id: 'ann1',
        title: 'School Assembly Tomorrow',
        message: 'Mandatory assembly for all students at 8:00 AM in the main auditorium.',
        createdBy: 'admin@school.edu.my',
        date: DateTime.now(),
      ),
      AnnouncementModel(
        id: 'ann2',
        title: 'New Library Hours',
        message: 'The library will now be open until 6 PM on weekdays and 4 PM on weekends.',
        createdBy: 'librarian@school.edu.my',
        date: DateTime.now().subtract(Duration(hours: 2)),
      ),
      AnnouncementModel(
        id: 'ann3',
        title: 'Sports Day Registration',
        message: 'Register for the upcoming sports day. Forms available at the sports office.',
        createdBy: 'coach@school.edu.my',
        date: DateTime.now().subtract(Duration(days: 1)),
      ),
      AnnouncementModel(
        id: 'ann4',
        title: 'Semester Exam Schedule',
        message: 'Exam schedule for next semester has been posted on the school portal.',
        createdBy: 'admin@school.edu.my',
        date: DateTime.now().subtract(Duration(days: 2)),
      ),
    ];
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
