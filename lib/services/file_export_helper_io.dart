import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String?> exportReportFile(Uint8List bytes, String filename) async {
  final directories = await _targetDirectories();
  final errors = <String>[];

  for (final directory in directories) {
    try {
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }

      final filePath = path.join(directory.path, filename);
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      if (!file.existsSync() || file.lengthSync() == 0) {
        throw FileSystemException('File rỗng sau khi ghi', file.path);
      }
      return file.path;
    } catch (e) {
      errors.add('${directory.path}: $e');
      continue;
    }
  }

  throw FileSystemException(
    'Không thể lưu file báo cáo ở các thư mục khả dụng. Chi tiết: ${errors.join(' | ')}',
  );
}

Future<List<Directory>> _targetDirectories() async {
  final targets = <Directory>[];

  // Priority 1: Standard Downloads folder (easiest for user to find)
  if (Platform.isAndroid) {
    targets.add(Directory('/storage/emulated/0/Download'));
  }

  // Priority 2: Downloads with app subdirectory
  if (Platform.isAndroid) {
    targets.add(Directory('/storage/emulated/0/Download/SmartSpendReports'));
  }

  // Priority 3: App documents directory
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      final appDocuments = await getApplicationDocumentsDirectory();
      targets.add(Directory(path.join(appDocuments.path, 'reports')));
    } catch (_) {}
  }

  // Priority 4: External storage fallback
  if (Platform.isAndroid) {
    try {
      final external = await getExternalStorageDirectory();
      if (external != null) {
        targets.add(Directory(path.join(external.path, 'reports')));
      }
    } catch (_) {}
  }

  // Priority 5: App support directory
  try {
    final appSupport = await getApplicationSupportDirectory();
    targets.add(Directory(path.join(appSupport.path, 'reports')));
  } catch (_) {}

  // Priority 6: Temporary directory (last resort)
  try {
    final temp = await getTemporaryDirectory();
    targets.add(Directory(path.join(temp.path, 'reports')));
  } catch (_) {}

  final uniqueTargets = <String, Directory>{};
  for (final target in targets) {
    uniqueTargets[target.path] = target;
  }

  return uniqueTargets.values.toList();
}
