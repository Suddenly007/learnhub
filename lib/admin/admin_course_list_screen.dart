import 'package:flutter/material.dart';
import '../core/models/course.dart';
import '../core/services/auth_service.dart';
import '../core/services/course_service.dart';
import '../shared/dialogs.dart';
import 'admin_lessons_screen.dart';

class AdminCourseListScreen extends StatelessWidget {
  const AdminCourseListScreen({super.key});

  Future<void> _create(BuildContext context) async {
    final svc = CourseService();
    final title = await promptText(context, 'New course', label: 'Title');
    if (title == null || title.isEmpty || !context.mounted) return;
    final desc = await promptText(context, 'Description', label: 'Short description');
    await svc.createCourse(title, desc ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final svc = CourseService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: AuthService().signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add),
        label: const Text('Course'),
      ),
      body: StreamBuilder<List<Course>>(
        stream: svc.allCourses(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final courses = snap.data!;
          if (courses.isEmpty) return const Center(child: Text('No courses yet. Add one.'));
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (_, i) {
              final c = courses[i];
              return ListTile(
                title: Text(c.title),
                subtitle: Text(c.description),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminLessonsScreen(course: c)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.published ? 'Published' : 'Draft'),
                    Switch(
                      value: c.published,
                      onChanged: (v) => svc.setPublished(c.id, v),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => svc.deleteCourse(c.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
