import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/passive_tree.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Мышь, подсказка и атрибуты: $brightness', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final actions = <Map<String, dynamic>>[];
      final history = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: SingleChildScrollView(
              child: PassiveTree(
                enabled: true,
                onHistory: (redo) async => history.add(redo),
                onToggle: (_) async {},
                onAction: (params) async => actions.add(params),
                onInspect: (_, compare) async => {
                  'lines': [
                    {'text': '^2+10 здоровья', 'size': 14},
                  ],
                },
                data: {
                  'version': 'test',
                  'edges': [
                    [1, 2],
                  ],
                  'nodes': [
                    {
                      'id': 1,
                      'x': 0,
                      'y': 0,
                      'name': 'Старт',
                      'type': 'ClassStart',
                      'allocated': true,
                      'stats': <String>[],
                    },
                    {
                      'id': 2,
                      'x': 1000,
                      'y': 1000,
                      'name': 'Атрибут',
                      'type': 'Normal',
                      'allocated': false,
                      'isAttribute': true,
                      'stats': ['+5 к атрибуту'],
                      'path': [2],
                    },
                  ],
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Атрибут');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Атрибут'));
      await tester.pumpAndSettle();
      final point = tester
          .getRect(find.byKey(const ValueKey('tree-viewport')))
          .center;
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: point - const Offset(40, 0));
      await mouse.moveTo(point);
      await tester.pumpAndSettle();
      expect(find.text('+10 здоровья'), findsOneWidget);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('+10 здоровья'), findsNothing);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await mouse.removePointer();
      final right = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await right.down(point);
      await right.up();
      await right.removePointer();
      await tester.pumpAndSettle();
      expect(actions.single['action'], 'right');
      await mouse.down(point);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(find.text('Выберите атрибут'), findsOneWidget);
      await tester.tap(find.text('Ловкость'));
      await tester.pumpAndSettle();
      expect(actions.last['attribute'], 2);
      final count = actions.length;
      await mouse.removePointer();
      final middle = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kMiddleMouseButton,
      );
      await middle.down(point);
      await middle.moveTo(point + const Offset(80, 30));
      await middle.up();
      await tester.pumpAndSettle();
      expect(actions.length, count);
      await middle.removePointer();
      final back = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kBackMouseButton,
      );
      await back.down(point);
      await back.up();
      await back.removePointer();
      final forward = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kForwardMouseButton,
      );
      await forward.down(point);
      await forward.up();
      await forward.removePointer();
      await tester.pumpAndSettle();
      expect(history, [false, true]);
      expect(actions.length, count);
      expect(tester.takeException(), isNull);
    });
  }
}
