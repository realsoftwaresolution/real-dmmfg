import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../bootstrap.dart' show baseUrl;

/// Global Video Player Cache Manager
/// Preloads, caches, and manages [VideoPlayerController] instances for diamond media videos.
/// Eliminates loading latency and buffering delays when opening media dialogs or switching tabs.
class VideoPlayerCacheManager {
  static final VideoPlayerCacheManager instance = VideoPlayerCacheManager._internal();
  VideoPlayerCacheManager._internal();

  final Map<String, VideoPlayerController> _cache = {};
  final Map<String, Future<VideoPlayerController>> _inProgress = {};
  final List<String> _lruOrder = [];
  static const int _maxCachedControllers = 8;

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

  /// Preloads and buffers a video URL into cache without blocking the UI.
  Future<VideoPlayerController> preload(String url) {
    if (_cache.containsKey(url)) {
      _touch(url);
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
    try {
      final uri = Uri.parse(Uri.encodeFull(url));
      final controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await controller.initialize();
      await controller.setLooping(true);
      // Muted by default so modern web browsers allow instant autoplay without blocking
      await controller.setVolume(0.0);
      await controller.play();

      _cache[url] = controller;
      _touch(url);
      _evictIfNecessary();
      return controller;
    } catch (e) {
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
    }
  }

  /// Pauses all currently playing controllers (e.g. when dialog is closed).
  void pauseActive() {
    for (final controller in _cache.values) {
      try {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      } catch (_) {}
    }
  }

  /// Disposes all cached controllers and frees memory.
  void disposeAll() {
    for (final controller in _cache.values) {
      try {
        controller.dispose();
      } catch (_) {}
    }
    _cache.clear();
    _lruOrder.clear();
    _inProgress.clear();
  }
}
