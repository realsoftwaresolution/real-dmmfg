import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createCachedVideoController(
  Uint8List bytes,
  String url,
  void Function(void Function()) registerCleanup,
) async {
  final cleanLower = url.toLowerCase().split('?').first;
  final String mimeType;
  if (cleanLower.endsWith('.webm')) {
    mimeType = 'video/webm';
  } else if (cleanLower.endsWith('.mov')) {
    mimeType = 'video/quicktime';
  } else if (cleanLower.endsWith('.mkv')) {
    mimeType = 'video/x-matroska';
  } else {
    mimeType = 'video/mp4';
  }

  final blob = html.Blob([bytes], mimeType);
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);

  registerCleanup(() {
    try {
      html.Url.revokeObjectUrl(blobUrl);
    } catch (_) {}
  });

  return VideoPlayerController.networkUrl(
    Uri.parse(blobUrl),
    videoPlayerOptions: VideoPlayerOptions(
      mixWithOthers: true,
      allowBackgroundPlayback: false,
    ),
  );
}
