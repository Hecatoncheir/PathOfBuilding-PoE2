import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_text.dart';

class WorkshopPageHeading extends StatelessWidget {
  const WorkshopPageHeading({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'ПЛАНИРУЙТЕ. ПРОБУЙТЕ. СРАВНИВАЙТЕ.'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr(context, title),
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -.7),
        ),
      ],
    ),
  );
}

class WorkshopSelect<T> extends StatelessWidget {
  const WorkshopSelect({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.isExpanded = true,
  });
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? initialValue;
  final InputDecoration decoration;
  final bool isExpanded;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: initialValue,
    items: items,
    onChanged: onChanged,
    decoration: decoration,
    isExpanded: isExpanded,
    itemHeight: 48,
  );
}

class WorkshopCard extends StatelessWidget {
  const WorkshopCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, title),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(tr(context, subtitle!)),
            ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class WorkshopValueTable extends StatelessWidget {
  const WorkshopValueTable({super.key, required this.values});
  final Map<String, String> values;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final entry in values.entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(tr(context, entry.key))),
              const SizedBox(width: 16),
              Expanded(
                child: SelectableText(entry.value, textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
    ],
  );
}

class WorkshopItemCard extends StatelessWidget {
  const WorkshopItemCard({super.key, required this.item});
  final Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) => WorkshopCard(
    title: item['name'] as String? ?? '—',
    child: WorkshopValueTable(
      values: {
        'Основа': item['base'] as String? ?? '—',
        'Редкость': item['rarity'] as String? ?? '—',
      },
    ),
  );
}

class PanelResizeHandle extends StatelessWidget {
  const PanelResizeHandle({
    super.key,
    required this.onDelta,
    required this.onEnd,
  });
  final ValueChanged<double> onDelta;
  final VoidCallback onEnd;
  void move(double delta) {
    onDelta(delta);
    onEnd();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: tr(context, 'Изменить ширину панели'),
    onIncrease: () => move(16),
    onDecrease: () => move(-16),
    child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => move(16),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => move(-16),
      },
      child: Focus(
        child: Tooltip(
          message: tr(context, 'Изменить ширину панели'),
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (event) => onDelta(event.delta.dx),
              onHorizontalDragEnd: (_) => onEnd(),
              child: SizedBox(
                width: 48,
                child: Center(
                  child: Container(
                    width: 3,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

const workshopSections = [
  'Расчёты',
  'Условия боя',
  'Импорт / экспорт',
  'Дерево',
  'Снаряжение',
  'Умения',
  'Сравнение',
  'Группа',
  'Заметки',
  'Мои сборки',
];
const workshopNavigation = [
  (3, 'Дерево', Icons.account_tree_outlined),
  (4, 'Снаряжение', Icons.diamond_outlined),
  (5, 'Умения', Icons.auto_awesome_outlined),
  (1, 'Условия боя', Icons.tune),
  (0, 'Расчёты', Icons.analytics_outlined),
  (6, 'Сравнение', Icons.compare_arrows),
  (7, 'Группа', Icons.groups_outlined),
  (8, 'Заметки', Icons.notes),
  (9, 'Мои сборки', Icons.folder_outlined),
  (2, 'Импорт / экспорт', Icons.import_export),
];
