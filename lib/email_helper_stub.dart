/*
 * Email Helper Stub
 * Fallback implementation
 */

import 'dart:typed_data';

Future<bool> sendEmailWithPdfImpl({
  required String recipientEmail,
  required String subject,
  required String bodyText,
  required Uint8List pdfBytes,
  required String pdfFileName,
}) async {
  throw UnsupportedError('Platform not supported');
}
