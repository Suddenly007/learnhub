import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final bool published;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.published = false,
  });

  factory Course.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Course(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      thumbnailUrl: d['thumbnailUrl'],
      published: d['published'] ?? false,
    );
  }
}
