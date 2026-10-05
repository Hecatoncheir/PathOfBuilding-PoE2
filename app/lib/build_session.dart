import 'dart:io';
import 'dart:convert';

import 'engine_client.dart';

class BuildSession {
  BuildSession(this.engine, this.recoveryFile);
  final EngineClient engine;
  final File recoveryFile;
  final _undo = <String>[];
  final _redo = <String>[];
  Map<String, dynamic> output = {};
  String? _savedXml;
  String? _currentXml;
  bool get hasUnsavedChanges => _currentXml != null && _currentXml != _savedXml;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  Future<String> export() async =>
      (await engine.request('exportBuild'))['xml'] as String;

  Future<void> open(String xml, {bool saved = true}) async {
    final result = await engine.request('loadBuild', {'xml': xml});
    output = result['output'] as Map<String, dynamic>;
    _undo.clear();
    _redo.clear();
    _currentXml = await export();
    _savedXml = saved ? _currentXml : null;
    await recoverSave();
  }

  Future<void> create(Map<String, dynamic> params) async {
    final result = await engine.request('createBuild', params);
    output = result['output'] as Map<String, dynamic>;
    _undo.clear();
    _redo.clear();
    _savedXml = null;
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
    final restoringSaved = from.last == _savedXml;
    final current = await export();
    final result = await engine.request('loadBuild', {'xml': from.last});
    from.removeLast();
    to.add(current);
    output = result['output'] as Map<String, dynamic>;
    await recoverSave();
    if (restoringSaved) _savedXml = _currentXml;
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
  Future<void> recoverSave() async {
    _currentXml = await export();
    await writeSafely(recoveryFile, _currentXml!);
  }

  void markSaved(String xml) {
    _savedXml = xml;
    _currentXml = xml;
  }

  Future<void> save(File file) async {
    final xml = await export();
    await writeSafely(file, xml);
    markSaved(xml);
  }

  static Future<String> readXml(File file) async {
    final handle = await file.open();
    try {
      if (await handle.length() > 4 * 1024 * 1024) {
        throw const FormatException('XML превышает лимит 4 MiB');
      }
      final bytes = await handle.read(4 * 1024 * 1024 + 1);
      if (bytes.length > 4 * 1024 * 1024) {
        throw const FormatException('XML превышает лимит 4 MiB');
      }
      return utf8.decode(bytes);
    } finally {
      await handle.close();
    }
  }

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
