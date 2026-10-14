import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin/admin_course_list_screen.dart';
import 'core/services/auth_service.dart';
import 'firebase_options.dart';
import 'shared/login_screen.dart';
import 'user/course_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LearnHubApp());
}

class LearnHubApp extends StatelessWidget {
  const LearnHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnHub',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: StreamBuilder<User?>(
        stream: AuthService().authChanges,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = snap.data;
          if (user == null) {
            return const LoginScreen(title: 'Welcome to LearnHub', allowSignUp: true);
          }
          return _RoleHome(user: user);
        },
      ),
    );
  }
}

/// Learners see the course list. Admins also get a "Manage" tab.
class _RoleHome extends StatefulWidget {
  final User user;
  const _RoleHome({required this.user});

  @override
  State<_RoleHome> createState() => _RoleHomeState();
}

class _RoleHomeState extends State<_RoleHome> {
  late final Future<bool> _isAdmin = AuthService().isAdmin(widget.user);
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data != true) return const CourseListScreen();

        return Scaffold(
          body: IndexedStack(
            index: _tab,
            children: const [CourseListScreen(), AdminCourseListScreen()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Learn'),
              NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Manage'),
            ],
          ),
        );
      },
    );
  }
}
