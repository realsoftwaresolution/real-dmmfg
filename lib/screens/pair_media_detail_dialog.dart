// lib/screens/pair_media_detail_dialog.dart
import 'dart:async';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:video_player/video_player.dart';
import '../bootstrap.dart' show baseUrl;
import '../services/video_player_cache_manager.dart';

class PairMediaDetailDialog extends StatefulWidget {
  final Map<String, dynamic> row;

  const PairMediaDetailDialog({super.key, required this.row});

  @override
  State<PairMediaDetailDialog> createState() => _PairMediaDetailDialogState();
}

class _PairMediaDetailDialogState extends State<PairMediaDetailDialog> {
  int _activeTabIndex = 0; // 0: Description, 1: Certificate, 2: Photos, 3: Videos
  String? _selectedMediaUrl;

  @override
  void initState() {
    super.initState();
    VideoPlayerCacheManager.instance.preloadFromRow(widget.row);
  }

  @override
  void dispose() {
    VideoPlayerCacheManager.instance.pauseActive();
    super.dispose();
  }

  List<String> _parseMediaList(dynamic list) {
    if (list == null) return [];
    final List<String> result = [];
    final Set<String> seen = {};

    void add(dynamic item) {
      if (item == null) return;
      final str = item.toString().trim();
      if (str.isNotEmpty && !seen.contains(str)) {
        seen.add(str);
        result.add(str);
      }
    }

    if (list is List) {
      for (final e in list) {
        add(e);
      }
    } else if (list is String) {
      add(list);
    }
    return result;
  }

