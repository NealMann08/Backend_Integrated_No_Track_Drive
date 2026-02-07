/*
 * Email Helper - Mobile Implementation
 * Uses share_plus to share PDF via email apps with attachment
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<bool> sendEmailWithPdfImpl({
  required String recipientEmail,
  required String subject,
  required String bodyText,
  required Uint8List pdfBytes,
  required String pdfFileName,
}) async {
  try {
    // Save PDF to temporary directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$pdfFileName');
    await file.writeAsBytes(pdfBytes);

    // Share via email with PDF attachment
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: bodyText,
    );

    return true;
  } catch (e) {
    print('Mobile email error: $e');
    return false;
  }
}
