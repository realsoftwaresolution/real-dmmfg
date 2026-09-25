import 'dart:typed_data';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController> createCachedVideoController(
  Uint8List bytes,
  String url,
  void Function(void Function()) registerCleanup,
) async {
  final uri = Uri.parse(Uri.encodeFull(url));
  return VideoPlayerController.networkUrl(
    uri,
    videoPlayerOptions: VideoPlayerOptions(
      mixWithOthers: true,
      allowBackgroundPlayback: false,
    ),
  );
}
