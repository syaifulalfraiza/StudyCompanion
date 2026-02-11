class UserSession {
  //thsis for user session management
  static String userId = "";
  static String name = "";
  static String role = "";
  static String email = "";
  static String phone = "";
  // Notification Settings
  static bool pushNotifications = true;
  static bool emailNotifications = true;
  static bool announcements = true;
  static bool reminders = true;

  static String profileImagePath = ""; // local image path (temporary)
  static int profileAvatarColor = 0xFF800000; // fallback avatar color

  /// Clear all user session data (logout)
  static void logout() {
    userId = "";
    name = "";
    role = "";
    email = "";
    phone = "";
    profileImagePath = "";
    profileAvatarColor = 0xFF800000;
  }

  /// Check if user is logged in
  static bool get isLoggedIn => userId.isNotEmpty;
}
