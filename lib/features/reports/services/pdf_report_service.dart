import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../test/domain/models/test_result.dart';
import 'file_saver_service.dart';

class PdfReportService {
  /// Builds the printable PDF Document instance
  static pw.Document buildPdfDocument(TestResult result, {String? patientName}) {
    final doc = pw.Document();

    final dateFormatted = DateFormat('MMMM dd, yyyy, HH:mm').format(result.timestamp);
    final isNormal = result.indicatedType.name == 'normal';
    final sanitizedSubject = (patientName != null && patientName.trim().isNotEmpty)
        ? (patientName.trim().length > 60 ? patientName.trim().substring(0, 60) : patientName.trim())
        : 'Anonymous / Self-administered';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated with ColorSight PWA | Confidential Health Screening',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ColorSight',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.Text(
                    'Color Vision Screening Report',
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: isNormal ? PdfColors.green100 : PdfColors.amber100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(
                    color: isNormal ? PdfColors.green800 : PdfColors.amber800,
                    width: 1,
                  ),
                ),
                child: pw.Text(
                  result.severity.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: isNormal ? PdfColors.green900 : PdfColors.amber900,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 10),

          // Patient / Test Metadata
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Report ID: ${result.id}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 3),
                    pw.Text('Battery: ${result.testMode}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                    pw.SizedBox(height: 3),
                    pw.Text('Date & Time: $dateFormatted',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Age Group: ${result.ageGroup}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 3),
                    pw.Text('Subject: $sanitizedSubject',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Primary Findings
          pw.Text(
            'Screening Findings',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  result.summaryTitle,
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: isNormal ? PdfColors.green900 : PdfColors.deepOrange900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Score: ${result.correctCount} of ${result.totalPlates} plates correctly identified (${((result.correctCount / result.totalPlates) * 100).round()}%)',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  result.explanation,
                  style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800, lineSpacing: 2),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Plate-by-Plate Response Table
          pw.Text(
            'Plate Response Summary',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _tableCell('Plate #', isHeader: true),
                  _tableCell('Target Axis', isHeader: true),
                  _tableCell('Response Given', isHeader: true),
                  _tableCell('Standard Answer', isHeader: true),
                  _tableCell('Result', isHeader: true),
                ],
              ),
              ...(List<PlateResponse>.from(result.responses)..sort((a, b) => a.plateNumber.compareTo(b.plateNumber))).map((resp) {
                String axis = "Red-Green";
                if (resp.plateNumber == 1) axis = "Control (Demo)";
                if ((resp.plateNumber >= 11 && resp.plateNumber <= 13) || resp.plateNumber == 21) axis = "Diagnostic (Protan/Deutan)";
                if (resp.plateNumber == 14 || resp.plateNumber == 24) axis = "Tritan (Blue-Yellow)";
                if (resp.plateNumber >= 19 && resp.plateNumber <= 20) axis = "Hidden Digit (Red-Green)";

                return pw.TableRow(
                  children: [
                    _tableCell('Plate ${resp.plateNumber}'),
                    _tableCell(axis),
                    _tableCell(resp.givenAnswer.isEmpty ? 'Nothing' : resp.givenAnswer),
                    _tableCell(resp.normalAnswer),
                    _tableCell(resp.isCorrect ? 'Correct' : 'Missed',
                        textColor: resp.isCorrect ? PdfColors.green800 : PdfColors.red800),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 12),

          // Disclaimers & Notes
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'IMPORTANT MEDICAL DISCLAIMER & RELIABILITY NOTE',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'This report is generated by ColorSight as an informal screening tool, NOT a medical diagnostic device. '
                  'Screening outcomes depend heavily on device display hardware, brightness, ambient lighting, and absence of software color shifts. '
                  'If color vision is a concern for school, career, or daily activities, please consult a licensed optometrist or ophthalmologist for clinical evaluation.',
                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700, lineSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  /// Formats a clean, descriptive suggested filename for the PDF export
  static String formatSuggestedFilename(TestResult result, {String? patientName}) {
    final dateStr = DateFormat('yyyy-MM-dd').format(result.timestamp);
    if (patientName != null && patientName.trim().isNotEmpty) {
      final sanitized = patientName
          .trim()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-');
      if (sanitized.isNotEmpty) {
        return 'ColorSight-Report-$sanitized-$dateStr.pdf';
      }
    }
    return 'ColorSight-Screening-Report-$dateStr.pdf';
  }

  /// Generates the raw PDF bytes for a test result
  static Future<Uint8List> generatePdfBytes(TestResult result, {String? patientName}) async {
    final doc = buildPdfDocument(result, patientName: patientName);
    return doc.save();
  }

  /// Saves the PDF document using the native OS location picker (Save As...)
  static Future<String> savePdfWithLocationPicker(TestResult result, {String? patientName}) async {
    final bytes = await generatePdfBytes(result, patientName: patientName);
    final filename = formatSuggestedFilename(result, patientName: patientName);
    return FileSaverService.savePdfFile(bytes, filename);
  }

  /// Generates a PDF screening report and opens the native print/save dialog in a new tab
  static Future<void> exportPdfReport(TestResult result, {String? patientName}) async {
    final doc = buildPdfDocument(result, patientName: patientName);
    final filename = formatSuggestedFilename(result, patientName: patientName);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: filename,
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? (isHeader ? PdfColors.blueGrey900 : PdfColors.grey800),
        ),
      ),
    );
  }
}
