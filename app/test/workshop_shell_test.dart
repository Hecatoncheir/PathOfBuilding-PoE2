import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/main.dart';
import 'package:pob_workshop/workshop_shell.dart';

void main() {
  testWidgets('Оболочка работает в обеих темах и на разных экранах', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final dark in [true, false]) {
      for (final width in [360.0, 390.0, 768.0, 1024.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpWidget(
          MaterialApp(
            theme: gruvbox(dark),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: Scaffold(
              body: WorkshopShell(
                section: 3,
                onSection: (_) {},
                output: const {},
                tree: null,
                editor: const Expanded(child: Center(child: Text('Карта'))),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (width >= 1250) {
          expect(find.text('ПУЛЬС СБОРКИ'), findsOneWidget);
          expect(find.text('—'), findsWidgets);
          await tester.tap(find.byTooltip('Скрыть показатели'));
          await tester.pumpAndSettle();
          expect(find.text('ПУЛЬС СБОРКИ'), findsNothing);
          await tester.tap(find.byTooltip('Показать показатели'));
          await tester.pumpAndSettle();
          expect(find.text('ПУЛЬС СБОРКИ'), findsOneWidget);
        } else {
          await tester.tap(find.byTooltip('Показать показатели'));
          await tester.pumpAndSettle();
          expect(find.text('ПУЛЬС СБОРКИ'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        }
      }
    }
  });
  testWidgets('Открытая панель обновляется после ответа движка', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late StateSetter update;
    var dps = 100;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Scaffold(
              body: WorkshopShell(
                section: 3,
                onSection: (_) {},
                output: {'TotalDPS': dps},
                tree: null,
                editor: const Expanded(child: SizedBox()),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.byTooltip('Показать показатели'));
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
    update(() => dps = 200);
    await tester.pumpAndSettle();
    expect(find.text('200'), findsOneWidget);
    expect(find.text('100'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
