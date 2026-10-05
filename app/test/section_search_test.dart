import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pob_workshop/main.dart';
import 'package:pob_workshop/section_search.dart';

void main() {
  testWidgets('Поиск раздела: фильтр, стрелки, Enter и Escape', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    int? selected;
    for (final dark in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: gruvbox(dark),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await searchSections(context, [
                    'Расчёты',
                    'Условия боя',
                    'Импорт / экспорт',
                    'Дерево',
                  ]);
                },
                child: const Text('Поиск'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Поиск'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(selected, 1);
      await tester.tap(find.text('Поиск'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'дер');
      expect(find.text('Дерево'), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(selected, 3);
      await tester.tap(find.text('Поиск'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'несуществующий');
      await tester.pump();
      expect(find.text('Раздел не найден'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(selected, isNull);
      expect(tester.takeException(), isNull);
    }
  });
}
