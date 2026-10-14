import 'package:cloud_firestore/cloud_firestore.dart';

enum LessonType { video, document, audio }

LessonType lessonTypeFromExtension(String? ext) {
  switch ((ext ?? '').toLowerCase()) {
    case 'mp4':
    case 'mov':
    case 'webm':
    case 'mkv':
      return LessonType.video;
    case 'mp3':
    case 'm4a':
    case 'wav':
    case 'aac':
    case 'ogg':
      return LessonType.audio;
    default:
      return LessonType.document;
  }
}

class Lesson {
  final String id;
  final String title;
  final LessonType type;
  final String url;
  final int order;

  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.order,
  });

  factory Lesson.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Lesson(
      id: doc.id,
      title: d['title'] ?? '',
      type: LessonType.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => LessonType.document,
      ),
      url: d['url'] ?? '',
      order: (d['order'] ?? 0) as int,
    );
  }
}
