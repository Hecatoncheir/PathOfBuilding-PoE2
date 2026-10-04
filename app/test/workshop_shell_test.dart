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
      for (final width in [390.0, 1000.0, 1600.0]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpWidget(
          MaterialApp(
            theme: gruvbox(dark),
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
        }
      }
    }
  });
}
