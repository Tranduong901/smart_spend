import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String?> exportReportFile(Uint8List bytes, String filename) async {
  final directories = await _targetDirectories();

  for (final directory in directories) {
    try {
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      final filePath = path.join(directory.path, filename);
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      continue;
    }
  }

  throw FileSystemException('Không thể lưu file báo cáo.');
}

Future<List<Directory>> _targetDirectories() async {
  final targets = <Directory>[];

  if (Platform.isAndroid) {
    targets.add(Directory('/storage/emulated/0/Download/SmartSpendReports'));
  }

  final external = await getExternalStorageDirectory();
  if (external != null) {
    targets.add(Directory(path.join(external.path, 'reports')));
  }

  final appDocuments = await getApplicationDocumentsDirectory();
  targets.add(Directory(path.join(appDocuments.path, 'reports')));

  return targets;
}
