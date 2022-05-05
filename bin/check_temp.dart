import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart';

const commentsToCheck = ['//remove', '//temp'];

class FoundData {
  final File file;
  final int lineNumber;

  const FoundData({
    required this.file,
    required this.lineNumber,
  });
}

Future<void> main(List<String> arguments) async {
  final dirPath = arguments.firstOrNull;
  if (dirPath == null) {
    print('No directory provided');
    exit(1);
  }

  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    print('Directory does not exist');
    exit(1);
  }

  final allFiles = await dir.list(recursive: true, followLinks: true).toList();
  final filesFoundWithTemp = <FoundData>[];
  for (final fileEntity in allFiles) {
    final name = basename(fileEntity.path);
    final ext = extension(name);
    if (ext != '.dart') continue;

    final file = File(fileEntity.path);
    final contents = await file.readAsLines();
    for (int i = 0; i < contents.length; i++) {
      final line = contents[i];
      final lineContent = line.replaceAll(RegExp(r'\s'), '').toLowerCase();
      if (commentsToCheck.any(lineContent.startsWith)) {
        filesFoundWithTemp.add(
          FoundData(file: file, lineNumber: i + 1),
        );
      }
    }
  }

  if (filesFoundWithTemp.isEmpty) {
    print('No temp comments found');
    exit(0);
  }

  for (final file in filesFoundWithTemp) {
    print('${file.file.absolute.path} at line number ${file.lineNumber}\n');
  }

  exit(1);
}
