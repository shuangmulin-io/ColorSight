import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cvd_simulator.dart';
import '../../domain/models/named_color.dart';
import '../../domain/services/color_namer.dart';

class PhotoColorPickerScreen extends StatefulWidget {
  final CvdType? userCvdType;

  const PhotoColorPickerScreen({
    super.key,
    this.userCvdType,
  });

  @override
  State<PhotoColorPickerScreen> createState() => _PhotoColorPickerScreenState();
}

class _PhotoColorPickerScreenState extends State<PhotoColorPickerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TransformationController _transformationController = TransformationController();

  Uint8List? _imageBytes;
  img.Image? _decodedImage;
  ColorMatchResult? _currentMatch;
  Offset? _selectedNormalizedPoint;
  bool _useExtendedNames = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _createDefaultSampleImage();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Generates a rich test image with color blocks, fruit, and clothing hues
  void _createDefaultSampleImage() {
    final sampleImg = img.Image(width: 400, height: 400);

    // Fill with a stylish grid of test colors
    final colors = [
      img.ColorRgb8(229, 57, 53), // Red
      img.ColorRgb8(251, 140, 0), // Orange
      img.ColorRgb8(253, 216, 53), // Yellow
      img.ColorRgb8(67, 160, 71), // Green
      img.ColorRgb8(30, 136, 229), // Blue
      img.ColorRgb8(142, 36, 170), // Purple
      img.ColorRgb8(240, 98, 146), // Pink
      img.ColorRgb8(109, 76, 65), // Brown
      img.ColorRgb8(0, 128, 128), // Teal
      img.ColorRgb8(128, 0, 0), // Maroon
      img.ColorRgb8(128, 128, 0), // Olive
      img.ColorRgb8(0, 0, 128), // Navy
      img.ColorRgb8(255, 127, 80), // Coral
      img.ColorRgb8(152, 255, 152), // Mint
      img.ColorRgb8(230, 230, 250), // Lavender
      img.ColorRgb8(245, 245, 220), // Beige
    ];

    const int cols = 4;
    const int rows = 4;
    final int cellW = (400 / cols).floor();
    final int cellH = (400 / rows).floor();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final color = colors[(r * cols + c) % colors.length];
        img.fillRect(
          sampleImg,
          x1: c * cellW,
          y1: r * cellH,
          x2: (c + 1) * cellW,
          y2: (r + 1) * cellH,
          color: color,
        );
      }
    }

    final bytes = Uint8List.fromList(img.encodePng(sampleImg));
    _imageBytes = bytes;
    _decodedImage = sampleImg;

    // Initial sample at center of top-left square (Red)
    _sampleAtNormalizedOffset(const Offset(0.125, 0.125));
  }

  Future<void> _pickImage(ImageSource source, {bool isFallback = false}) async {
    try {
      setState(() => _isProcessing = true);
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 92,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          setState(() {
            _imageBytes = bytes;
            _decodedImage = decoded;
            _isProcessing = false;
            // Reset zoom when new photo is loaded
            _transformationController.value = Matrix4.identity();
          });
          // Sample center of new image
          _sampleAtNormalizedOffset(const Offset(0.5, 0.5));
          return;
        }
      }
    } catch (e) {
      // Graceful fallback for iOS Safari / WebKit camera restrictions (PRD §6.1)
      if (source == ImageSource.camera && !isFallback) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Camera is restricted on this browser or iOS PWA. Switching to photo picker...',
              ),
              action: SnackBarAction(
                label: 'Choose Photo',
                textColor: Colors.amberAccent,
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        await _pickImage(ImageSource.gallery, isFallback: true);
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    matrix.scale(1.35, 1.35);
    setState(() {
      _transformationController.value = matrix;
    });
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    matrix.scale(1 / 1.35, 1 / 1.35);
    setState(() {
      _transformationController.value = matrix;
    });
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  /// Samples a 5x5 pixel region around the chosen normalized coordinate [0..1]
  void _sampleAtNormalizedOffset(Offset norm) {
    if (_decodedImage == null) return;

    final imgW = _decodedImage!.width;
    final imgH = _decodedImage!.height;

    final centerX = (norm.dx * imgW).clamp(0, imgW - 1).toInt();
    final centerY = (norm.dy * imgH).clamp(0, imgH - 1).toInt();

    // 5x5 Box Average to remove camera noise (PRD §6.2)
    int rSum = 0;
    int gSum = 0;
    int bSum = 0;
    int count = 0;

    for (int dy = -2; dy <= 2; dy++) {
      for (int dx = -2; dx <= 2; dx++) {
        final px = (centerX + dx).clamp(0, imgW - 1);
        final py = (centerY + dy).clamp(0, imgH - 1);

        final pixel = _decodedImage!.getPixel(px, py);
        rSum += pixel.r.toInt();
        gSum += pixel.g.toInt();
        bSum += pixel.b.toInt();
        count++;
      }
    }

    final avgR = (rSum / count).round();
    final avgG = (gSum / count).round();
    final avgB = (bSum / count).round();

    final sampledColor = Color.fromARGB(255, avgR, avgG, avgB);
    final match = ColorNamer.identify(
      sampledColor,
      userCvdType: widget.userCvdType ?? CvdType.normal,
    );

    setState(() {
      _selectedNormalizedPoint = norm;
      _currentMatch = match;
    });
  }

  Future<void> _copyColorDetails() async {
    if (_currentMatch == null) return;

    final name = _useExtendedNames
        ? _currentMatch!.extendedName
        : _currentMatch!.basicName;
    final hex = _currentMatch!.hexCode;
    final r = _currentMatch!.sampledColor.red;
    final g = _currentMatch!.sampledColor.green;
    final b = _currentMatch!.sampledColor.blue;

    final textToCopy = '$name ($hex) • RGB($r, $g, $b)';
    await Clipboard.setData(ClipboardData(text: textToCopy));

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Copied "$name ($hex)" to clipboard',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Identifier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            tooltip: 'Pick Image',
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Take Photo',
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Image Viewer with aspect ratio preservation and zoom/pan
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFF070B12),
                width: double.infinity,
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : (_imageBytes != null && _decodedImage != null)
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              // Interactive Zoom & Pan Viewer
                              InteractiveViewer(
                                transformationController: _transformationController,
                                minScale: 1.0,
                                maxScale: 8.0,
                                clipBehavior: Clip.hardEdge,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: _decodedImage!.width / _decodedImage!.height,
                                    child: LayoutBuilder(
                                      builder: (context, imgConstraints) {
                                        return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTapDown: (details) {
                                            final normX = (details.localPosition.dx / imgConstraints.maxWidth).clamp(0.0, 1.0);
                                            final normY = (details.localPosition.dy / imgConstraints.maxHeight).clamp(0.0, 1.0);
                                            _sampleAtNormalizedOffset(Offset(normX, normY));
                                          },
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.memory(
                                                _imageBytes!,
                                                fit: BoxFit.contain,
                                              ),
                                              // Reticle Target
                                              if (_selectedNormalizedPoint != null)
                                                Positioned(
                                                  left: _selectedNormalizedPoint!.dx * imgConstraints.maxWidth - 20,
                                                  top: _selectedNormalizedPoint!.dy * imgConstraints.maxHeight - 20,
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 2.5),
                                                      boxShadow: const [
                                                        BoxShadow(color: Colors.black54, blurRadius: 6),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: _currentMatch?.sampledColor ?? Colors.white,
                                                          border: Border.all(color: Colors.black, width: 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              // Floating Zoom Controls (bottom-right of viewer)
                              Positioned(
                                right: 14,
                                bottom: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(alpha: 0.90),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.zoom_out_rounded, size: 20),
                                        tooltip: 'Zoom Out',
                                        onPressed: _zoomOut,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.restart_alt_rounded, size: 20),
                                        tooltip: 'Reset Zoom (1x)',
                                        onPressed: _resetZoom,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.zoom_in_rounded, size: 20),
                                        tooltip: 'Zoom In',
                                        onPressed: _zoomIn,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Top Hint Banner
                              Positioned(
                                top: 12,
                                left: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.70),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.pinch_rounded, color: Colors.white70, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        'Pinch or use buttons to zoom • Tap to sample',
                                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'Tap photo icon above to load an image',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
              ),
            ),

            // Bottom Results Sheet (Large high contrast swatch + text readout)
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: _currentMatch == null
                    ? const Center(child: Text('Tap on the image to identify color'))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Primary Color Name & Swatch
                            Row(
                              children: [
                                // Large Swatch with High Contrast Border
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _currentMatch!.sampledColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white70, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    key: const Key('color_info_tap_target'),
                                    onTap: _copyColorDetails,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _useExtendedNames
                                                ? _currentMatch!.extendedName
                                                : _currentMatch!.basicName,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${_currentMatch!.hexCode} • RGB(${_currentMatch!.sampledColor.red}, ${_currentMatch!.sampledColor.green}, ${_currentMatch!.sampledColor.blue})',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Copy Action Button
                                IconButton(
                                  key: const Key('copy_color_button'),
                                  icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 22),
                                  tooltip: 'Copy color details',
                                  onPressed: _copyColorDetails,
                                ),
                                const SizedBox(width: 4),
                                // Extended Names Toggle
                                Column(
                                  children: [
                                    Switch.adaptive(
                                      value: _useExtendedNames,
                                      onChanged: (val) => setState(() => _useExtendedNames = val),
                                      activeColor: AppColors.primary,
                                    ),
                                    const Text('Specific', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Confusion Warning (Cross-feature integration)
                            if (_currentMatch!.confusionWarning != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.visibility_rounded, color: AppColors.danger, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _currentMatch!.confusionWarning!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFECDD3),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Luminance Lighting Warning (PRD §6.3)
                            if (_currentMatch!.isPoorLighting && _currentMatch!.lightingWarning != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.wb_incandescent_outlined, color: AppColors.warning, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _currentMatch!.lightingWarning!,
                                        style: const TextStyle(fontSize: 11, color: AppColors.warning),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 10),

                            // Action Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Interactive Color Sampler',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                TextButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                                  label: const Text('Pick Another Photo', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
