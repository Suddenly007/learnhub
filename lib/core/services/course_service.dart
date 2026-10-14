import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/lesson.dart';

class CourseService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _courses =>
      _db.collection('courses');

  // ---- User side ----
  Stream<List<Course>> publishedCourses() => _courses
      .where('published', isEqualTo: true)
      .snapshots()
      .map((s) {
        final list = s.docs.map(Course.fromDoc).toList();
        list.sort((a, b) => a.title.compareTo(b.title)); // avoids a composite index
        return list;
      });

  Stream<List<Lesson>> lessons(String courseId) => _courses
      .doc(courseId)
      .collection('lessons')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(Lesson.fromDoc).toList());

  // ---- Admin side ----
  Stream<List<Course>> allCourses() => _courses
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Course.fromDoc).toList());

  Future<void> createCourse(String title, String description) =>
      _courses.add({
        'title': title,
        'description': description,
        'published': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> setPublished(String courseId, bool value) =>
      _courses.doc(courseId).update({'published': value});

  // Note: this does not delete the lessons subcollection or stored files.
  // Clean that up with a Cloud Function later.
  Future<void> deleteCourse(String courseId) => _courses.doc(courseId).delete();

  Future<void> addLesson(
    String courseId, {
    required String title,
    required LessonType type,
    required String url,
    required int order,
  }) =>
      _courses.doc(courseId).collection('lessons').add({
        'title': title,
        'type': type.name,
        'url': url,
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteLesson(String courseId, String lessonId) =>
      _courses.doc(courseId).collection('lessons').doc(lessonId).delete();
}
