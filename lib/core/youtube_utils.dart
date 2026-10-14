/// Extracts the 11-character video id from common YouTube link formats.
/// Returns null if the link is not a valid YouTube video link.
String? youtubeIdFromUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  String? id;

  if (host == 'youtu.be') {
    id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  } else if (host.endsWith('youtube.com') || host.endsWith('youtube-nocookie.com')) {
    if (uri.queryParameters['v'] != null) {
      id = uri.queryParameters['v'];
    } else if (uri.pathSegments.length >= 2 &&
        const {'embed', 'shorts', 'live', 'v'}.contains(uri.pathSegments.first)) {
      id = uri.pathSegments[1];
    }
  }

  if (id != null && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)) return id;
  return null;
}
