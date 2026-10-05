import 'package:pob_workshop/build_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/design_theme.dart';
import 'package:pob_workshop/main.dart';
import 'package:pob_workshop/passive_tree.dart';
import 'package:pob_workshop/ui_text.dart';
import 'package:pob_workshop/workshop_components.dart';
import 'package:pob_workshop/workshop_shell.dart';
import 'package:pob_workshop/workshop_toolbar.dart';
import 'package:pob_workshop/ui_preferences.dart';

import 'dart:io';

double contrast(Color a, Color b) {
  final values = [a.computeLuminance(), b.computeLuminance()]..sort();
  return (values.last + .05) / (values.first + .05);
}

const smallTree = {
  'version': 'test',
  'edges': <List<int>>[],
  'nodes': [
    {
      'id': 1,
      'x': 0,
      'y': 0,
      'name': 'Start',
      'type': 'ClassStart',
      'allocated': true,
      'stats': <String>[],
    },
    {
      'id': 2,
      'x': 100,
      'y': 100,
      'name': 'Fire damage',
      'type': 'Notable',
      'allocated': false,
      'stats': ['10% increased Fire Damage'],
    },
  ],
};

void main() {
  testWidgets('Уменьшение движения применяет масштаб сразу', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: gruvbox(true),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: PassiveTree(
            fillViewport: true,
            data: smallTree,
            enabled: true,
            onToggle: (_) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final scale = viewer.transformationController!.value.getMaxScaleOnAxis();
    await tester.tap(find.byTooltip('Увеличить дерево'));
    await tester.pump();
    expect(
      viewer.transformationController!.value.getMaxScaleOnAxis(),
      closeTo(scale * 1.3, .001),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Переключение языка обновляет диалоги и общие элементы', (
    tester,
  ) async {
    var language = 'ru';
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return MaterialApp(
            builder: (context, child) =>
                WorkshopLocale(language: language, child: child!),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () =>
                      showInterfaceSettings(context, language, false),
                  child: Text(tr(context, 'Настройки интерфейса')),
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.tap(find.text('Настройки интерфейса'));
    await tester.pumpAndSettle();
    update(() => language = 'en');
    await tester.pumpAndSettle();
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Все разделы оболочки доступны через поиск на телефоне', (
    tester,
  ) async {
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('pob-stage5'),
    ))!;
    final settings = UiPreferences(File('${directory.path}/settings.json'));
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      WorkshopApp(
        connectEngine: false,
        preferences: settings,
        buildLibrary: BuildLibrary(Directory("${directory.path}/builds")),
      ),
    );
    await tester.pumpAndSettle();
    for (final section in workshopSections) {
      await tester.tap(find.byTooltip('Поиск раздела · Ctrl+K'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(TextField),
        ),
        section,
      );
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.widgetWithText(ListTile, section),
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.text(section), findsWidgets);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => directory.delete(recursive: true));
  });

  testWidgets('Общие карточки, таблицы и выбор доступны на узком экране', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: gruvbox(false),
        home: Scaffold(
          body: ListView(
            children: [
              const WorkshopItemCard(
                item: {'name': 'Ruby', 'base': 'Ruby', 'rarity': 'NORMAL'},
              ),
              WorkshopSelect<int>(
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Default')),
                ],
                initialValue: 1,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ruby'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  test('Контраст всех основных текстовых состояний не ниже 4.5:1', () {
    for (final dark in [true, false]) {
      final theme = gruvbox(dark);
      final tokens = theme.extension<WorkshopColors>()!;
      for (final surface in [
        theme.scaffoldBackgroundColor,
        theme.colorScheme.surface,
        tokens.raised,
      ]) {
        for (final text in [
          theme.colorScheme.onSurface,
          tokens.muted,
          theme.colorScheme.primary,
          tokens.gold,
          theme.colorScheme.error,
        ]) {
          expect(contrast(text, surface), greaterThanOrEqualTo(4.5));
        }
      }
      expect(
        contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets(
    'Оболочка и реальное устройство ввода: обе темы, языки и ориентации',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final language in ['ru', 'en']) {
        for (final dark in [false, true]) {
          for (final size in [
            const Size(360, 740),
            const Size(390, 844),
            const Size(768, 1024),
            const Size(1024, 768),
            const Size(1440, 900),
            const Size(740, 360),
          ]) {
            tester.view.physicalSize = size;
            await tester.pumpWidget(
              MaterialApp(
                theme: gruvbox(dark),
                builder: (context, child) => WorkshopLocale(
                  language: language,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.5),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                ),
                home: Scaffold(
                  appBar: WorkshopToolbar(
                    search: () {},
                    importExport: () {},
                    settings: () {},
                    mode: ThemeMode.dark,
                    onTheme: (_) {},
                  ),
                  body: WorkshopShell(
                    key: ValueKey('$language-$dark-$size'),
                    section: 3,
                    onSection: (_) {},
                    output: const {'TotalDPS': 128450, 'Life': 2840},
                    tree: null,
                    editor: Expanded(
                      child: PassiveTree(
                        fillViewport: true,
                        data: smallTree,
                        enabled: true,
                        onToggle: (_) async {},
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$language $dark $size',
            );
            final viewport = find.byKey(const ValueKey('tree-viewport'));
            expect(tester.getSize(viewport).height, greaterThan(30));
            final old = tester.getRect(viewport);
            await tester.dragFrom(old.center, const Offset(10, 10));
            await tester.pumpAndSettle();
            expect(tester.getRect(viewport), old);
            expect(tester.takeException(), isNull);
          }
        }
      }
    },
  );

  testWidgets('Изменение ширины панелей работает мышью и сохраняет значения', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    double? navigation, pulse;
    await tester.pumpWidget(
      MaterialApp(
        theme: gruvbox(true),
        home: Scaffold(
          body: WorkshopShell(
            section: 3,
            onSection: (_) {},
            output: const {},
            tree: null,
            onWidths: (a, b) {
              navigation = a;
              pulse = b;
            },
            editor: const Expanded(child: Center(child: Text('Editor'))),
          ),
        ),
      ),
    );
    await tester.drag(
      find.byType(PanelResizeHandle).first,
      const Offset(30, 0),
    );
    await tester.pumpAndSettle();
    expect(navigation, greaterThan(220));
    await tester.drag(
      find.byType(PanelResizeHandle).last,
      const Offset(-30, 0),
    );
    await tester.pumpAndSettle();
    expect(pulse, greaterThan(286));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Глобальные команды, порядок фокуса и сенсорные цели', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    var searched = 0, saved = 0, undone = 0, redone = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: gruvbox(true),
        home: WorkshopShortcuts(
          search: () => searched++,
          save: () => saved++,
          undo: () => undone++,
          redo: () => redone++,
          child: Scaffold(
            appBar: WorkshopToolbar(
              search: () => searched++,
              importExport: () {},
              settings: () {},
              mode: ThemeMode.dark,
              onTheme: (_) {},
            ),
            body: const Focus(autofocus: true, child: SizedBox()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    for (final key in [
      LogicalKeyboardKey.keyK,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyZ,
      LogicalKeyboardKey.keyY,
    ]) {
      await tester.sendKeyEvent(key);
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect([searched, saved, undone, redone], [1, 1, 1, 1]);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(FocusManager.instance.primaryFocus?.context, isNotNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('Формат чисел зависит от языка, игровые названия сохраняются', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WorkshopLocale(
          language: 'en',
          child: Builder(
            builder: (context) => Text(
              '${tr(context, 'Дерево')} ${formatUiNumber(context, 128450.5)} ${tr(context, 'Fireball')}',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Passive tree 128,450.50 Fireball'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: WorkshopLocale(
          language: 'ru',
          child: Builder(
            builder: (context) => Text(formatUiNumber(context, 128450.5)),
          ),
        ),
      ),
    );
    expect(find.text('128\u202f450,50'), findsOneWidget);
  });
}
