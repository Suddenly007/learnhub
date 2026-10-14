import 'package:flutter/material.dart';
import '../core/models/course.dart';
import '../core/models/lesson.dart';
import '../core/services/course_service.dart';
import 'lesson_viewer_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  IconData _icon(LessonType t) => switch (t) {
        LessonType.video => Icons.play_circle_outline,
        LessonType.audio => Icons.headphones,
        LessonType.document => Icons.description_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: StreamBuilder<List<Lesson>>(
        stream: CourseService().lessons(course.id),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lessons = snap.data!;
          if (lessons.isEmpty) return const Center(child: Text('No lessons yet.'));
          return ListView(
            children: [
              for (final l in lessons)
                ListTile(
                  leading: Icon(_icon(l.type)),
                  title: Text(l.title),
                  subtitle: Text(l.type.name),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LessonViewerScreen(lesson: l)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
