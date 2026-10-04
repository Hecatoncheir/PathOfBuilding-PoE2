import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/build_session.dart';
import 'package:pob_workshop/engine_client.dart';

void main() {
  test('Основное умение выбирает Lua, выбор переживает отмену и XML', () async {
    final engine = EngineClient();
    addTearDown(engine.dispose);
    final root = Directory.current.parent.path;
    await engine.start(root);
    final fixture = await File(
      '$root/app/docs/flutter/fixtures/fireball-basic/build.xml',
    ).readAsString();
    final group = RegExp(
      r'<Skill enabled=.*?</Skill>',
      dotAll: true,
    ).firstMatch(fixture)!.group(0)!;
    final xml = fixture.replaceFirst(
      group,
      '$group\n${group.replaceFirst('label=""', 'label="Вторая группа"')}',
    );
    final temporary = await Directory.systemTemp.createTemp('pob-build-info');
    addTearDown(() => temporary.delete(recursive: true));
    final session = BuildSession(engine, File('${temporary.path}/session.xml'));
    await session.open(xml);
    final before = await engine.request('getSnapshot');
    expect(before['buildInfo']['class'], 'Ranger');
    expect(before['buildInfo']['groups']['entries'], hasLength(2));
    expect(before['buildInfo']['skills']['entries'], isNotEmpty);
    await session.selectMainSkill({'control': 'groups', 'id': 2});
    expect(
      (await engine.request('getSnapshot'))['buildInfo']['groups']['selected'],
      2,
    );
    expect(await session.export(), contains('mainSocketGroup="2"'));
    await session.undo();
    expect(
      (await engine.request('getSnapshot'))['buildInfo']['groups']['selected'],
      1,
    );
    await session.redo();
    expect(
      (await engine.request('getSnapshot'))['buildInfo']['groups']['selected'],
      2,
    );
    final saved = await session.export();
    await expectLater(
      engine.request('selectMainSkill', {'control': 'groups', 'id': 999}),
      throwsA(isA<StateError>()),
    );
    expect(await session.export(), saved);
  });
}
