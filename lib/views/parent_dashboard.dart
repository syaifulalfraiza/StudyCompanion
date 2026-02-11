import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/views/edit_profile_page.dart';
import 'package:studycompanion_app/views/notification_settings_page.dart';
import 'package:studycompanion_app/views/change_password_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:studycompanion_app/viewmodels/parent_dashboard_viewmodel.dart';
import 'package:studycompanion_app/viewmodels/notification_viewmodel.dart';
import 'package:studycompanion_app/viewmodels/announcement_viewmodel.dart';
import 'package:studycompanion_app/services/parent_calendar_service.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ParentDashboardViewModel(parentId: UserSession.userId),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationViewModel(
            userId: UserSession.userId,
            isStudent: false,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AnnouncementViewModel(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final pages = [
            const ParentHomePage(),
            Center(
              child: Consumer<NotificationViewModel>(
                builder: (context, notificationVM, _) =>
                    ParentNotificationsPage(viewModel: notificationVM),
              ),
            ),
            const ParentCalendarPage(),
            const ParentProfilePage(),
          ];
          return Scaffold(
            body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF800020),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Calendar",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🏠 HOME PAGE (Parent Dashboard Main Screen)
////////////////////////////////////////////////////////////

class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentDashboardViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Row(
              children: [
                _buildProfileAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, ${_getDisplayName()}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "PARENT DASHBOARD",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xFF800020)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ParentNotificationsPage(
                        viewModel: context.read<NotificationViewModel>(),
                      ),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black87),
                onSelected: (value) {
                  if (value == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsPage(),
                      ),
                    );
                  } else if (value == 'edit_profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  } else if (value == 'change_password') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  } else if (value == 'logout') {
                    _showLogoutConfirmation(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'edit_profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.black87),
                        SizedBox(width: 12),
                        Text('Edit Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.black87),
                        SizedBox(width: 12),
                        Text('Notification Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'change_password',
                    child: Row(
                      children: [
                        Icon(Icons.lock, color: Colors.black87),
                        SizedBox(width: 12),
                        Text('Change Password'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: _buildHomePageContent(viewModel, context),
          ),
        );
      },
    );
  }

  Widget _buildHomePageContent(
    ParentDashboardViewModel viewModel,
    BuildContext context,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!viewModel.hasChildren) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              viewModel.error ?? "No children found",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 👋 Greeting with enhanced styling
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${UserSession.name.isEmpty ? 'Parent' : UserSession.name.split(' ').first} 👋",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's your family's learning summary",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 📊 FAMILY OVERVIEW - Enhanced with better visual design
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF800020), Color(0xFF5C0000)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF800020).withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Family Overview",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "This Month",
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    viewModel.selectedChild != null
                        ? "${viewModel.selectedChild!.name}'s Progress"
                        : "Select a child to view progress",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress indicator
                  if (viewModel.selectedChild != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (viewModel.selectedChildProgress / 100).clamp(0, 1),
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Stats pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _enhancedStatPill(
                        "Grade",
                        viewModel.selectedChild?.grade ?? "-",
                        Colors.white,
                      ),
                      _enhancedStatPill(
                        "GPA",
                        viewModel.selectedChild != null
                            ? viewModel.selectedChild!.gpa.toStringAsFixed(2)
                            : "-",
                        Colors.white,
                      ),
                      _enhancedStatPill(
                        "Progress",
                        "${viewModel.selectedChildProgress}%",
                        Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// ⚡ QUICK ACTIONS - Enhanced styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildActionCard(
                  context,
                  "Notifications",
                  Icons.notifications_active,
                  const Color(0xFF800020),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ParentNotificationsPage(
                          viewModel: context.read<NotificationViewModel>(),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  "Calendar",
                  Icons.calendar_month,
                  const Color(0xFF3D5AFE),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentCalendarPage(),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  "Messages",
                  Icons.message,
                  const Color(0xFF00BFA5),
                  () {
                    // TODO: Navigate to messages
                  },
                ),
                _buildActionCard(
                  context,
                  "Profile",
                  Icons.person,
                  const Color(0xFFFF6F00),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 🎓 CHILDREN LIST - Enhanced cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Children",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          ...viewModel.children.map(
            (child) => GestureDetector(
              onTap: () {
                viewModel.selectChild(child.id);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: viewModel.selectedChild?.id == child.id
                        ? const Color(0xFF800020).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: viewModel.selectedChild?.id == child.id
                          ? const Color(0xFF800020)
                          : Colors.grey.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF800020), Color(0xFF5C0000)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            child.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Grade ${child.grade}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            child.gpa.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF800020),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "GPA",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// 📚 TODAY'S FOCUS - Enhanced styling
          if (viewModel.selectedChild != null) ...
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Focus",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              _buildFocusCard(
                "📚 Homework",
                viewModel.selectedChild!.homework,
                Colors.blue,
              ),
              _buildFocusCard(
                "📝 Quiz",
                viewModel.selectedChild!.quiz,
                Colors.orange,
              ),
              _buildFocusCard(
                "📌 Reminder",
                viewModel.selectedChild!.reminder,
                Colors.green,
              ),
              const SizedBox(height: 24),
            ]
          else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Select a child to see today's learning focus",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            )
          ],

          const SizedBox(height: 20),

          /// 📌 CHILD'S TASKS
          if (viewModel.selectedChild != null) ...[
            const SectionTitle("Child's Tasks"),
            if (viewModel.selectedChildTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("No tasks assigned"),
              )
            else
              Column(
                children: viewModel.selectedChildTasks.take(3).map((task) {
                  return DashboardCard(
                    title: task.title,
                    subtitle: task.subject,
                    trailing: task.dueDate,
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
          ],

          /// 📊 PERFORMANCE
          const SectionTitle("Performance"),
          if (viewModel.selectedChild == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Select a child to view performance"),
            )
          else
            DashboardCard(
              title: "Completion Rate",
              subtitle: "${viewModel.selectedChildProgress}%",
              trailing:
                  "${viewModel.completedTasksCount}/${viewModel.totalTasksCount}",
            ),

          const SizedBox(height: 20),

          /// 📢 ANNOUNCEMENTS
          const SectionTitle("Announcements"),
          Consumer<AnnouncementViewModel>(
            builder: (context, announcementVM, _) {
              if (announcementVM.announcements.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No announcements"),
                );
              }
              return Column(
                children: announcementVM.announcements.take(2).map((announcement) {
                  return DashboardCard(
                    title: announcement.title,
                    subtitle: announcement.content,
                    trailing: announcement.formattedDate,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnnouncementDetailPage(
                            title: announcement.title,
                            content: announcement.content,
                            date: announcement.formattedDate,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getDisplayName() {
    final name = UserSession.name.trim();
    if (name.isEmpty) return 'Parent';
    return name.split(RegExp(r'\s+')).take(2).join(' ');
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: UserSession.profileImagePath.isNotEmpty
          ? FileImage(File(UserSession.profileImagePath))
          : null,
      child: UserSession.profileImagePath.isEmpty
          ? const Icon(Icons.person, size: 18, color: Colors.white)
          : null,
    );
  }

  Widget _statPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced stat pill with better styling
  Widget _enhancedStatPill(String label, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced action card
  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 36),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build enhanced focus card
  Widget _buildFocusCard(String title, String subtitle, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: accentColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Clear user session
                UserSession.logout();

                // Navigate back to login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// � NOTIFICATIONS PAGE
////////////////////////////////////////////////////////////

class ParentNotificationsPage extends StatelessWidget {
  final NotificationViewModel viewModel;

  const ParentNotificationsPage({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF800020),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _buildNotificationBody(context, viewModel),
    );
  }

  Widget _buildNotificationBody(BuildContext context, NotificationViewModel notificationVM) {
    if (notificationVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notificationVM.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No notifications",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notificationVM.notifications.length,
      itemBuilder: (context, index) {
        final notification = notificationVM.notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: notification.isRead
                  ? Colors.grey[300]
                  : const Color(0xFF800020),
              child: Icon(
                _getNotificationIcon(notification.notificationType),
                color: notification.isRead ? Colors.grey : Colors.white,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead
                    ? FontWeight.normal
                    : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notification.body),
                const SizedBox(height: 4),
                Text(
                  notification.formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () async {
              await notificationVM.markAsRead(notification.id);
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(notification.title),
                  content: Text(notification.body),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return Icons.warning;
      case 'reminder':
        return Icons.alarm;
      case 'update':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}

////////////////////////////////////////////////////////////
/// 📅 CALENDAR PAGE
////////////////////////////////////////////////////////////

class ParentCalendarPage extends StatefulWidget {
  const ParentCalendarPage({super.key});

  @override
  State<ParentCalendarPage> createState() => _ParentCalendarPageState();
}

class _ParentCalendarPageState extends State<ParentCalendarPage> {
  static const primary = Color(0xFF800020);
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // Calendar events from Firestore
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  final bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ParentCalendarService.streamParentEvents(
        parentId: UserSession.userId,
      ),
      builder: (context, snapshot) {
        // Handle loading and errors
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: primary,
              elevation: 0,
              title: const Text(
                'Calendar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            appBar: AppBar(
              backgroundColor: primary,
              elevation: 0,
              title: const Text(
                'Calendar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // Convert flat event list to date-indexed map
        _events = _convertEventsToMap(snapshot.data ?? []);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: primary,
            elevation: 0,
            title: const Text(
              'Calendar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _focusedMonth = DateTime.now();
                  });
                },
              ),
            ],
          ),
          body: Column(
        children: [
          // Calendar Header with Month Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      _formatMonthYear(_focusedMonth),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCalendarGrid(),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateFull(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getEventCountText(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _showAddOrEditEventDialog(date: _selectedDate);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._getEventsForDate(_selectedDate).map((event) {
                  return _buildEventCard(event);
                }),
                if (_getEventsForDate(_selectedDate).isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events scheduled',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  /// Convert flat events list to date-indexed map
  Map<DateTime, List<Map<String, dynamic>>> _convertEventsToMap(
    List<Map<String, dynamic>> flatEvents,
  ) {
    final eventsMap = <DateTime, List<Map<String, dynamic>>>{};

    for (final event in flatEvents) {
      final eventDate = event['date'] as DateTime;
      final normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);

      if (!eventsMap.containsKey(normalizedDate)) {
        eventsMap[normalizedDate] = [];
      }
      eventsMap[normalizedDate]!.add(event);
    }

    return eventsMap;
  }

  /// Build calendar grid with dates
  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayNumber = index - startingWeekday + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox();
            }

            final date =
                DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());
            final hasEvents = _events
              .containsKey(DateTime(date.year, date.month, date.day));

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? Colors.white24
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected ? primary : Colors.white,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasEvents)
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? primary : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build event card
  Widget _buildEventCard(Map<String, dynamic> event) {
    final eventType = event['type'] as String;
    final eventStyle = _getEventStyle(eventType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEventDetails(event, _selectedDate),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: eventStyle.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(eventStyle.icon, color: eventStyle.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _convertTimeToString(event['time']),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (event['childName'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Child: ${event['childName']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show event details in dialog
  void _showEventDetails(Map<String, dynamic> event, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(_getIconForEventType(event['type'])),
              const SizedBox(width: 8),
              Expanded(child: Text(event['title'])),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow('Time:', _convertTimeToString(event['time'])),
                _buildDetailRow('Type:', event['type']),
                if (event['childName'] != null)
                  _buildDetailRow('Student:', event['childName']),
                const SizedBox(height: 12),
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  event['description'] ?? 'No description',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddOrEditEventDialog(date: date, event: event);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _deleteEvent(date, event['id']);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Build detail row for dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Get events for selected date
  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _events[normalizedDate] ?? [];
  }

  /// Get event count text
  String _getEventCountText() {
    final count = _getEventsForDate(_selectedDate).length;
    return count == 0
        ? 'No events'
        : count == 1
            ? '1 event'
            : '$count events';
  }

  /// Check if two dates are the same
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Convert time field to String (handles both Timestamp and String types)
  String _convertTimeToString(dynamic timeValue) {
    if (timeValue == null) return '';
    if (timeValue is String) return timeValue;
    if (timeValue is Timestamp) {
      final dateTime = timeValue.toDate();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return timeValue.toString();
  }

  /// Format date as "Monday, February 15"
  String _formatDateFull(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }

  /// Format date as "February 2026"
  String _formatMonthYear(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Pick an initial date that has events, if available
  DateTime _getInitialSelectedDate() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final eventDates = _events.keys
        .where((date) => date.year == todayNormalized.year && date.month == todayNormalized.month)
        .toList();

    if (eventDates.isEmpty) return todayNormalized;

    eventDates.sort();
    final nextDate = eventDates.firstWhere(
      (date) => !date.isBefore(todayNormalized),
      orElse: () => eventDates.first,
    );
    return nextDate;
  }

  /// Get color for event type
  int _getColorForEventType(String eventType) {
    switch (eventType) {
      case 'examination':
        return 0xFFD32F2F; // Red
      case 'deadline':
        return 0xFFF57C00; // Orange
      case 'parent_teaching':
        return 0xFF0288D1; // Blue
      case 'school_event':
        return 0xFF388E3C; // Green
      case 'holiday':
        return 0xFF7B1FA2; // Purple
      case 'reminder':
        return 0xFFFFB300; // Amber
      default:
        return 0xFF757575; // Grey
    }
  }

  /// Get icon for event type
  String _getIconForEventType(String eventType) {
    switch (eventType) {
      case 'examination':
        return '📝';
      case 'deadline':
        return '⏰';
      case 'parent_teaching':
        return '👨‍🏫';
      case 'school_event':
        return '🎓';
      case 'holiday':
        return '🎉';
      case 'reminder':
        return '⚠️';
      default:
        return '📌';
    }
  }

  void _showAddOrEditEventDialog({
    required DateTime date,
    Map<String, dynamic>? event,
  }) {
    final titleController = TextEditingController(text: event?['title'] ?? '');
    final timeController = TextEditingController(text: _convertTimeToString(event?['time']));
    final descriptionController =
        TextEditingController(text: event?['description'] ?? '');
    String selectedType = event?['type'] ?? 'school_event';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Add Event' : 'Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: const [
                  DropdownMenuItem(value: 'school_event', child: Text('School Event')),
                  DropdownMenuItem(value: 'examination', child: Text('Examination')),
                  DropdownMenuItem(value: 'deadline', child: Text('Deadline')),
                  DropdownMenuItem(value: 'parent_teaching', child: Text('Parent-Teacher')),
                  DropdownMenuItem(value: 'holiday', child: Text('Holiday')),
                  DropdownMenuItem(value: 'reminder', child: Text('Reminder')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final time = timeController.text.trim();
              if (title.isEmpty || time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in title and time.')),
                );
                return;
              }
              final eventData = {
                'id': event?['id'] ??
                    DateTime.now().microsecondsSinceEpoch.toString(),
                'title': title,
                'time': time,
                'type': selectedType,
                'description': descriptionController.text.trim(),
                'childName': event?['childName'],
              };
              if (event == null) {
                _addEvent(date, eventData);
              } else {
                _updateEvent(date, eventData);
              }
              Navigator.pop(context);
            },
            child: Text(event == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _addEvent(DateTime date, Map<String, dynamic> event) {
    // Save to Firestore
    ParentCalendarService.createEvent(
      parentId: UserSession.userId,
      title: event['title'] ?? '',
      time: event['time'] ?? '',
      type: event['type'] ?? 'school_event',
      date: date,
      description: event['description'],
      childName: event['childName'],
    ).then((_) {
      _showSuccessMessage('Event added successfully');
    }).catchError((error) {
      _showErrorMessage('Failed to add event: $error');
    });
  }

  void _updateEvent(DateTime date, Map<String, dynamic> updatedEvent) {
    // Update in Firestore
    ParentCalendarService.updateEvent(
      eventId: updatedEvent['id'] ?? '',
      title: updatedEvent['title'] ?? '',
      time: updatedEvent['time'] ?? '',
      type: updatedEvent['type'] ?? 'school_event',
      date: date,
      description: updatedEvent['description'],
      childName: updatedEvent['childName'],
    ).then((_) {
      _showSuccessMessage('Event updated successfully');
    }).catchError((error) {
      _showErrorMessage('Failed to update event: $error');
    });
  }

  void _deleteEvent(DateTime date, String id) {
    // Delete from Firestore
    ParentCalendarService.deleteEvent(id).then((_) {
      _showSuccessMessage('Event deleted successfully');
    }).catchError((error) {
      _showErrorMessage('Failed to delete event: $error');
    });
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  _EventStyle _getEventStyle(String eventType) {
    switch (eventType) {
      case 'examination':
        return _EventStyle(color: Colors.red, icon: Icons.quiz);
      case 'deadline':
        return _EventStyle(color: Colors.orange, icon: Icons.assignment_late);
      case 'parent_teaching':
        return _EventStyle(color: Colors.blue, icon: Icons.people);
      case 'school_event':
        return _EventStyle(color: Colors.green, icon: Icons.event);
      case 'holiday':
        return _EventStyle(color: Colors.purple, icon: Icons.celebration);
      case 'reminder':
        return _EventStyle(color: Colors.amber, icon: Icons.notifications);
      default:
        return _EventStyle(color: Colors.grey, icon: Icons.circle);
    }
  }
}

class _EventStyle {
  final Color color;
  final IconData icon;

  const _EventStyle({
    required this.color,
    required this.icon,
  });
}

/// NOTE: _generateSampleCalendarEvents() is no longer used.
/// Real calendar data is fetched from Firestore via ParentCalendarService
/*
/// Generate sample calendar events
Map<DateTime, List<Map<String, dynamic>>> _generateSampleCalendarEvents() {
  return {
    // February 2026 Events
    DateTime(2026, 2, 10): [
      {
        'id': 'e1',
        'title': 'Mathematics Quiz - Form 1A',
        'time': '10:00 AM',
        'type': 'examination',
        'description': 'Form 1A Mathematics quiz covering algebra and geometry',
        'childName': 'Amir Abdullah',
      },
    ],
    DateTime(2026, 2, 12): [
      {
        'id': 'e3',
        'title': 'Mathematics Competition Registration Closes',
        'time': '5:00 PM',
        'type': 'reminder',
        'description': 'Last day to register for National Mathematics Competition',
        'childName': null,
      },
    ],
    DateTime(2026, 2, 15): [
      {
        'id': 'e5',
        'title': 'School Sports Day',
        'time': 'All Day',
        'type': 'school_event',
        'description': 'Annual Sports Day at school field. All students must participate.',
        'childName': 'All Students',
      },
    ],
    DateTime(2026, 2, 20): [
      {
        'id': 'e8',
        'title': 'Parent-Teacher Meeting',
        'time': '2:00 PM - 5:00 PM',
        'type': 'parent_teaching',
        'description': 'Annual Parent-Teacher Meeting. Discuss academic progress with teachers.',
        'childName': 'All Students',
      },
    ],

    // March 2026 Events
    DateTime(2026, 3, 1): [
      {
        'id': 'e10',
        'title': 'Mid-Year Examinations Begin',
        'time': '8:00 AM',
        'type': 'examination',
        'description': 'Mid-Year Examination period starts for Form 1-3 (Dates: March 1-20)',
        'childName': 'All Students',
      },
    ],
    DateTime(2026, 3, 5): [
      {
        'id': 'e11',
        'title': 'Mathematics Exam - Form 1',
        'time': '9:00 AM - 11:00 AM',
        'type': 'examination',
        'description': 'Mathematics Paper 1 (2 hours) - Form 1 students',
        'childName': 'Form 1 Students',
      },
    ],
    DateTime(2026, 3, 20): [
      {
        'id': 'e15',
        'title': 'Mid-Year Examinations End',
        'time': '11:00 AM',
        'type': 'examination',
        'description': 'Last day of Mid-Year Examination period',
        'childName': 'All Students',
      },
    ],
  };
}
*/

////////////////////////////////////////////////////////////
/// 👤 PROFILE PAGE
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/// 👤 PROFILE PAGE
////////////////////////////////////////////////////////////

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  /// 📸 Pick image from gallery
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        UserSession.profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ FIXED OVERFLOW HERE
          child: Column(
            children: [
            const SizedBox(height: 20),

            /// 👤 PROFILE IMAGE WITH CAMERA ICON
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: UserSession.profileImagePath.isNotEmpty
                      ? FileImage(File(UserSession.profileImagePath))
                      : null,
                  child: UserSession.profileImagePath.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),

                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              UserSession.name.isEmpty ? "Parent User" : UserSession.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Text(UserSession.email),
            Text(UserSession.phone),

            const SizedBox(height: 30),

            /// ⚙ SETTINGS OPTIONS
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile"),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                setState(() {});
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notification Settings"),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),

            const SizedBox(height: 40),

            /// 🚪 LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                onPressed: () {
                  UserSession.name = "";
                  UserSession.email = "";
                  UserSession.role = "";
                  UserSession.phone = "";
                  UserSession.profileImagePath = "";

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔹 REUSABLE WIDGETS
////////////////////////////////////////////////////////////

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;

  const DashboardCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(
                    trailing,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnnouncementDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const AnnouncementDetailPage({
    required this.title,
    required this.content,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(content),
            ],
          ),
        ),
      ),
    );
  }
}

class FocusCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const FocusCard({required this.title, required this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ParentActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ParentActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
