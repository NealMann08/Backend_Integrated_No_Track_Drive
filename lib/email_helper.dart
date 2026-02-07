/*
 * Email Helper
 *
 * Cross-platform email functionality with PDF attachment support.
 * On mobile: Uses share_plus to share PDF via email apps
 * On web: Falls back to mailto with instructions
 */

import 'package:flutter/foundation.dart';
import 'dart:typed_data';

// Conditional imports
import 'email_helper_stub.dart'
    if (dart.library.html) 'email_helper_web.dart'
    if (dart.library.io) 'email_helper_mobile.dart';

/// Send email with PDF attachment
/// Returns true if successful, false otherwise
Future<bool> sendEmailWithPdf({
  required String recipientEmail,
  required String subject,
  required String bodyText,
  required Uint8List pdfBytes,
  required String pdfFileName,
}) async {
  return sendEmailWithPdfImpl(
    recipientEmail: recipientEmail,
    subject: subject,
    bodyText: bodyText,
    pdfBytes: pdfBytes,
    pdfFileName: pdfFileName,
  );
}

/// Check if platform supports email with attachments
bool supportsEmailAttachments() {
  return !kIsWeb; // Mobile supports attachments, web does not via mailto
}
