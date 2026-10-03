import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/engine_client.dart';
import 'package:pob_workshop/build_session.dart';

void main() {
  test(
    'Сессия отменяет изменения и сохраняет XML с резервной копией',
    () async {
      final directory = await Directory.systemTemp.createTemp('pob-session-');
      addTearDown(() => directory.delete(recursive: true));
      final root = Directory.current.parent.path;
      final engine = EngineClient();
      addTearDown(engine.dispose);
      await engine.start(root);
      final session = BuildSession(
        engine,
        File('${directory.path}/recovery.xml'),
      );
      await session.open(
        await File('$root/docs/flutter/fixtures/fireball-basic/build.xml')
            .readAsString(),
      );
      final initial = session.output['TotalDPS'] as num;
      await session.modify('100% increased Spell Damage');
      expect(session.output['TotalDPS'], closeTo(initial * 2, 1e-6));
      await session.undo();
      expect(session.output['TotalDPS'], closeTo(initial, 1e-6));
      await session.redo();
      expect(session.output['TotalDPS'], closeTo(initial * 2, 1e-6));
      final saved = File('${directory.path}/build.xml');
      await session.save(saved);
      final original = await saved.readAsString();
      await session.undo();
      await session.save(saved);
      expect(await File('${saved.path}.bak').readAsString(), original);
      await session.open(await session.recoveryFile.readAsString());
      expect(session.output['TotalDPS'], closeTo(initial, 1e-6));
    },
    skip: !Platform.isWindows,
  );
  test('Lua-клиент пересчитывает реальную сборку', () async {
    final root = Directory.current.parent.path;
    final engine = EngineClient();
    addTearDown(engine.dispose);
    await engine.start(root);
    final result = await engine.request('loadBuild', {
      'xml': await File('$root/docs/flutter/fixtures/fireball-basic/build.xml')
          .readAsString(),
    });
    final dps = result['output']['TotalDPS'] as num;
    final modified = await engine.request('setCustomMods', {
      'text': '100% increased Spell Damage',
    });
    expect(modified['output']['TotalDPS'], closeTo(dps * 2, 1e-6));
    await expectLater(
      engine.request('getSnapshot', {'revision': 0}),
      throwsStateError,
    );
    expect(engine.revision, 2);
    expect(
      (await engine.request('exportBuild'))['xml'],
      contains('<PathOfBuilding2>'),
    );
  }, skip: !Platform.isWindows);
}
