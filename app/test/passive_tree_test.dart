import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/passive_tree.dart';

void main() {
  testWidgets('Поиск узла, выбор и подтверждение на узком экране', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    int? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PassiveTree(
              enabled: true,
              onToggle: (id) async => applied = id,
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
                    'x': 100,
                    'y': 100,
                    'name': 'Усиление',
                    'type': 'Notable',
                    'allocated': false,
                    'stats': ['Урон +10%'],
                  },
                ],
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Усиление');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Усиление'));
    await tester.pumpAndSettle();
    expect(find.text('Урон +10%'), findsOneWidget);
    await tester.ensureVisible(find.text('Назначить путь к узлу'));
    await tester.tap(find.text('Назначить путь к узлу'));
    expect(applied, 2);
    expect(tester.takeException(), isNull);
  });
}
