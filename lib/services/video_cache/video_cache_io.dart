import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createCachedVideoController(
  Uint8List bytes,
  String url,
  void Function(void Function()) registerCleanup,
) async {
  final cleanLower = url.toLowerCase().split('?').first;
  final String ext;
  if (cleanLower.endsWith('.webm')) {
    ext = '.webm';
  } else if (cleanLower.endsWith('.mov')) {
    ext = '.mov';
  } else if (cleanLower.endsWith('.mkv')) {
    ext = '.mkv';
  } else {
    ext = '.mp4';
  }

  final tempDir = await getTemporaryDirectory();
  final hash = url.hashCode.abs();
  final filename = 'diam_vid_${hash}_${DateTime.now().millisecondsSinceEpoch}$ext';
  final file = File('${tempDir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);

  registerCleanup(() {
    try {
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  });

  return VideoPlayerController.file(
    file,
    videoPlayerOptions: VideoPlayerOptions(
      mixWithOthers: true,
      allowBackgroundPlayback: false,
    ),
  );
}
