import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'firebase_options.dart';
import 'shared/login_screen.dart';
import 'user/course_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnHub',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: StreamBuilder<User?>(
        stream: AuthService().authChanges,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snap.data == null) {
            return const LoginScreen(title: 'Welcome to LearnHub', allowSignUp: true);
          }
          return const CourseListScreen();
        },
      ),
    );
  }
}
