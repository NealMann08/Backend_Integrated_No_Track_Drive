/*
 * PDF Helper - Web Implementation
 * Uses dart:html to create blob download for web platform
 */

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

Future<bool> savePdfImpl(Uint8List pdfBytes, String fileName) async {
  try {
    // Create a blob from the PDF bytes
    final blob = html.Blob([pdfBytes], 'application/pdf');

    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    // Add to document, click, and remove
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);

    // Cleanup the URL
    html.Url.revokeObjectUrl(url);

    return true;
  } catch (e) {
    print('Web PDF save error: $e');
    return false;
  }
}
