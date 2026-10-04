import 'dart:io';

import 'engine_client.dart';

class BuildSession {
  BuildSession(this.engine, this.recoveryFile);
  final EngineClient engine;
  final File recoveryFile;
  final _undo = <String>[];
  final _redo = <String>[];
  Map<String, dynamic> output = {};
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  Future<String> export() async =>
      (await engine.request('exportBuild'))['xml'] as String;

  Future<void> open(String xml) async {
    final result = await engine.request('loadBuild', {'xml': xml});
    output = result['output'] as Map<String, dynamic>;
    _undo.clear();
    _redo.clear();
    await recoverSave();
  }

  Future<void> modify(String text) async {
    final previous = await export();
    final result = await engine.request('setCustomMods', {'text': text});
    output = result['output'] as Map<String, dynamic>;
    _undo.add(previous);
    if (_undo.length > 40) _undo.removeAt(0);
    _redo.clear();
    await recoverSave();
  }

  Future<void> _restore(List<String> from, List<String> to) async {
    if (from.isEmpty) return;
    final current = await export();
    final result = await engine.request('loadBuild', {'xml': from.last});
    from.removeLast();
    to.add(current);
    output = result['output'] as Map<String, dynamic>;
    await recoverSave();
  }

  Future<void> undo() => _restore(_undo, _redo);
  Future<void> toggleNode(int id) async {
    await treeAction({'id': id, 'action': 'toggle'});
  }

  Future<void> selectMainSkill(Map<String, dynamic> params) =>
      _changeTree('selectMainSkill', params);

  Future<void> treeAction(Map<String, dynamic> params) async {
    await _changeTree('treeAction', params);
  }

  Future<void> treeOptions(Map<String, dynamic> params) =>
      _changeTree('treeOptions', params);

  Future<void> _changeTree(String method, Map<String, dynamic> params) async {
    final previous = await export();
    final result = await engine.request(method, params);
    output = result['output'] as Map<String, dynamic>;
    if (method == 'treeOptions' &&
        params.keys.every((key) => key == 'mode' || key == 'compare')) {
      return;
    }
    _undo.add(previous);
    if (_undo.length > 40) _undo.removeAt(0);
    _redo.clear();
    await recoverSave();
  }

  Future<void> redo() => _restore(_redo, _undo);
  Future<void> recoverSave() async => writeSafely(recoveryFile, await export());
  Future<void> save(File file) async => writeSafely(file, await export());

  static Future<void> writeSafely(File file, String text) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.pending');
    final backup = File('${file.path}.bak');
    await temporary.writeAsString(text, flush: true);
    if (await file.exists()) await file.copy(backup.path);
    // Windows rename заменяет существующий файл; копия остаётся для восстановления.
    await temporary.rename(file.path);
  }
}
