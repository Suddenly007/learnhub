import 'package:flutter/material.dart';
import '../core/models/course.dart';
import '../core/services/auth_service.dart';
import '../core/services/course_service.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: AuthService().signOut),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: CourseService().publishedCourses(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final courses = snap.data!;
          if (courses.isEmpty) return const Center(child: Text('No courses available yet.'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: courses.length,
            itemBuilder: (_, i) {
              final c = courses[i];
              return Card(
                child: ListTile(
                  title: Text(c.title),
                  subtitle: Text(c.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
