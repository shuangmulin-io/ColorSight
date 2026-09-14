import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cvd_simulator.dart';

class SpectrumComparisonWidget extends StatelessWidget {
  final CvdType cvdType;

  const SpectrumComparisonWidget({
    super.key,
    required this.cvdType,
  });

  static const List<Color> _rainbowColors = [
    Color(0xFFE53935), // Red
    Color(0xFFFB8C00), // Orange
    Color(0xFFFDD835), // Yellow
    Color(0xFF43A047), // Green
    Color(0xFF00ACC1), // Cyan
    Color(0xFF1E88E5), // Blue
    Color(0xFF8E24AA), // Violet
  ];

  @override
  Widget build(BuildContext context) {
    final simulatedColors = _rainbowColors
        .map((c) => CvdSimulator.simulate(c, cvdType))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Spectrum Perception Comparison',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Normal Spectrum
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Standard Trichromat Spectrum',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                'Full Visible Range',
                style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildSpectrumBar(_rainbowColors),

          const SizedBox(height: 16),

          // Simulated Spectrum
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Perception (${_formatType(cvdType)})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                cvdType == CvdType.normal ? 'No Deficit' : 'Affected Axis',
                style: TextStyle(
                  fontSize: 11,
                  color: cvdType == CvdType.normal ? AppColors.secondary : AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildSpectrumBar(simulatedColors),

          const SizedBox(height: 10),
          Text(
            _getSpectrumExplanation(cvdType),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectrumBar(List<Color> colors) {
    return Container(
      height: 24,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  String _formatType(CvdType type) {
    switch (type) {
      case CvdType.normal:
        return 'Normal Vision';
      case CvdType.deuteranopia:
        return 'Deutan / Green-Weak';
      case CvdType.protanopia:
        return 'Protan / Red-Weak';
      case CvdType.tritanopia:
        return 'Tritan / Blue-Yellow';
    }
  }

  String _getSpectrumExplanation(CvdType type) {
    switch (type) {
      case CvdType.normal:
        return 'All red, green, and blue cones are fully functioning across typical wavelengths.';
      case CvdType.deuteranopia:
        return 'Red and green wavelengths collapse toward yellowish and olive hues; discrimination between reds and greens is diminished.';
      case CvdType.protanopia:
        return 'Sensitivity to long (red) wavelengths is significantly reduced; bright reds appear darker and shift toward brown/dark green.';
      case CvdType.tritanopia:
        return 'Sensitivity to short (blue) wavelengths is reduced; blue and yellow/violet tones can appear grayish or teal.';
    }
  }
}
