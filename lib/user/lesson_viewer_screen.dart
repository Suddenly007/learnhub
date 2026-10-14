import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../core/models/lesson.dart';
import '../core/youtube_utils.dart';

class LessonViewerScreen extends StatelessWidget {
  final Lesson lesson;
  const LessonViewerScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    if (lesson.type == LessonType.video) return _VideoView(lesson: lesson);
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: _LinkView(lesson: lesson),
    );
  }
}

class _VideoView extends StatefulWidget {
  final Lesson lesson;
  const _VideoView({required this.lesson});

  @override
  State<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final id = youtubeIdFromUrl(widget.lesson.url);
    if (id != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: id,
        autoPlay: false,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: const Center(child: Text('This video link is not valid.')),
      );
    }
    return YoutubePlayerScaffold(
      controller: controller,
      builder: (context, player) => Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: ListView(
          children: [
            player,
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.lesson.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkView extends StatelessWidget {
  final Lesson lesson;
  const _LinkView({required this.lesson});

  Future<void> _open(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(lesson.url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAudio = lesson.type == LessonType.audio;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isAudio ? Icons.headphones : Icons.description_outlined, size: 72),
          const SizedBox(height: 16),
          Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _open(context),
            icon: const Icon(Icons.open_in_new),
            label: Text(isAudio ? 'Listen' : 'Read'),
          ),
        ],
      ),
    );
  }
}
