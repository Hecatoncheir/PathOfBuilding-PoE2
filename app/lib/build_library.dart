import 'dart:io';
import 'dart:convert';

import 'build_session.dart';

class BuildLibrary {
  BuildLibrary(this.root);
  final Directory root;
  Future<void> _historyWrite = Future.value();
  File get recentFile => File('${root.path}/recent.json');

  Future<List<File>> recent() async {
    if (!await recentFile.exists()) return [];
    final data = jsonDecode(await recentFile.readAsString()) as Map;
    if (data['version'] != 1 || data['paths'] is! List) {
      throw const FormatException('Неизвестный формат списка недавних сборок');
    }
    return (data['paths'] as List)
        .whereType<String>()
        .take(12)
        .map(File.new)
        .toList();
  }

  Future<void> remember(File file, {File? previous}) {
    final operation = _historyWrite.then((_) async {
      final path = file.absolute.path;
      final removed = {
        path.toLowerCase(),
        if (previous != null) previous.absolute.path.toLowerCase(),
      };
      final paths = [
        path,
        for (final entry in await recent())
          if (!removed.contains(entry.absolute.path.toLowerCase()))
            entry.absolute.path,
      ].take(12).toList();
      await BuildSession.writeSafely(
        recentFile,
        jsonEncode({'version': 1, 'paths': paths}),
      );
    });
    _historyWrite = operation.catchError((Object _) {});
    return operation;
  }

  static BuildLibrary local() => BuildLibrary(
    Directory(
      '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}/PathOfBuildingWorkshop/builds',
    ),
  );

  String destination(String folder, String name) {
    for (final value in [folder, name]) {
      if (value.isNotEmpty &&
          (value.trim() != value ||
              value == '.' ||
              value == '..' ||
              RegExp(r'[\\/:*?"<>|\x00-\x1f]').hasMatch(value) ||
              value.endsWith('.') ||
              value.length > 100 ||
              RegExp(
                r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)',
                caseSensitive: false,
              ).hasMatch(value))) {
        throw const FormatException('Недопустимое имя файла или папки');
      }
    }
    if (name.isEmpty) throw const FormatException('Укажите название сборки');
    return '${root.path}/${folder.isEmpty ? '' : '$folder/'}$name.xml';
  }

  Future<List<File>> list() async {
    await root.create(recursive: true);
    final files = <File>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.xml')) {
        files.add(entity);
      }
    }
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    return files;
  }

  String relative(File file) =>
      file.path.substring(root.path.length + 1).replaceAll('\\', '/');

  Future<File> save(String folder, String name, String xml) async {
    final target = File(destination(folder, name));
    if (await target.exists()) {
      throw const FileSystemException('Сборка с таким именем уже существует');
    }
    await BuildSession.writeSafely(target, xml);
    return target;
  }

  Future<File> copy(File source, String folder, String name) async =>
      save(folder, name, await source.readAsString());

  Future<File> rename(File source, String folder, String name) async {
    final target = File(destination(folder, name));
    if (await target.exists()) {
      throw const FileSystemException('Сборка с таким именем уже существует');
    }
    await target.parent.create(recursive: true);
    return source.rename(target.path);
  }
}
