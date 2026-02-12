import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../viewmodels/classroom_viewmodel.dart';
import '../viewmodels/teacher_dashboard_viewmodel.dart';
import '../models/classroom_model.dart';
import '../core/user_session.dart';
import 'classroom_detail_page.dart';
import 'teacher_announcements_page.dart';
import 'teacher_assignments_page.dart';
import 'teacher_calendar_page.dart';
import 'edit_profile_page.dart';
import 'notification_settings_page.dart';
import 'admin/firestore_inspector_page.dart';

class NewTeacherDashboard extends StatefulWidget {
  const NewTeacherDashboard({super.key});

  @override
  State<NewTeacherDashboard> createState() => _NewTeacherDashboardState();
}

class _NewTeacherDashboardState extends State<NewTeacherDashboard> {
  static const primary = Color(0xFF800020);
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Dashboard - already on it
        break;
      case 1:
        // Classrooms - already on it, but could refresh
        break;
      case 2:
        // Calendar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TeacherCalendarPage()),
        );
        break;
      case 3:
        // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ClassroomViewModel();
        viewModel.loadClassrooms(UserSession.userId);
        return viewModel;
      },
      child: Consumer<ClassroomViewModel>(
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
                          "TEACHER DASHBOARD",
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
                  icon: const Icon(Icons.notifications, color: primary),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) {
                    if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                    } else if (value == 'settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
                      );
                    } else if (value == 'logout') {
                      _showLogoutConfirmation(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'profile',
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
                          Icon(Icons.settings, color: Colors.black87),
                          SizedBox(width: 12),
                          Text('Notification Settings'),
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
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddClassroomDialog(context, viewModel),
              backgroundColor: primary,
              tooltip: 'Add Classroom',
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => viewModel.loadClassrooms(UserSession.userId),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _buildDashboardContent(viewModel),
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.dashboard,
                        color: _selectedIndex == 0 ? primary : Colors.grey,
                      ),
                      onPressed: () => _onNavItemTapped(0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.class_,
                        color: _selectedIndex == 1 ? primary : Colors.grey,
                      ),
                      onPressed: () => _onNavItemTapped(1),
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month,
                        color: _selectedIndex == 2 ? primary : Colors.grey,
                      ),
                      onPressed: () => _onNavItemTapped(2),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person,
                        color: _selectedIndex == 3 ? primary : Colors.grey,
                      ),
                      onPressed: () => _onNavItemTapped(3),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(ClassroomViewModel viewModel) {
    if (viewModel.classrooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No classrooms yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first classroom',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadClassrooms(UserSession.userId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Greeting
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${UserSession.name.isEmpty ? 'Teacher' : UserSession.name.split(' ').first}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage your classrooms and track student progress",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📊 Teaching Overview Card
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
                          "Teaching Overview",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "This Semester",
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${viewModel.classrooms.length} ${viewModel.classrooms.length == 1 ? 'Classroom' : 'Classrooms'}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _enhancedStatPill(
                          "Total Classes",
                          "${viewModel.classrooms.length}",
                          Colors.white,
                        ),
                        _enhancedStatPill(
                          "Total Students",
                          "${viewModel.classrooms.fold<int>(0, (sum, c) => sum + c.studentCount)}",
                          Colors.white,
                        ),
                        _enhancedStatPill(
                          "Active",
                          "All",
                          Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ⚡ Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildActionCard(
                    context,
                    "Announcements",
                    Icons.campaign,
                    const Color(0xFF800020),
                    () {
                      final tempViewModel = TeacherDashboardViewModel();
                      tempViewModel.initializeTeacher(UserSession.userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: tempViewModel,
                            child: const TeacherAnnouncementsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    "Assignments",
                    Icons.assignment,
                    const Color(0xFF3D5AFE),
                    () {
                      final tempViewModel = TeacherDashboardViewModel();
                      tempViewModel.initializeTeacher(UserSession.userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: tempViewModel,
                            child: const TeacherAssignmentsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    "Calendar",
                    Icons.calendar_month,
                    const Color(0xFF00BFA5),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TeacherCalendarPage()),
                      );
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
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🎓 My Classrooms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "My Classrooms",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Classroom Cards
            ...viewModel.classrooms.map(
              (classroom) => _buildClassroomCard(context, classroom, viewModel),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getDisplayName() {
    final name = UserSession.name.trim();
    if (name.isEmpty) return 'Teacher';
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
                UserSession.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  Widget _buildClassroomCard(BuildContext context, ClassroomModel classroom, ClassroomViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: viewModel,
                    child: ClassroomDetailPage(classroom: classroom),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primary, primary.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.class_, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classroom.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Section ${classroom.section}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditClassroomDialog(context, viewModel, classroom);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, viewModel, classroom);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: Colors.black87),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.people, '${classroom.studentCount} Students', primary),
                      _buildInfoChip(Icons.calendar_today, classroom.semester, const Color(0xFF3D5AFE)),
                      _buildInfoChip(Icons.school, classroom.academicYear, const Color(0xFF00BFA5)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClassroomDialog(BuildContext context, ClassroomViewModel viewModel) {
    final nameController = TextEditingController();
    final sectionController = TextEditingController();
    final semesterController = TextEditingController(text: 'Semester 1');
    final academicYearController = TextEditingController(text: '2024/2025');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Classroom'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Classroom Name',
                  hintText: 'e.g., Form 5 Science',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  hintText: 'e.g., A, B, C',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: semesterController,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: academicYearController,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  border: OutlineInputBorder(),
                ),
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
            onPressed: () async {
              if (nameController.text.isEmpty || sectionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }

              Navigator.pop(context);

              final success = await viewModel.createClassroom(
                name: nameController.text,
                section: sectionController.text,
                teacherId: UserSession.userId,
                semester: semesterController.text,
                academicYear: academicYearController.text,
              );

              if (success != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Classroom created successfully')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditClassroomDialog(BuildContext context, ClassroomViewModel viewModel, ClassroomModel classroom) {
    final nameController = TextEditingController(text: classroom.name);
    final sectionController = TextEditingController(text: classroom.section);
    final semesterController = TextEditingController(text: classroom.semester);
    final academicYearController = TextEditingController(text: classroom.academicYear);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Classroom'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Classroom Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: semesterController,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: academicYearController,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  border: OutlineInputBorder(),
                ),
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
            onPressed: () async {
              Navigator.pop(context);

              final success = await viewModel.updateClassroom(
                classroomId: classroom.id,
                teacherId: UserSession.userId,
                name: nameController.text,
                section: sectionController.text,
                semester: semesterController.text,
                academicYear: academicYearController.text,
              );

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Classroom updated successfully')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClassroomViewModel viewModel, ClassroomModel classroom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Classroom'),
        content: Text('Are you sure you want to delete "${classroom.name}"?\n\nThis will also delete all subjects and tasks in this classroom.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await viewModel.deleteClassroom(
                classroom.id,
                UserSession.userId,
              );

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Classroom deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
