import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin/admin_course_list_screen.dart';
import 'core/services/auth_service.dart';
import 'firebase_options.dart';
import 'shared/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnHub Admin',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: StreamBuilder<User?>(
        stream: AuthService().authChanges,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = snap.data;
          if (user == null) return const LoginScreen(title: 'LearnHub Admin');
          return _AdminGate(user: user);
        },
      ),
    );
  }
}

class _AdminGate extends StatefulWidget {
  final User user;
  const _AdminGate({required this.user});

  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  late final Future<bool> _isAdmin = AuthService().isAdmin(widget.user);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data != true) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('This account does not have admin access.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: AuthService().signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          );
        }
        return const AdminCourseListScreen();
      },
    );
  }
}
