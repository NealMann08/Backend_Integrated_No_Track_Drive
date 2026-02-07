/*
 * PDF Helper - Mobile Implementation
 * Uses path_provider and share_plus for iOS/Android
 */

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<bool> savePdfImpl(Uint8List pdfBytes, String fileName) async {
  try {
    // Get the temporary directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');

    // Write the PDF bytes to file
    await file.writeAsBytes(pdfBytes);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'My Driving Safety Report',
    );

    return true;
  } catch (e) {
    print('Mobile PDF save error: $e');
    return false;
  }
}
