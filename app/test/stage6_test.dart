import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/build_library.dart';
import 'package:pob_workshop/build_session.dart';
import 'package:pob_workshop/engine_client.dart';
import 'package:pob_workshop/new_build_dialog.dart';

void main() {
  test('Недавние файлы сохраняются, переставляются и обновляются при переименовании', () async {
    final dir = await Directory.systemTemp.createTemp('pob-recent-');
    addTearDown(() => dir.delete(recursive: true));
    final library = BuildLibrary(dir);
    for (var index = 0; index < 15; index++) {
      await library.remember(File('${dir.path}/$index.xml'));
    }
    await library.remember(File('${dir.path}/8.xml'));
    final recent = await BuildLibrary(dir).recent();
    expect(recent, hasLength(12));
    expect(recent.first.path, endsWith('8.xml'));
    expect(recent.where((file) => file.path.endsWith('/8.xml')), hasLength(1));
    await library.remember(
      File('${dir.path}/renamed.xml'),
      previous: File('${dir.path}/8.xml'),
    );
    expect(
      (await library.recent()).any((file) => file.path.endsWith('/8.xml')),
      false,
    );
  });

  test(
    'Новая сборка создаётся в Lua, несохранённость переживает ошибки и историю',
    () async {
      final dir = await Directory.systemTemp.createTemp('pob-dirty-');
      addTearDown(() => dir.delete(recursive: true));
      final engine = EngineClient();
      addTearDown(engine.dispose);
      await engine.start(Directory.current.parent.path);
      final session = BuildSession(engine, File('${dir.path}/recovery.xml'));
      await session.create({'name': 'Новая', 'level': 90, 'classId': 7});
      expect(session.hasUnsavedChanges, true);
      expect((await engine.request('getSnapshot'))['buildInfo']['level'], 90);
      final saved = File('${dir.path}/saved.xml');
      await session.save(saved);
      expect(session.hasUnsavedChanges, false);
      await session.modify('+100 to maximum Life');
      expect(session.hasUnsavedChanges, true);
      await session.undo();
      expect(session.hasUnsavedChanges, false);
      await session.redo();
      expect(session.hasUnsavedChanges, true);
      await expectLater(
        session.save(File(dir.path)),
        throwsA(isA<FileSystemException>()),
      );
      expect(session.hasUnsavedChanges, true);
      await session.open(await session.export(), saved: false);
      expect(session.hasUnsavedChanges, true);
      final recovery = await BuildSession.readXml(session.recoveryFile);
      expect(recovery, contains('<PathOfBuilding2>'));
    },
    skip: !Platform.isWindows,
  );

  test('Слишком большой XML отклоняется до загрузки в память и Lua', () async {
    final dir = await Directory.systemTemp.createTemp('pob-limit-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/large.xml');
    final handle = await file.open(mode: FileMode.write);
    await handle.truncate(4 * 1024 * 1024 + 1);
    await handle.close();
    await expectLater(BuildSession.readXml(file), throwsFormatException);
  });

  testWidgets('Создание: имя и корректный уровень обязательны', (tester) async {
    Map<String, dynamic>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (_) => const NewBuildDialog(
                  classes: [
                    {'id': 7, 'name': 'Sorceress'},
                  ],
                ),
              );
            },
            child: const Text('Открыть'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Создать'))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField).first, 'Искра');
    await tester.enterText(find.byType(TextField).last, '101');
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Создать'))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField).last, '90');
    await tester.pump();
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();
    expect(result, {'name': 'Искра', 'level': 90, 'classId': 7});
  });

  testWidgets(
    'Предупреждение позволяет отменить замену; черновик не выдаётся за сохранённый XML',
    (tester) async {
      String? choice;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                choice = await confirmBuildReplacement(context, hasDraft: true);
              },
              child: const Text('Открыть'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'В полях есть неприменённый текст. Сохранение XML его не включает.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Сохранить'), findsNothing);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(choice, 'cancel');
    },
  );
}
