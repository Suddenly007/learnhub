import 'package:flutter/material.dart';
import '../core/youtube_utils.dart';
import '../core/models/course.dart';
import '../core/models/lesson.dart';
import '../core/services/course_service.dart';

class AdminLessonsScreen extends StatefulWidget {
  final Course course;
  const AdminLessonsScreen({super.key, required this.course});

  @override
  State<AdminLessonsScreen> createState() => _AdminLessonsScreenState();
}

class _AdminLessonsScreenState extends State<AdminLessonsScreen> {
  final _svc = CourseService();
  int _count = 0;

  Future<void> _addLesson() async {
    final form = await showDialog<_LessonForm>(
      context: context,
      builder: (_) => const _LessonDialog(),
    );
    if (form == null) return;
    try {
      await _svc.addLesson(
        widget.course.id,
        title: form.title,
        type: form.type,
        url: form.url,
        order: _count,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save lesson: $e')));
      }
    }
  }

  IconData _icon(LessonType t) => switch (t) {
        LessonType.video => Icons.play_circle_outline,
        LessonType.audio => Icons.headphones,
        LessonType.document => Icons.description_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLesson,
        icon: const Icon(Icons.add_link),
        label: const Text('Add lesson'),
      ),
      body: StreamBuilder<List<Lesson>>(
        stream: _svc.lessons(widget.course.id),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lessons = snap.data!;
          _count = lessons.length;
          if (lessons.isEmpty) return const Center(child: Text('No lessons yet.'));
          return ListView(
            children: [
              for (final l in lessons)
                ListTile(
                  leading: Icon(_icon(l.type)),
                  title: Text(l.title),
                  subtitle: Text(l.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _svc.deleteLesson(widget.course.id, l.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LessonForm {
  final String title;
  final LessonType type;
  final String url;
  const _LessonForm(this.title, this.type, this.url);
}

class _LessonDialog extends StatefulWidget {
  const _LessonDialog();

  @override
  State<_LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<_LessonDialog> {
  final _title = TextEditingController();
  final _url = TextEditingController();
  LessonType _type = LessonType.video;
  String? _error;

  String? _validate() {
    final url = _url.text.trim();
    if (_title.text.trim().isEmpty) return 'Enter a title';
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http') || uri.host.isEmpty) {
      return 'Enter a valid link starting with https://';
    }
    if (_type == LessonType.video && youtubeIdFromUrl(url) == null) {
      return 'Video links must be YouTube links';
    }
    return null;
  }

  void _save() {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.pop(context, _LessonForm(_title.text.trim(), _type, _url.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add lesson'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _title,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              SegmentedButton<LessonType>(
                segments: const [
                  ButtonSegment(value: LessonType.video, label: Text('Video')),
                  ButtonSegment(value: LessonType.document, label: Text('Document')),
                  ButtonSegment(value: LessonType.audio, label: Text('Audio')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _url,
                decoration: InputDecoration(
                  labelText: _type == LessonType.video
                      ? 'YouTube link (unlisted)'
                      : 'Drive or Dropbox share link',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
