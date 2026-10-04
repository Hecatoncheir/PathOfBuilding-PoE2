import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/engine_client.dart';

void main() {
  test(
    'Подсказка Lua не меняет сборку, атрибуты и заметки переживают XML',
    () async {
      final engine = EngineClient();
      addTearDown(engine.dispose);
      final root = Directory.current.parent.path;
      await engine.start(root);
      await engine.request('loadBuild', {
        'xml': await File(
          '$root/app/docs/flutter/fixtures/fireball-basic/build.xml',
        ).readAsString(),
      });
      final tree = await engine.request('getTree');
      final nodes = (tree['nodes'] as List).cast<Map<String, dynamic>>();
      final node = nodes.firstWhere(
        (n) => n['isAttribute'] == true && (n['path'] as List).isNotEmpty,
      );
      final id = node['id'];
      final before = (await engine.request('exportBuild'))['xml'];
      final revision = engine.revision;
      final tooltip = await engine.request('getNodeTooltip', {'id': id});
      expect(tooltip['lines'], isNotEmpty);
      expect(
        (tooltip['lines'] as List).any(
          (line) => (line['text'] as String? ?? '').contains('Allocating'),
        ),
        isTrue,
      );
      expect((await engine.request('exportBuild'))['xml'], before);
      expect(engine.revision, revision);
      await engine.request('treeAction', {
        'id': id,
        'action': 'allocate',
        'attribute': 1,
      });
      await engine.request('treeAction', {'id': id, 'action': 'right'});
      final changed = await engine.request('getTree');
      final attribute = (changed['nodes'] as List).firstWhere(
        (n) => n['id'] == id,
      );
      expect(attribute['allocated'], isTrue);
      expect(attribute['name'], 'Dexterity');
      await engine.request('treeAction', {
        'id': id,
        'action': 'note',
        'text': 'Проверка заметки',
      });
      final xml = (await engine.request('exportBuild'))['xml'];
      await engine.request('loadBuild', {'xml': xml});
      final restored = await engine.request('getTree');
      expect(
        (restored['nodes'] as List).firstWhere((n) => n['id'] == id)['note'],
        'Проверка заметки',
      );
      await expectLater(
        engine.request('treeAction', {
          'id': id,
          'action': 'allocate',
          'attribute': 4,
        }),
        throwsStateError,
      );
      final current = await engine.request('getTree');
      final socket = (current['nodes'] as List).firstWhere(
        (n) => n['type'] == 'Socket' && (n['path'] as List).isNotEmpty,
      );
      final socketId = socket['id'];
      await engine.request('treeAction', {
        'id': socketId,
        'action': 'allocate',
      });
      await engine.request('treeAction', {
        'id': socketId,
        'action': 'jewel',
        'raw': 'Rarity: Magic\nRuby\n--------\n10% increased Fire Damage',
      });
      final jewels = await engine.request('getJewels', {'id': socketId});
      expect(jewels['selected'], greaterThan(0));
      expect(jewels['items'], isNotEmpty);
      expect(
        (await engine.request('getNodeTooltip', {'id': socketId}))['lines'],
        isNotEmpty,
      );
      await engine.request('treeOptions', {'mode': 1});
      await expectLater(
        engine.request('treeAction', {'id': socketId, 'action': 'refund'}),
        throwsStateError,
      );
      expect((await engine.request('getTree'))['mode'], 1);
      await engine.request('treeOptions', {'mode': 0});
      await engine.request('treeAction', {
        'id': socketId,
        'action': 'jewel',
        'item': 0,
      });
      expect(
        (await engine.request('getJewels', {'id': socketId}))['selected'],
        0,
      );
      final notable = nodes.firstWhere((n) => n['type'] == 'Notable');
      expect(
        (await engine.request('getNodeTooltip', {
          'id': notable['id'],
        }))['lines'],
        isNotEmpty,
      );
      final existing = await engine.request('getTree');
      final oldSpec = existing['activeSpec'];
      await engine.request('treeOptions', {
        'specAction': 'clone',
        'name': 'Проверка копии',
      });
      final cloned = await engine.request('getTree');
      expect(
        (cloned['specs'] as List).length,
        (existing['specs'] as List).length + 1,
      );
      await engine.request('treeOptions', {'compare': oldSpec});
      await engine.request('treeAction', {'id': id, 'action': 'refund'});
      final compared = await engine.request('getTree');
      expect(
        (compared['nodes'] as List).firstWhere(
          (n) => n['id'] == id,
        )['compareAllocated'],
        isTrue,
      );
      await engine.request('treeOptions', {'compare': 0});
      await engine.request('treeOptions', {'specAction': 'delete'});
      expect((await engine.request('getTree'))['activeSpec'], oldSpec);
    },
    skip: !Platform.isWindows,
  );
}
