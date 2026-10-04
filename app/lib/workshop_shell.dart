import 'package:flutter/material.dart';

/// Оболочка отображает ответы движка; игровые значения здесь не вычисляются.
class WorkshopShell extends StatelessWidget {
  const WorkshopShell({
    super.key,
    required this.section,
    required this.onSection,
    required this.output,
    required this.tree,
    required this.editor,
  });
  final int section;
  final ValueChanged<int> onSection;
  final Map<String, dynamic> output;
  final Map<String, dynamic>? tree;
  final Widget editor;

  Widget navigation(BuildContext context) => SizedBox(
    width: 220,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('ВАША СБОРКА', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 16),
        Text(
          output.isEmpty ? 'Откройте сборку' : 'Текущая сборка',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 32),
        for (final entry in const [
          (3, 'Дерево', Icons.account_tree_outlined),
          (1, 'Условия боя', Icons.tune),
          (0, 'Расчёты', Icons.analytics_outlined),
          (2, 'Импорт / экспорт', Icons.import_export),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: section == entry.$1,
              selectedTileColor: Theme.of(context).colorScheme.primary
                  .withValues(alpha: .12),
              leading: Icon(entry.$3),
              title: Text(entry.$2),
              onTap: () => onSection(entry.$1),
            ),
          ),
        const Divider(height: 32),
        const Text(
          'Редакторы снаряжения, умений, группы и заметок ещё переносятся из Lua.',
        ),
      ],
    ),
  );

  Widget pulse(BuildContext context) => SizedBox(
    width: 270,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('ПУЛЬС СБОРКИ', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),
        Text('Всё важное рядом', style: Theme.of(context).textTheme.titleLarge),
        const Divider(height: 48),
        const Text('Урон в секунду'),
        const SizedBox(height: 12),
        Text(
          value('TotalDPS'),
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        const Text('Результат оригинального движка Lua'),
        const Divider(height: 48),
        for (final pair in const [
          ('Life', 'Здоровье'),
          ('EnergyShield', 'Энерг. щит'),
          ('Mana', 'Мана'),
          ('Spirit', 'Дух'),
          ('FireResist', 'Огонь'),
          ('ColdResist', 'Холод'),
          ('LightningResist', 'Молния'),
          ('ChaosResist', 'Хаос'),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Text(pair.$2)),
                Text(
                  value(pair.$1, percent: pair.$1.endsWith('Resist')),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => onSection(0),
          child: const Text('Открыть расчёты →'),
        ),
      ],
    ),
  );

  String value(String key, {bool percent = false}) {
    final number = output[key];
    if (number is! num) return '—';
    return '${number.toStringAsFixed(number == number.roundToDouble() ? 0 : 2)}${percent ? '%' : ''}';
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      if (size.maxWidth < 760) {
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final entry in const [
                    (3, 'Дерево'),
                    (1, 'Условия'),
                    (0, 'Расчёты'),
                    (2, 'Импорт'),
                  ])
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: ChoiceChip(
                        label: Text(entry.$2),
                        selected: section == entry.$1,
                        onSelected: (_) => onSection(entry.$1),
                      ),
                    ),
                ],
              ),
            ),
            editor,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          navigation(context),
          const VerticalDivider(width: 1),
          editor,
          if (size.maxWidth >= 1250) ...[
            const VerticalDivider(width: 1),
            pulse(context),
          ],
        ],
      );
    },
  );
}
