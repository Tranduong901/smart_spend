import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> exportReportFile(Uint8List bytes, String filename) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final link = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;

  html.document.body!.children.add(link);
  link.click();
  html.document.body!.children.remove(link);
  html.Url.revokeObjectUrl(url);

  return null;
}
