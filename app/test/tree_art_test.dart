import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/engine_client.dart';
import 'package:pob_workshop/passive_tree.dart';
import 'package:pob_workshop/tree_art.dart';
import 'package:pob_workshop/main.dart';
import 'package:pob_workshop/workshop_shell.dart';
import 'package:pob_workshop/workshop_toolbar.dart';

void main() {
  testWidgets('Игровые текстуры отображаются на настоящем дереве', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final engine = EngineClient();
    addTearDown(engine.dispose);
    final root = Directory.current.parent.path;
    late Map<String, dynamic> detail;
    late Map<String, dynamic> snapshot;
    final data = await tester.runAsync(() async {
      final font = FontLoader('PreviewFont');
      font.addFont(
        Future.value(
          ByteData.sublistView(
            await File('${Platform.environment['WINDIR']}/Fonts/segoeui.ttf')
                .readAsBytes(),
          ),
        ),
      );
      await font.load();
      final config = jsonDecode(
        await File('.dart_tool/package_config.json').readAsString(),
      );
      final flutterUri =
          (config['packages'] as List).firstWhere(
                (p) => p['name'] == 'flutter',
              )['rootUri']
              as String;
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        Future.value(
          ByteData.sublistView(
            await File.fromUri(
              Uri.parse('$flutterUri/').resolve(
                '../../bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
              ),
            ).readAsBytes(),
          ),
        ),
      );
      await icons.load();
      await engine.start(root);
      await engine.request('loadBuild', {
        'xml': await File(
          '$root/app/docs/flutter/fixtures/fireball-basic/build.xml',
        ).readAsString(),
      });
      final art = await TreeArt.load('0_5');
      expect(art.length, greaterThan(500));
      snapshot = await engine.request('getSnapshot');
      final tree = await engine.request('getTree');
      final node = (tree['nodes'] as List).firstWhere(
        (n) => n['name'] == 'Melee Damage',
      );
      detail = await engine.request('getNodeTooltip', {'id': node['id']});
      return tree;
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: gruvbox(true).copyWith(
          textTheme: gruvbox(true).textTheme.apply(fontFamily: 'PreviewFont'),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: const ValueKey('tree-preview'),
              child: PassiveTree(
                data: data!,
                mapHeight: 750,
                onInspect: (_, compare) async => detail,
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
    await tester.enterText(find.byType(TextField), 'Melee Damage');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Melee Damage').first);
    await tester.pumpAndSettle();
    final point = tester
        .getRect(find.byKey(const ValueKey('tree-viewport')))
        .center;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: point - const Offset(40, 0));
    await mouse.moveTo(point);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('tree-preview')),
      matchesGoldenFile('goldens/tree-tooltip.png'),
    );
    await mouse.removePointer();
    tester.view.physicalSize = const Size(1600, 1000);
    for (final dark in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: gruvbox(dark).copyWith(
            textTheme: gruvbox(dark).textTheme.apply(fontFamily: 'PreviewFont'),
          ),
          home: RepaintBoundary(
            key: const ValueKey('shell-preview'),
            child: Scaffold(
              appBar: WorkshopToolbar(
                search: () {},
                importExport: () {},
                settings: () {},
                mode: dark ? ThemeMode.dark : ThemeMode.light,
                onTheme: (_) {},
              ),
              body: WorkshopShell(
                key: ValueKey(dark),
                section: 3,
                onSection: (_) {},
                output: Map<String, dynamic>.from(snapshot['output']),
                buildInfo: Map<String, dynamic>.from(snapshot['buildInfo']),
                tree: data,
                editor: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: PassiveTree(
                      key: ValueKey('tree-$dark'),
                      fillViewport: true,
                      data: data,
                      enabled: true,
                      onToggle: (_) async {},
                    ),
                  ),
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
        find.byKey(const ValueKey('shell-preview')),
        matchesGoldenFile('goldens/workshop-${dark ? 'dark' : 'light'}.png'),
      );
    }
  }, skip: !Platform.isWindows);
}
