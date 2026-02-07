/*
 * Email Helper - Web Implementation
 * Downloads PDF then opens email client
 * (Web mailto doesn't support attachments, so we provide two-step process)
 */

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

Future<bool> sendEmailWithPdfImpl({
  required String recipientEmail,
  required String subject,
  required String bodyText,
  required Uint8List pdfBytes,
  required String pdfFileName,
}) async {
  try {
    // Step 1: Download the PDF
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', pdfFileName)
      ..style.display = 'none';

    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    // Step 2: Open mailto with the provided body (no extra wrapping to avoid repetition)
    // Add a note about attaching the downloaded PDF since web mailto doesn't support attachments
    final webBody = '''$bodyText

Note: Please attach the PDF file that was just downloaded to this email.''';

    final mailtoUrl = 'mailto:$recipientEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(webBody)}';
    html.window.open(mailtoUrl, '_blank');

    return true;
  } catch (e) {
    print('Web email error: $e');
    return false;
  }
}
