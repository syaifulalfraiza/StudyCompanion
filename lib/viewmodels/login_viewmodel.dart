import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studycompanion_app/views/student_dashboard.dart';
import 'package:studycompanion_app/views/new_teacher_dashboard.dart';
import 'package:studycompanion_app/views/parent_dashboard.dart';
import 'package:studycompanion_app/views/admin_dashboard.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/services/sample_teacher_data.dart';

/// A self-contained login screen widget that mirrors the provided HTML layout.
/// Place this file in `lib/viewmodels/login_viewmodel.dart` and use
/// `LoginViewModel()` as a normal Flutter page/widget.
class LoginViewModel extends StatefulWidget {
  const LoginViewModel({super.key});

  @override
  State<LoginViewModel> createState() => _LoginViewModelState();
}

class _LoginViewModelState extends State<LoginViewModel> {
  static const _primary = Color(0xFF800020);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final List<String> _roles = ['Student', 'Parent', 'Teacher', 'Admin'];
  int _selectedRoleIndex = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Try to authenticate with sample data (for testing/demo purposes)
  Future<bool> _trySampleDataLogin(
    String email,
    String password,
    String selectedRole,
  ) async {
    // Only support teacher sample data for now
    if (selectedRole != 'teacher') {
      return false;
    }

    // Check if email matches any sample teacher
    final allTeachers = SampleTeacherData.getAllTeachers();
    final matchedTeacher = allTeachers.firstWhere(
      (t) => t['email'] == email,
      orElse: () => {},
    );

    if (matchedTeacher.isEmpty) {
      return false; // Email not found in sample data
    }

    // Check password (for demo purposes, use 'password123')
    if (password != 'password123') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid password. Use "password123" for demo accounts.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return true; // Handled, but invalid
    }

    // Successful sample data login
    if (mounted) {
      // Store user session
      UserSession.userId = matchedTeacher['id'] as String;
      UserSession.name = matchedTeacher['name'] as String;
      UserSession.email = matchedTeacher['email'] as String;
      UserSession.role = 'teacher';
      UserSession.phone = matchedTeacher['phone'] as String? ?? '';

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${matchedTeacher['name']}!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to teacher dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NewTeacherDashboard(),
        ),
      );
    }

    return true; // Successfully handled
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF221012)
          : const Color(0xFFF8F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                            BoxShadow(
                              color: _primary.withAlpha((0.25 * 255).round()),
                              blurRadius: 12,
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Study Companion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1B0D0F),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.help_outline,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      // Welcome
                      Column(
                        children: [
                          Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1B0D0F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please select your role and sign in to continue your learning journey.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Role selector (segmented)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: isDark
                              ? Colors.white10
                              : Colors.grey.shade200.withAlpha((0.6 * 255).round()),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: List.generate(_roles.length, (i) {
                            final selected = i == _selectedRoleIndex;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedRoleIndex = i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? (isDark ? _primary : Colors.white)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                        color: isDark
                          ? _primary.withAlpha((0.25 * 255).round())
                          : Colors.black12,
                                              blurRadius: 6,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _roles[i],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? (isDark ? Colors.white : _primary)
                                          : (isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[700]),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Form
                      Form(
                        child: Column(
                          children: [
                            // Email
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 4.0,
                                  bottom: 6,
                                ),
                                child: Text(
                                  'Email or Username',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.grey,
                                ),
                                hintText: 'Enter your email or ID',
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white10
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: _primary),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // Password
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 4.0,
                                  bottom: 6,
                                ),
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey,
                                ),
                                hintText: 'Enter your password',
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white10
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: _primary),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                            ),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 6.0,
                                  right: 2.0,
                                ),
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Sign In button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 8,
                                ),
                                onPressed: () async {
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text;

                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Email and password are required.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final selectedRole =
                                      _roles[_selectedRoleIndex].toLowerCase();

                                  // Try sample data authentication first if teacher role selected (for testing purposes)
                                  if (selectedRole == 'teacher') {
                                    final sampleLoginSuccess = await _trySampleDataLogin(
                                      email,
                                      password,
                                      selectedRole,
                                    );
                                    if (sampleLoginSuccess) return;
                                  }

                                  // Fall back to Firebase authentication
                                  try {
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                          email: email,
                                          password: password,
                                        );

                                    final userSnapshot = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .where('email', isEqualTo: email)
                                        .limit(1)
                                        .get();

                                    if (userSnapshot.docs.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'User record not found in Firestore.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final userDoc = userSnapshot.docs.first;
                                    final data = userDoc.data();
                                    final role = (data['role'] ?? '')
                                        .toString()
                                        .toLowerCase();

                                    if (role.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'User role is missing in Firestore.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (selectedRole != role) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Selected role does not match this user. Expected: $role.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // ✅ STORE USER GLOBALLY
                                    UserSession.userId = data['userId'] ?? userDoc.id;
                                    UserSession.name = (data['name'] ?? email)
                                        .toString();
                                    UserSession.email = email;
                                    UserSession.role = role;
                                    UserSession.phone = (data['phone'] ?? '')
                                        .toString();

                                    Widget destinationScreen;

                                    switch (role) {
                                      case 'student':
                                        destinationScreen =
                                            const StudentDashboard();
                                        break;

                                      case 'teacher':
                                        destinationScreen =
                                            const NewTeacherDashboard();
                                        break;

                                      case 'parent':
                                        destinationScreen =
                                            const ParentDashboard();
                                        break;

                                      case 'admin':
                                        destinationScreen =
                                            const AdminDashboard();
                                        break;

                                      default:
                                        destinationScreen =
                                            const StudentDashboard();
                                    }
                                    if (!mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => destinationScreen,
                                      ),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    final message = switch (e.code) {
                                      'user-not-found' =>
                                        'No user found for that email.',
                                      'wrong-password' => 'Incorrect password.',
                                      'invalid-email' =>
                                        'Invalid email address.',
                                      _ => 'Login failed: ${e.message}',
                                    };
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Login failed: $e'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
