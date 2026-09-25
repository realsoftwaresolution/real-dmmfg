import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../bootstrap.dart' show baseUrl;
import 'video_cache/video_cache_helper.dart';

/// Global Video Player Cache Manager
/// Pre-downloads video bytes into local memory (Blob on Web, Temp File on IO)
/// to achieve 100% zero-buffering, instant seeking, and seamless 360-degree looping.
class VideoPlayerCacheManager {
  static final VideoPlayerCacheManager instance = VideoPlayerCacheManager._internal();
  VideoPlayerCacheManager._internal();

  final Map<String, VideoPlayerController> _cache = {};
  final Map<String, Future<VideoPlayerController>> _inProgress = {};
  final Map<String, ValueNotifier<double?>> _downloadProgress = {};
  final Map<String, void Function()> _cleanups = {};
  final List<String> _lruOrder = [];
  static const int _maxCachedControllers = 8;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 120),
      responseType: ResponseType.bytes,
    ),
  );

  /// Resolves relative media URLs using the application's baseUrl.
  String resolveUrl(String relativePath) {
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://') ||
        relativePath.startsWith('blob:')) {
      return relativePath;
    }
    String root = baseUrl;
    if (root.endsWith('/api')) {
      root = root.substring(0, root.length - 4);
    } else if (root.endsWith('/api/')) {
      root = root.substring(0, root.length - 5);
    }
    if (root.endsWith('/')) {
      root = root.substring(0, root.length - 1);
    }
    final cleanPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

    if (cleanPath.startsWith('media/')) {
      return '$root/$cleanPath';
    }
    return '$root/media/$cleanPath';
  }

  /// Extracts and resolves all video URLs from a diamond row data map.
  List<String> extractVideoUrls(Map<String, dynamic>? row) {
    if (row == null) return [];
    final raw = row['videos'] ?? row['Videos'];
    if (raw == null) return [];
    final List<String> result = [];
    final Set<String> seen = {};

    void checkAndAdd(dynamic item) {
      if (item == null) return;
      final str = item.toString().trim();
      if (str.isEmpty || seen.contains(str)) return;
      seen.add(str);

      final lower = str.toLowerCase().split('?').first;
      if (lower.endsWith('.mp4') ||
          lower.endsWith('.mov') ||
          lower.endsWith('.webm') ||
          lower.endsWith('.mkv') ||
          lower.contains('video')) {
        result.add(resolveUrl(str));
      }
    }

    if (raw is List) {
      for (final e in raw) {
        checkAndAdd(e);
      }
    } else if (raw is String) {
      checkAndAdd(raw);
    }
    return result;
  }

  /// Preloads all video controllers for a diamond row in the background.
  void preloadFromRow(Map<String, dynamic>? row) {
    final urls = extractVideoUrls(row);
    for (final url in urls) {
      preload(url);
    }
  }

  /// Gets the real-time download/buffer progress notifier for a given video URL (0.0 to 1.0).
  ValueNotifier<double?> getProgressNotifier(String url) {
    if (_cache.containsKey(url) && _cache[url]!.value.isInitialized) {
      final notifier = _downloadProgress.putIfAbsent(url, () => ValueNotifier<double?>(1.0));
      notifier.value = 1.0;
      return notifier;
    }
    return _downloadProgress.putIfAbsent(url, () => ValueNotifier<double?>(null));
  }

  /// Preloads and buffers a video URL into cache without blocking the UI.
  Future<VideoPlayerController> preload(String url) {
    if (_cache.containsKey(url)) {
      _touch(url);
      _downloadProgress[url]?.value = 1.0;
      return Future.value(_cache[url]!);
    }
    if (_inProgress.containsKey(url)) {
      return _inProgress[url]!;
    }

    final future = _initController(url);
    _inProgress[url] = future;
    return future;
  }

  /// Gets an existing cached controller or creates and initializes a new one.
  Future<VideoPlayerController> getOrCreate(String url) {
    return preload(url);
  }

  /// Returns the cached controller synchronously if it is already available and initialized.
  VideoPlayerController? getCached(String url) {
    if (_cache.containsKey(url)) {
      final controller = _cache[url];
      if (controller != null && controller.value.isInitialized) {
        _touch(url);
        return controller;
      }
    }
    return null;
  }

  Future<VideoPlayerController> _initController(String url) async {
    final progressNotifier = getProgressNotifier(url);
    progressNotifier.value = 0.05;

    VideoPlayerController? controller;
    try {
      // 1. Attempt to download complete video bytes for zero-buffering in-memory / local playback
      try {
        final response = await _dio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: const {
              'Accept': 'video/mp4,video/*;q=0.9,*/*;q=0.8',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final ratio = (received / total).clamp(0.05, 0.95);
              progressNotifier.value = ratio;
            }
          },
        );

        if (response.data != null && response.data!.isNotEmpty) {
          final bytes = Uint8List.fromList(response.data!);
          controller = await createPlatformCachedVideoController(
            bytes,
            url,
            (cleanup) {
              _cleanups[url] = cleanup;
            },
          );
        }
      } catch (dioError) {
        // Fallback: If downloading raw bytes fails (e.g. CORS restriction), fall back to direct streaming
        debugPrint('VideoPlayerCacheManager: Pre-download failed for $url ($dioError), falling back to direct networkUrl streaming');
      }

      // 2. If controller was not created via local bytes, create via network URL fallback
      if (controller == null) {
        final uri = Uri.parse(Uri.encodeFull(url));
        controller = VideoPlayerController.networkUrl(
          uri,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      }

      await controller.initialize();
      await controller.setLooping(true);
      // Muted by default so modern web browsers allow instant autoplay without user gesture blocking
      await controller.setVolume(0.0);
      await controller.seekTo(Duration.zero);
      await controller.pause();

      progressNotifier.value = 1.0;
      _cache[url] = controller;
      _touch(url);
      _evictIfNecessary();
      return controller;
    } catch (e) {
      progressNotifier.value = null;
      debugPrint('VideoPlayerCacheManager: Failed to initialize video controller for $url: $e');
      rethrow;
    } finally {
      _inProgress.remove(url);
    }
  }

  void _touch(String url) {
    _lruOrder.remove(url);
    _lruOrder.add(url);
  }

  void _evictIfNecessary() {
    while (_lruOrder.length > _maxCachedControllers) {
      final oldestUrl = _lruOrder.removeAt(0);
      final controller = _cache.remove(oldestUrl);
      if (controller != null) {
        try {
          controller.pause();
          controller.dispose();
        } catch (_) {}
      }
      _cleanups[oldestUrl]?.call();
      _cleanups.remove(oldestUrl);
      _downloadProgress.remove(oldestUrl);
    }
  }

  /// Pauses all currently playing controllers and rewinds them to start (e.g. when dialog is closed).
  void pauseActive() {
    for (final controller in _cache.values) {
      try {
        controller.pause();
        controller.seekTo(Duration.zero);
      } catch (_) {}
    }
  }

  /// Disposes all cached controllers, revokes object URLs/temp files, and frees memory.
  void disposeAll() {
    for (final controller in _cache.values) {
      try {
        controller.dispose();
      } catch (_) {}
    }
    for (final cleanup in _cleanups.values) {
      try {
        cleanup();
      } catch (_) {}
    }
    _cache.clear();
    _cleanups.clear();
    _downloadProgress.clear();
    _lruOrder.clear();
    _inProgress.clear();
  }
}
