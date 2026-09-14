// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

/// Web implementation using File System Access API (window.showSaveFilePicker)
/// via message bridge with graceful fallback to anchor download.
class FileSaverService {
  static Future<String> savePdfFile(Uint8List bytes, String filename) async {
    final base64Data = base64Encode(bytes);
    final completer = Completer<String>();

    late StreamSubscription<html.MessageEvent> sub;
    sub = html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['type'] == 'colorsight_save_pdf_result') {
        sub.cancel();
        if (!completer.isCompleted) {
          completer.complete(data['status']?.toString() ?? 'downloaded');
        }
      }
    });

    html.window.postMessage({
      'type': 'colorsight_save_pdf',
      'base64Data': base64Data,
      'filename': filename,
    }, '*');

    // Timeout safety fallback: default to downloaded after 2 minutes if no response
    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        sub.cancel();
        return 'downloaded';
      },
    );
  }
}
