import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

Future<String?> saveFile(Uint8List bytes, String fileName, String mimeType) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  html.Url.revokeObjectUrl(url);
  return fileName;
}
