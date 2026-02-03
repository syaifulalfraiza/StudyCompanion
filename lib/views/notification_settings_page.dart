import 'package:flutter/material.dart';
import 'package:studycompanion_app/core/user_session.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool announcements = true;
  bool reminders = true;

  @override
  void initState() {
    super.initState();

    // Later load from DB
    pushNotifications = UserSession.pushNotifications;
    emailNotifications = UserSession.emailNotifications;
    announcements = UserSession.announcements;
    reminders = UserSession.reminders;
  }

  void _saveSettings() {
    UserSession.pushNotifications = pushNotifications;
    UserSession.emailNotifications = emailNotifications;
    UserSession.announcements = announcements;
    UserSession.reminders = reminders;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification settings saved")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "General",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive alerts on your device"),
            value: pushNotifications,
            onChanged: (value) => setState(() => pushNotifications = value),
          ),

          SwitchListTile(
            title: const Text("Email Notifications"),
            subtitle: const Text("Receive updates via email"),
            value: emailNotifications,
            onChanged: (value) => setState(() => emailNotifications = value),
          ),

          const Divider(height: 40),

          const Text(
            "School Updates",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SwitchListTile(
            title: const Text("Announcements"),
            value: announcements,
            onChanged: (value) => setState(() => announcements = value),
          ),

          SwitchListTile(
            title: const Text("Reminders"),
            subtitle: const Text("Homework, events, deadlines"),
            value: reminders,
            onChanged: (value) => setState(() => reminders = value),
          ),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text("Save Settings"),
          ),
        ],
      ),
    );
  }
}
