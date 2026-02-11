import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studycompanion_app/viewmodels/teacher_dashboard_viewmodel.dart';
import 'package:studycompanion_app/views/teacher_assignments_page.dart';
import 'package:studycompanion_app/views/teacher_announcements_page.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/views/admin/firestore_inspector_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  static const primary = Color(0xFF631018);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Public method for quick actions to call
  void switchTab(int index) {
    _onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeacherDashboardViewModel()
        ..initializeTeacher(UserSession.userId.isNotEmpty ? UserSession.userId : 't5'),
      child: Builder(
        builder: (context) {
          final pages = [
            const TeacherHomePage(),
            const TeacherAssignmentsPage(),
            const TeacherAnnouncementsPage(),
          ];
          return Scaffold(
            body: pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: primary,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tasks"),
                BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Announcements"),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  static const primary = Color(0xFF631018);

  void _switchToTab(BuildContext context, int tabIndex) {
    final dashboardState = context.findAncestorStateOfType<_TeacherDashboardState>();
    dashboardState?.switchTab(tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherDashboardViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final summary = viewModel.getDashboardSummary();
        final recentAssignments = viewModel.getRecentAssignments(limit: 5);

        return Scaffold(
          backgroundColor: const Color(0xFFFCF9F9),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 🔝 HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
                  decoration: const BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Welcome Back\n${viewModel.teacherName}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              // 🔍 Debug: Firestore Inspector Button
                              IconButton(
                                icon: const Icon(Icons.bug_report, color: Colors.white70),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FirestoreInspectorPage(),
                                    ),
                                  );
                                },
                                tooltip: 'Inspect Firestore Database',
                              ),
                              // 🔔 Notifications
                              IconButton(
                                icon: const Icon(Icons.notifications, color: Colors.white),
                                onPressed: () {},
                                tooltip: 'Notifications',
                              ),
                              // 🚪 Logout Button
                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white70),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text('Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            print('🚪 Logout button pressed');
                                            UserSession.logout();
                                            print('✅ User session cleared');
                                            Navigator.pop(context);
                                            print('📍 Closing logout dialog');
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/',
                                              (route) => false,
                                            );
                                            print('➡️ Navigating to login page');
                                          },
                                          child: const Text(
                                            'Logout',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        viewModel.teacherSubject,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 📊 DASHBOARD SUMMARY
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Classes',
                          '${summary['totalClasses'] ?? 0}',
                          Icons.class_,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Assignments',
                          '${summary['totalAssignments'] ?? 0}',
                          Icons.assignment,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Pending',
                          '${summary['pendingSubmissions'] ?? 0}',
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Overdue',
                          '${summary['overdueAssignments'] ?? 0}',
                          Icons.warning,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ⚡ QUICK ACTIONS
                _sectionTitle("Quick Actions"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      QuickAction(
                        icon: Icons.add_task,
                        label: "New Task",
                        onTap: () => _switchToTab(context, 1),
                      ),
                      QuickAction(
                        icon: Icons.assignment,
                        label: "View Tasks",
                        onTap: () => _switchToTab(context, 1),
                      ),
                      QuickAction(
                        icon: Icons.campaign,
                        label: "Announce",
                        onTap: () => _switchToTab(context, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 📚 RECENT ASSIGNMENTS
                _sectionTitle("Recent Assignments"),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: recentAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = recentAssignments[index];
                      return TaskCard(
                        assignment.title,
                        '${assignment.submittedCount}/${assignment.totalStudents} submitted',
                        assignment.submissionPercentage / 100,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// 🔹 QUICK ACTION
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const QuickAction({required this.icon, required this.label, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF631018)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// 🔹 TASK CARD
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  const TaskCard(this.title, this.subtitle, this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            color: const Color(0xFF631018),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
