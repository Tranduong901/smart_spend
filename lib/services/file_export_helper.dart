import 'dart:typed_data';

import 'file_export_helper_stub.dart'
    if (dart.library.io) 'file_export_helper_io.dart'
    if (dart.library.html) 'file_export_helper_web.dart' as impl;

Future<String?> exportReportFile(Uint8List bytes, String filename) {
  return impl.exportReportFile(bytes, filename);
}
