import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/engine_client.dart';
import 'package:pob_workshop/passive_tree.dart';
import 'package:pob_workshop/tree_art.dart';

void main() {
  testWidgets('Игровые текстуры отображаются на настоящем дереве', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final engine = EngineClient();
    addTearDown(engine.dispose);
    final root = Directory.current.parent.path;
    final data = await tester.runAsync(() async {
      await engine.start(root);
      await engine.request('loadBuild', {
        'xml': await File(
          '$root/docs/flutter/fixtures/fireball-basic/build.xml',
        ).readAsString(),
      });
      final art = await TreeArt.load('0_5');
      expect(art.length, greaterThan(500));
      return engine.request('getTree');
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: const ValueKey('tree-preview'),
              child: PassiveTree(
                data: data!,
                enabled: true,
                onToggle: (_) async {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Всё дерево'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const ValueKey('tree-preview')),
      matchesGoldenFile('goldens/game-tree.png'),
    );
  }, skip: !Platform.isWindows);
}
