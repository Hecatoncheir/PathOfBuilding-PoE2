import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/ui_preferences.dart';
import 'package:pob_workshop/main.dart';

void main() {
  test(
    'Настройки сохраняются последовательно и переживают перезапуск',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'pob-ui-settings',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/settings.json');
      final settings = UiPreferences(file);
      expect(settings.readTheme(), ThemeMode.dark);
      await file.writeAsString('{broken');
      expect(settings.readTheme(), ThemeMode.dark);
      await file.writeAsString('{"unknown":42}');
      await Future.wait([
        settings.saveTheme(ThemeMode.light),
        settings.savePanel(false),
        settings.saveTheme(ThemeMode.system),
        settings.saveLanguage('en'),
        settings.saveReducedMotion(true),
        settings.saveWidths(260, 340),
      ]);
      final restored = UiPreferences(file);
      expect(restored.readTheme(), ThemeMode.system);
      expect(restored.readPanel(), false);
      expect(restored.readLanguage(), 'en');
      expect(restored.readReducedMotion(), true);
      expect(restored.readWidth('navigationWidth', 220), 260);
      expect(restored.readWidth('pulseWidth', 286), 340);
      expect(await file.readAsString(), contains('"unknown":42'));
    },
  );

  testWidgets('Системная тема реагирует на смену яркости платформы', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    var mode = ThemeMode.system;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          theme: gruvbox(false),
          darkTheme: gruvbox(true),
          themeMode: mode,
          home: Scaffold(
            body: ThemeMenu(
              mode: mode,
              onSelected: (value) => setState(() => mode = value),
            ),
          ),
        ),
      ),
    );
    Brightness brightness() =>
        Theme.of(tester.element(find.byType(ThemeMenu))).brightness;
    expect(brightness(), Brightness.light);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);
    await tester.tap(find.byTooltip('Выбрать тему'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckedPopupMenuItem<ThemeMode>).at(1));
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);
  });
}