  String _resolveUrl(String relativePath) {
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://') || relativePath.startsWith('blob:')) {
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

  void _download(String relativePath) {
    final fullUrl = _resolveUrl(relativePath);
    final fileName = relativePath.split('/').last.split('\\').last;
    try {
      final anchor = html.AnchorElement(href: fullUrl)
        ..target = 'blank'
        ..download = fileName;
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();
    } catch (_) {
      html.window.open(fullUrl, '_blank');
    }
  }

  String _val(String key, [String fallback = '-']) {
    final dynamic v = widget.row[key] ??
        widget.row[key.toLowerCase()] ??
        widget.row[key.toUpperCase()];
    if (v == null) return fallback;
    final str = v.toString().trim();
    if (str.isEmpty || str == 'null') return fallback;
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final images = _parseMediaList(widget.row['images'] ?? widget.row['Images']);
    final videos = _parseMediaList(widget.row['videos'] ?? widget.row['Videos']);
    final certificates = _parseMediaList(widget.row['certificates'] ?? widget.row['Certificates']);

    // Deduplicate media items for current active tab
    final Set<String> tabMediaSeen = {};
    final List<String> currentMediaItems = [];
    void addTabItem(String item) {
      if (!tabMediaSeen.contains(item)) {
        tabMediaSeen.add(item);
        currentMediaItems.add(item);
      }
    }

    if (_activeTabIndex == 0) {
      for (final v in videos) {
        addTabItem(v);
      }
      for (final img in images) {
        addTabItem(img);
      }
      for (final certItem in certificates) {
        addTabItem(certItem);
      }
    } else if (_activeTabIndex == 1) {
      for (final certItem in certificates) {
        addTabItem(certItem);
      }
    } else if (_activeTabIndex == 2) {
      for (final img in images) {
        addTabItem(img);
      }
    } else if (_activeTabIndex == 3) {
      for (final v in videos) {
        addTabItem(v);
      }
    }

    final activeMedia = _selectedMediaUrl ?? (currentMediaItems.isNotEmpty ? currentMediaItems.first : null);

    // Extract exact data fields from API response
    final pktNo = _val('PktNo');
    final bCode = _val('BCode');
    final wt = _val('Wt');
    final issWt = _val('IssWt');
    final recWt = _val('RecWt');
    final color = _val('Color');
    final clarity = _val('Clarity');
    final cut = _val('Cut');
    final polish = _val('Polish');
    final symmetry = _val('Symmetry');
    final fluo = widget.row['Flou']?.toString().trim() ??
        widget.row['flou']?.toString().trim() ??
        widget.row['Fluo']?.toString().trim() ??
        widget.row['fluo']?.toString().trim() ??
        '-';
    final sellPrice = _val('SellPrice');
    final sellAmount = _val('SellAmount');
    final length = _val('Length');
    final dia = _val('Dia');
    final height = _val('Height');
    final topSide = _val('TopSide');
    final groupType = _val('GroupType');
    final cert = _val('Certificate');
    final certiNo = _val('CertiNo');
    final pairNo = _val('PairNo');
    final shape = _val('Shape');
    final kapanNo = _val('KapanNo');

    final String mmStr = (length != '-' && dia != '-' && height != '-')
        ? '$length × $dia × $height'
        : '-';
    final String depthStr = (height != '-' && height != '0') ? '$height%' : '-';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 12,
      shadowColor: Colors.black26,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        width: 1150,
        height: 730,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Top Bar: Modern Segmented Tab Bar + Close Button
            Row(
              children: [
                // Segmented Tabs Container
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      _buildModernTab(0, 'Description', null),
                      _buildModernTab(1, 'Certificate', certificates.length),
                      _buildModernTab(2, 'Photos', images.length),
                      _buildModernTab(3, 'Videos', videos.length),
                    ],
                  ),
                ),
                const Spacer(),
                // Packet ID Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond_outlined, size: 16, color: Color(0xFF0288D1)),
                      const SizedBox(width: 6),
                      Text(
                        'Pkt: $pktNo (BCode: $bCode)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0288D1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Close Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF64748B), size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content Body: Left Column (Media Viewer & Download List) | Right Column (Diamond Specs Grid)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Media Box + Styled File Download Cards (flex: 5)
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Media Display Container
                        Container(
                          width: double.infinity,
                          height: 410,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Main Embedded Media Viewer
                              Positioned.fill(
                                child: activeMedia == null
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.perm_media_outlined, size: 48, color: Colors.white38),
                                            SizedBox(height: 8),
                                            Text(
                                              'No media available for this tab',
                                              style: TextStyle(color: Colors.white54, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _buildMediaViewer(activeMedia),
                              ),

                              // Frosted Glass Text Overlay at Top (Matching Screenshot Info)
                              Positioned(
                                top: 12,
                                left: 16,
                                right: 16,
                                child: IgnorePointer(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$wt CT  $color  -  $clarity',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$length × $dia × $height MM',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Downloadable File Cards List
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: currentMediaItems.map((item) {
                                  final fileName = item.split('/').last.split('\\').last;
                                  final isSelected = item == activeMedia;
                                  final lower = item.toLowerCase();
                                  final isVid = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm');
                                  final isPdf = lower.endsWith('.pdf');

                                  IconData iconData = Icons.image_outlined;
                                  if (isVid) iconData = Icons.play_circle_outline;
                                  if (isPdf) iconData = Icons.picture_as_pdf_outlined;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF0288D1) : const Color(0xFFE2E8F0),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(iconData, size: 18, color: isSelected ? const Color(0xFF0288D1) : const Color(0xFF64748B)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() => _selectedMediaUrl = item);
                                              },
                                              child: Text(
                                                fileName,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isSelected ? const Color(0xFF0288D1) : const Color(0xFF1E293B),
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: InkWell(
                                            onTap: () => _download(item),
                                            borderRadius: BorderRadius.circular(4),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0288D1).withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(Icons.download_rounded, size: 14, color: Color(0xFF0288D1)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Download',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF0288D1),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right Side: Premium Specification Grid Table (flex: 6)
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Table(
                                border: TableBorder.all(color: const Color(0xFFE2E8F0), width: 1),
                                columnWidths: const {
                                  0: FlexColumnWidth(1.1),
                                  1: FlexColumnWidth(1.4),
                                  2: FlexColumnWidth(1.4),
                                  3: FlexColumnWidth(1.4),
                                },
                                children: [
                                  _buildSpecRow('Stock#', '$bCode, $pktNo', 'Availability', 'In Stock'),
                                  _buildSpecRow('Lab', cert, 'Cert No', certiNo, isLabBlue: true),
                                  _buildSpecRow('Shape', shape, 'Weight', '$wt CT'),
                                  _buildSpecRow('Color', color, 'Clarity', clarity),
                                  _buildSpecRow('Cut', cut, 'Fluorescence', fluo),
                                  _buildSpecRow('Polish', polish, 'Symmetry', symmetry),
                                  _buildSpecRow('Measurement', mmStr, 'Depth', depthStr),
                                  _buildSpecRow('Iss Wt', issWt, 'Rec Wt', recWt),
                                  _buildSpecRow('Sell Price', sellPrice != '-' ? '\$$sellPrice' : '-', 'Sell Amount', sellAmount != '-' ? '\$$sellAmount' : '-'),
                                  _buildSpecRow('PairNo', pairNo, 'KapanNo', kapanNo),
                                  _buildSpecRow('TopSide', topSide, 'GroupType', groupType),
                                  _buildSpecRow('H&A', 'False', 'BROWN/ GREEN/ MILKY', 'False/ False/ False'),
                                  _buildSpecRow('CenterInc', 'False', 'SideInc', 'False'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Share via WhatsApp Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final text = "Check Diamond Stock# $bCode, PktNo $pktNo: $wt CT $color $clarity";
                                final url = "https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}";
                                html.window.open(url, '_blank');
                              },
                              icon: const Icon(Icons.share_outlined, size: 16),
                              label: const Text('Share on WhatsApp'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTab(int index, String label, int? count) {
    final isSelected = _activeTabIndex == index;
    final displayLabel = (count != null && count > 0) ? '$label ($count)' : label;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
            _selectedMediaUrl = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0288D1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            displayLabel,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildSpecRow(String k1, String v1, String k2, String v2, {bool isLabBlue = false}) {
    return TableRow(
      children: [
        _buildTableCell(k1, isKey: true),
        _buildTableCell(v1, isKey: false, isBlue: isLabBlue || k1 == 'Measurement'),
        _buildTableCell(k2, isKey: true),
        _buildTableCell(v2, isKey: false),
      ],
    );
  }

  Widget _buildTableCell(String text, {required bool isKey, bool isBlue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
      color: isKey ? const Color(0xFFF8FAFC) : Colors.white,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isKey ? FontWeight.w600 : FontWeight.w500,
          color: isKey
              ? const Color(0xFF475569)
              : (isBlue ? const Color(0xFF0288D1) : const Color(0xFF0F172A)),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMediaViewer(String relativePath) {
    final fullUrl = _resolveUrl(relativePath);
    final lower = relativePath.toLowerCase().split('?').first;
    final isVideo = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm') || lower.endsWith('.mkv') || lower.contains('video');
    final isPdf = lower.endsWith('.pdf');

    if (isVideo) {
      return EmbeddedVideoPlayer(key: ValueKey(fullUrl), videoUrl: fullUrl);
    } else if (isPdf) {
      return EmbeddedPdfViewer(key: ValueKey(fullUrl), pdfUrl: fullUrl);
    }

    return EmbeddedImageViewer(key: ValueKey(fullUrl), imageUrl: fullUrl);
  }
}

class EmbeddedVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const EmbeddedVideoPlayer({super.key, required this.videoUrl});

  @override
  State<EmbeddedVideoPlayer> createState() => _EmbeddedVideoPlayerState();
}

class _EmbeddedVideoPlayerState extends State<EmbeddedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;
  bool _isHoveringControls = false;
  Timer? _hideTimer;
  double _currentSpeed = 1.0;
  bool _isLooping = true;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant EmbeddedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _cleanupCurrent();
      _isInitialized = false;
      _hasError = false;
      _errorMessage = '';
      _initPlayer();
    }
  }

  void _cleanupCurrent() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
  }

  void _initPlayer() {
    // 1. Check if controller is already cached and ready for instant playback
    final cached = VideoPlayerCacheManager.instance.getCached(widget.videoUrl);
    if (cached != null && cached.value.isInitialized) {
      _controller = cached;
      _isInitialized = true;
      _isLooping = cached.value.isLooping;
      _isMuted = cached.value.volume == 0.0;
      _currentSpeed = cached.value.playbackSpeed;
      _controller!.addListener(_onControllerUpdate);
      if (!_controller!.value.isPlaying) {
        _controller!.play();
      }
      _startHideTimer();
      return;
    }

    // 2. Otherwise get or create from cache manager
    VideoPlayerCacheManager.instance.getOrCreate(widget.videoUrl).then((controller) {
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isInitialized = true;
        _isLooping = controller.value.isLooping;
        _isMuted = controller.value.volume == 0.0;
        _currentSpeed = controller.value.playbackSpeed;
      });
      _controller!.addListener(_onControllerUpdate);
      if (!_controller!.value.isPlaying) {
        _controller!.play();
      }
      _startHideTimer();
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    });
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    if (_controller != null && _controller!.value.hasError && !_hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = _controller!.value.errorDescription ?? 'Video playback error';
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _controller != null && _controller!.value.isPlaying && !_isHoveringControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onUserInteraction() {
    if (!_showControls) {
      setState(() => _showControls = true);
    }
    _startHideTimer();
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _showControls = true);
      _hideTimer?.cancel();
    } else {
      _controller!.play();
      _startHideTimer();
    }
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
    });
    _controller!.setVolume(_isMuted ? 0.0 : 1.0);
  }

  void _toggleLoop() {
    if (_controller == null) return;
    setState(() {
      _isLooping = !_isLooping;
    });
    _controller!.setLooping(_isLooping);
  }

  void _changeSpeed(double speed) {
    if (_controller == null) return;
    setState(() {
      _currentSpeed = speed;
    });
    _controller!.setPlaybackSpeed(speed);
  }

  void _seekRelative(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final current = _controller!.value.position;
    final target = current + Duration(seconds: seconds);
    final duration = _controller!.value.duration;
    if (target < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (target > duration) {
      _controller!.seekTo(duration);
    } else {
      _controller!.seekTo(target);
    }
    _onUserInteraction();
  }

  void _openFullscreen() {
    if (_controller == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) => _FullscreenDiamondVideoDialog(
        controller: _controller!,
        videoUrl: widget.videoUrl,
      ),
    );
  }

  @override
  void dispose() {
    _cleanupCurrent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Main Video Render Layer
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio > 0
                    ? _controller!.value.aspectRatio
                    : 16 / 9,
                child: RepaintBoundary(
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          // else if (!_hasError)
          //   _buildElegantPlaceholder(),

          // 2. Error Fallback
          else if (_hasError) _buildErrorOverlay(),

          // 3. Subtle Center Buffering Indicator (leaves underlying frame visible)
          if (_isInitialized && _controller != null)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller!,
              builder: (context, value, child) {
                if (value.isBuffering) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0288D1)),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // 4. Tap gesture detector across the video surface
          Positioned.fill(
            child: MouseRegion(
              onHover: (_) => _onUserInteraction(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePlayPause,
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // 5. Center Play Button (when paused)
          if (_isInitialized && _controller != null)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller!,
              builder: (context, value, child) {
                if (!value.isPlaying && _showControls) {
                  return Center(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0288D1).withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 38),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // 6. Bottom Controls Bar
          if (_isInitialized && _controller != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: _buildControlsBar(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildElegantPlaceholder() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0288D1).withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0288D1).withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.diamond_outlined,
                size: 36,
                color: Color(0xFF0288D1),
              ),
            ),
            const SizedBox(height: 14),
            const SizedBox(
              width: 130,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFF1E293B),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0288D1)),
                minHeight: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            const Text(
              'Unable to play video',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'Format not supported or network error',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                    });
                    _initPlayer();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    html.window.open(widget.videoUrl, '_blank');
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open in Browser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsBar() {
    return MouseRegion(
      onEnter: (_) => _isHoveringControls = true,
      onExit: (_) {
        _isHoveringControls = false;
        _startHideTimer();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.88),
              Colors.black.withValues(alpha: 0.45),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scrubber
            _VideoProgressBar(
              controller: _controller!,
              onSeekStart: () => _hideTimer?.cancel(),
              onSeekEnd: () => _startHideTimer(),
            ),
            const SizedBox(height: 4),

            // Controls Row
            Row(
              children: [
                // Play / Pause
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller!,
                  builder: (context, value, _) {
                    return _buildIconButton(
                      icon: value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      tooltip: value.isPlaying ? 'Pause' : 'Play',
                      onTap: _togglePlayPause,
                    );
                  },
                ),

                // Rewind 5s
                _buildIconButton(
                  icon: Icons.replay_5_rounded,
                  tooltip: 'Rewind 5s',
                  iconSize: 18,
                  onTap: () => _seekRelative(-5),
                ),

                // Forward 5s
                _buildIconButton(
                  icon: Icons.forward_5_rounded,
                  tooltip: 'Forward 5s',
                  iconSize: 18,
                  onTap: () => _seekRelative(5),
                ),

                const SizedBox(width: 6),

                // Time Display
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _controller!,
                  builder: (context, value, _) {
                    final pos = _formatDuration(value.position);
                    final dur = _formatDuration(value.duration);
                    return Text(
                      '$pos / $dur',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Continuous 360° Loop toggle
                _buildIconButton(
                  icon: Icons.repeat_rounded,
                  tooltip: _isLooping ? '360° Loop: Active' : '360° Loop: Off',
                  iconSize: 18,
                  color: _isLooping ? const Color(0xFF0288D1) : Colors.white60,
                  onTap: _toggleLoop,
                ),

                const SizedBox(width: 4),

                // Speed Selector
                PopupMenuButton<double>(
                  tooltip: 'Playback Speed',
                  initialValue: _currentSpeed,
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: _changeSpeed,
                  itemBuilder: (ctx) => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                    return PopupMenuItem<double>(
                      value: s,
                      height: 32,
                      child: Text(
                        '${s}x',
                        style: TextStyle(
                          fontSize: 12,
                          color: s == _currentSpeed ? const Color(0xFF0288D1) : Colors.white,
                          fontWeight: s == _currentSpeed ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_currentSpeed}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Volume / Mute
                _buildIconButton(
                  icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  tooltip: _isMuted ? 'Unmute' : 'Mute',
                  iconSize: 18,
                  color: _isMuted ? Colors.white60 : Colors.white,
                  onTap: _toggleMute,
                ),

                // Fullscreen
                _buildIconButton(
                  icon: Icons.fullscreen_rounded,
                  tooltip: 'Fullscreen View',
                  iconSize: 20,
                  onTap: _openFullscreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    double iconSize = 22,
    Color color = Colors.white,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onSeekStart;
  final VoidCallback onSeekEnd;

  const _VideoProgressBar({
    required this.controller,
    required this.onSeekStart,
    required this.onSeekEnd,
  });

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  bool _isDragging = false;
  double _dragFraction = 0.0;

  void _seekTo(double localDx, double width) {
    final fraction = (localDx / width).clamp(0.0, 1.0);
    final target = widget.controller.value.duration * fraction;
    widget.controller.seekTo(target);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final durationMs = value.duration.inMilliseconds;
        final positionMs = value.position.inMilliseconds;

        double playedFraction = 0.0;
        if (durationMs > 0) {
          playedFraction = (_isDragging ? _dragFraction : (positionMs / durationMs)).clamp(0.0, 1.0);
        }

        double bufferedFraction = 0.0;
        if (durationMs > 0 && value.buffered.isNotEmpty) {
          for (final range in value.buffered) {
            final f = range.end.inMilliseconds / durationMs;
            if (f > bufferedFraction) bufferedFraction = f.clamp(0.0, 1.0);
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (details) {
                  setState(() {
                    _isDragging = true;
                    _dragFraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
                  });
                  widget.onSeekStart();
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragFraction = (details.localPosition.dx / width).clamp(0.0, 1.0);
                  });
                },
                onHorizontalDragEnd: (details) {
                  final target = widget.controller.value.duration * _dragFraction;
                  widget.controller.seekTo(target);
                  setState(() => _isDragging = false);
                  widget.onSeekEnd();
                },
                onTapDown: (details) {
                  _seekTo(details.localPosition.dx, width);
                  widget.onSeekEnd();
                },
                child: SizedBox(
                  height: 20,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background Track
                      Container(
                        height: 4,
                        width: width,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Buffered Track
                      Container(
                        height: 4,
                        width: width * bufferedFraction,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Played Track
                      Container(
                        height: 4,
                        width: width * playedFraction,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Scrubber Thumb
                      Positioned(
                        left: (width * playedFraction - 6).clamp(0.0, width - 12),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                            border: Border.all(color: const Color(0xFF0288D1), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FullscreenDiamondVideoDialog extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoUrl;

  const _FullscreenDiamondVideoDialog({
    required this.controller,
    required this.videoUrl,
  });

  @override
  State<_FullscreenDiamondVideoDialog> createState() => _FullscreenDiamondVideoDialogState();
}

class _FullscreenDiamondVideoDialogState extends State<_FullscreenDiamondVideoDialog> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onInteraction() {
    if (!_showControls) {
      setState(() => _showControls = true);
    }
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: MouseRegion(
          onHover: (_) => _onInteraction(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Large Video
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio > 0
                      ? widget.controller.value.aspectRatio
                      : 16 / 9,
                  child: RepaintBoundary(
                    child: VideoPlayer(widget.controller),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),

              // Fullscreen controls
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.88),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _VideoProgressBar(
                            controller: widget.controller,
                            onSeekStart: () => _hideTimer?.cancel(),
                            onSeekEnd: () => _startHideTimer(),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ValueListenableBuilder<VideoPlayerValue>(
                                valueListenable: widget.controller,
                                builder: (context, value, _) {
                                  return IconButton(
                                    icon: Icon(
                                      value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: () {
                                      if (value.isPlaying) {
                                        widget.controller.pause();
                                        setState(() => _showControls = true);
                                      } else {
                                        widget.controller.play();
                                        _startHideTimer();
                                      }
                                    },
                                  );
                                },
                              ),
                              ValueListenableBuilder<VideoPlayerValue>(
                                valueListenable: widget.controller,
                                builder: (context, value, _) {
                                  final pos = _formatDuration(value.position);
                                  final dur = _formatDuration(value.duration);
                                  return Text(
                                    '$pos / $dur',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  );
                                },
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 26),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmbeddedImageViewer extends StatefulWidget {
  final String imageUrl;

  const EmbeddedImageViewer({super.key, required this.imageUrl});

  @override
  State<EmbeddedImageViewer> createState() => _EmbeddedImageViewerState();
}

class _EmbeddedImageViewerState extends State<EmbeddedImageViewer> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'image-element-${widget.imageUrl.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final imgElement = html.ImageElement()
        ..src = widget.imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.objectFit = 'contain';
      return imgElement;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}

class EmbeddedPdfViewer extends StatefulWidget {
  final String pdfUrl;

  const EmbeddedPdfViewer({super.key, required this.pdfUrl});

  @override
  State<EmbeddedPdfViewer> createState() => _EmbeddedPdfViewerState();
}

class _EmbeddedPdfViewerState extends State<EmbeddedPdfViewer> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'pdf-element-${widget.pdfUrl.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframeElement = html.IFrameElement()
        ..src = widget.pdfUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none';
      return iframeElement;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
