import 'dart:async';
import 'dart:convert';
import 'dart:io';

class EngineClient {
  Process? _process;
  final _pending = <String, Completer<Map<String, dynamic>>>{};
  int _counter = 0;
  int revision = 0;
  Future<void> start(String root) async {
    _process = await Process.start('python', [
      '-X',
      'utf8',
      'app/tools/run_headless.py',
      'app/tools/headless_server.lua',
    ], workingDirectory: root);
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          _receive,
          onError: _fail,
          onDone: () => _fail(StateError('Движок завершился')),
        );
    _process!.stderr
        .transform(const Utf8Decoder(allowMalformed: true))
        .listen(stderr.write);
    await request('initialize');
  }

  void _receive(String line) {
    try {
      final response = jsonDecode(line) as Map<String, dynamic>;
      final pending = _pending.remove(response['id']);
      if (pending == null) return;
      if (response['error'] != null) {
        pending.completeError(
          StateError(response['error']['message'] as String),
        );
        return;
      }
      revision = response['revision'] as int;
      pending.complete(response['result'] as Map<String, dynamic>);
    } catch (error) {
      _fail(error);
    }
  }

  void _fail(Object error) {
    for (final pending in _pending.values) {
      if (!pending.isCompleted) pending.completeError(error);
    }
    _pending.clear();
  }

  Future<Map<String, dynamic>> request(
    String method, [
    Map<String, dynamic>? params,
  ]) async {
    final process = _process;
    if (process == null) throw StateError('Движок не запущен');
    final id = '${++_counter}';
    final pending = Completer<Map<String, dynamic>>();
    _pending[id] = pending;
    try {
      process.stdin.writeln(
        jsonEncode({
          'protocol': 1,
          'id': id,
          'method': method,
          'params': {'revision': revision, ...?params},
        }),
      );
      return await pending.future.timeout(const Duration(seconds: 30));
    } finally {
      _pending.remove(id);
    }
  }

  void dispose() {
    _fail(StateError('Клиент закрыт'));
    _process?.kill();
    _process = null;
  }
}
