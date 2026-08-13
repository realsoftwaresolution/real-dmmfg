// lib/screens/pair_media_detail_dialog.dart
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import '../bootstrap.dart' show baseUrl;

class PairMediaDetailDialog extends StatefulWidget {
  final Map<String, dynamic> row;

  const PairMediaDetailDialog({super.key, required this.row});

  @override
  State<PairMediaDetailDialog> createState() => _PairMediaDetailDialogState();
}

class _PairMediaDetailDialogState extends State<PairMediaDetailDialog> {
  int _activeTabIndex = 0; // 0: Description, 1: Certificate, 2: Photos, 3: Videos
  String? _selectedMediaUrl;

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
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'video-element-${widget.videoUrl.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final videoElement = html.VideoElement()
        ..src = widget.videoUrl
        ..controls = true
        ..autoplay = false
        ..loop = false
        ..muted = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.objectFit = 'contain';
      return videoElement;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
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
