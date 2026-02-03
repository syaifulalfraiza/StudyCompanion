import 'package:flutter/material.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/views/edit_profile_page.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ParentHomePage(),
    ParentMessagesPage(),
    ParentCalendarPage(),
    ParentProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF800020),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Calendar",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Good Morning, ${UserSession.name} 👋",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Here’s your child’s learning overview today."),
            ),
            SizedBox(height: 20),
            DashboardCard(
              title: "Alex Johnson",
              subtitle: "Grade 5 • Section B",
              trailing: "GPA 3.8",
            ),
            SectionTitle("Today's Focus"),
            FocusCard(title: "Math Homework", subtitle: "Fractions Chapter"),
            SectionTitle("Performance"),
            DashboardCard(
              title: "Weekly Average",
              subtitle: "88%",
              trailing: "+2.4%",
            ),
            SectionTitle("Announcements"),
            DashboardCard(
              title: "Science Fair Update",
              subtitle: "Due next Friday",
              trailing: "",
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 💬 MESSAGES PAGE
////////////////////////////////////////////////////////////

class ParentMessagesPage extends StatelessWidget {
  const ParentMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Messages with Teachers",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 📅 CALENDAR PAGE
////////////////////////////////////////////////////////////

class ParentCalendarPage extends StatelessWidget {
  const ParentCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "School Calendar",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 👤 PROFILE PAGE
////////////////////////////////////////////////////////////

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 👤 Profile Info
          CircleAvatar(radius: 40, backgroundColor: Colors.grey),
          SizedBox(height: 10),

          Text(
            UserSession.name.isEmpty ? "Parent User" : UserSession.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Text(UserSession.email),
          Text(UserSession.phone), // ✅ show phone

          SizedBox(height: 30),

          // ⚙ Settings Options
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
              setState(() {}); // refresh after edit
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notification Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {},
          ),

          const Spacer(),

          // 🚪 LOGOUT BUTTON
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

  const DashboardCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle),
              ],
            ),
            Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
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
