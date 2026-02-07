/*
 * PDF Helper
 *
 * Cross-platform PDF saving functionality.
 * Handles both mobile (using path_provider) and web (using blob download).
 */

import 'package:flutter/foundation.dart';
import 'dart:typed_data';

// Conditional imports for web vs mobile
import 'pdf_helper_stub.dart'
    if (dart.library.html) 'pdf_helper_web.dart'
    if (dart.library.io) 'pdf_helper_mobile.dart';

/// Saves PDF bytes and returns true if successful
Future<bool> savePdfFile(Uint8List pdfBytes, String fileName) async {
  return savePdfImpl(pdfBytes, fileName);
}
