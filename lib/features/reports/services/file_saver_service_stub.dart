import 'dart:typed_data';

/// Platform stub for non-web environments (unit tests, CLI, mobile)
class FileSaverService {
  static Future<String> savePdfFile(Uint8List bytes, String filename) async {
    // Stub implementation for tests and headless environments
    return 'saved';
  }
}
