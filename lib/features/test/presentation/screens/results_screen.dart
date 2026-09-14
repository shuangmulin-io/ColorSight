import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cvd_simulator.dart';
import '../../domain/models/test_result.dart';
import '../widgets/spectrum_comparison_widget.dart';
import '../../../reports/services/pdf_report_service.dart';
import '../../../color_id/presentation/screens/photo_color_picker_screen.dart';

class ResultsScreen extends StatelessWidget {
  final TestResult result;

  const ResultsScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isNormal = result.indicatedType == CvdType.normal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isNormal
                        ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                        : [const Color(0xFF7C2D12), const Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isNormal ? AppColors.secondary : AppColors.danger.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                result.id,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                result.testMode,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isNormal ? AppColors.secondary : AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            result.severity.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.summaryTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: ${result.correctCount} / ${result.totalPlates} plates identified (${((result.correctCount / result.totalPlates) * 100).round()}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.explanation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Visual Spectrum Comparison
              SpectrumComparisonWidget(cvdType: result.indicatedType),

              const SizedBox(height: 20),

              // Cross-Feature Callout: Color ID integration (PRD §7)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.colorize_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Personalized Color Identifier',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isNormal
                          ? 'Use our Color Identifier tool to check exact color names and RGB values on photos and daily items.'
                          : 'Your screening profile has been saved. The Color Identifier will now actively warn you about colors known to trigger ${result.indicatedType.name} confusion (e.g. red vs green).',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoColorPickerScreen(
                                userCvdType: result.indicatedType,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF0F172A),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Open Color Identifier with This Profile'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reliability & Screen Notice (PRD §5.7)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reliability & Display Disclaimer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'This screening provides an informal indication. Results depend on display hardware color accuracy, brightness, and ambient lighting. '
                            'For clinical confirmation or official evaluation, please visit an optometrist or ophthalmologist.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Export PDF Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _exportPdf(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                  label: const Text(
                    'Export Official PDF Report',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Detailed Breakdown Accordion
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text(
                    'Plate-by-Plate Response Audit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${result.responses.where((r) => r.isCorrect).length} correct • ${result.responses.where((r) => !r.isCorrect).length} missed',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  children: [
                    const SizedBox(height: 8),
                    for (final resp in (List<PlateResponse>.from(result.responses)..sort((a, b) => a.plateNumber.compareTo(b.plateNumber))))
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: resp.isCorrect ? AppColors.border : AppColors.danger.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: resp.isCorrect
                                    ? AppColors.secondary.withOpacity(0.15)
                                    : AppColors.danger.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                resp.isCorrect ? Icons.check_rounded : Icons.close_rounded,
                                color: resp.isCorrect ? AppColors.secondary : AppColors.danger,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plate ${resp.plateNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Your answer: ${resp.givenAnswer} • Standard: ${resp.normalAnswer}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
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

              const SizedBox(height: 20),

              // Home Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Return to Home'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _exportPdf(BuildContext context) async {
    final nameController = TextEditingController();

    final shouldExport = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 10),
              Text(
                'Export PDF Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the subject name to appear on the official report, or leave blank to keep it anonymous.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                maxLength: 60,
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(60),
                  FilteringTextInputFormatter.deny(RegExp(r'[\r\n\t]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Subject Name (Optional)',
                  hintText: 'e.g. Jacky Lim',
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  counterStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => nameController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'For this export only. Never saved, stored, or pre-filled.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF0F172A),
              ),
              icon: const Icon(Icons.save_alt_rounded, size: 18),
              label: const Text('Save Report...'),
            ),
          ],
        );
      },
    );

    if (shouldExport == true) {
      final name = nameController.text.trim();
      final patientName = name.isNotEmpty ? name : null;

      try {
        final resultStatus = await PdfReportService.savePdfWithLocationPicker(
          result,
          patientName: patientName,
        );

        if (!context.mounted) return;

        if (resultStatus == 'saved' || resultStatus == 'downloaded') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resultStatus == 'saved'
                    ? 'Report saved to your selected folder.'
                    : 'Report downloaded to your Downloads folder.',
              ),
              backgroundColor: AppColors.secondary,
              action: SnackBarAction(
                label: 'Open',
                textColor: const Color(0xFF0F172A),
                onPressed: () => PdfReportService.exportPdfReport(
                  result,
                  patientName: patientName,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to export PDF: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }
}
