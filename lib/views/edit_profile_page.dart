import 'package:flutter/material.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: UserSession.name);
    _emailController = TextEditingController(text: UserSession.email);
    _phoneController.text = UserSession.phone;
  }

  Future<void> _pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (pickedFile != null) {
        setState(() {
          UserSession.profileImagePath = pickedFile.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open gallery.')),
      );
    }
  }

  void _showAvatarColorPicker() {
    final colors = <int>[
      0xFF800000,
      0xFF1E88E5,
      0xFF43A047,
      0xFFF4511E,
      0xFF6D4C41,
      0xFF8E24AA,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Avatar Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  UserSession.profileAvatarColor = color;
                  UserSession.profileImagePath = '';
                });
                Navigator.pop(context);
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(color),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickProfileImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Choose Avatar Color'),
              onTap: () {
                Navigator.pop(context);
                _showAvatarColorPicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _removeProfileImage() {
    setState(() {
      UserSession.profileImagePath = '';
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _saveProfile() {
    // 🔥 Temporary local session save (later DB)
    UserSession.name = _nameController.text;
    UserSession.email = _emailController.text;
    UserSession.phone = _phoneController.text;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated")));

    // Return to previous screen and let it refresh
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(UserSession.profileAvatarColor),
                    backgroundImage: UserSession.profileImagePath.isNotEmpty
                        ? FileImage(File(UserSession.profileImagePath))
                        : null,
                    child: UserSession.profileImagePath.isEmpty
                        ? Text(
                            _getInitials(UserSession.name),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.transparent,
                            ),
                          )
                        : null,
                  ),
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
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
              const SizedBox(height: 8),
              TextButton(
                onPressed: UserSession.profileImagePath.isEmpty
                    ? null
                    : _removeProfileImage,
                child: const Text('Remove Photo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
