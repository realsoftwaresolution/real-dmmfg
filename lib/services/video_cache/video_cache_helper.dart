import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'video_cache_stub.dart'
    if (dart.library.html) 'video_cache_web.dart'
    if (dart.library.io) 'video_cache_io.dart';

Future<VideoPlayerController> createPlatformCachedVideoController(
  Uint8List bytes,
  String url,
  void Function(void Function()) registerCleanup,
) {
  return createCachedVideoController(bytes, url, registerCleanup);
}
