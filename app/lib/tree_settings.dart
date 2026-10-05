import 'workshop_components.dart';
import 'ui_text.dart';

import 'package:flutter/material.dart';

class TreeSettings extends StatelessWidget {
  const TreeSettings({super.key, required this.data, required this.onApply});
  final Map<String, dynamic> data;
  final Future<void> Function(Map<String, dynamic>) onApply;

  Future<void> manage(BuildContext context, String action) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr(context, 'Удалить набор дерева?')),
          content: Text(
            tr(context, 'Действие можно отменить через историю сборки.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr(context, 'Отмена')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr(context, 'Удалить')),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      Navigator.pop(context);
      await onApply({'specAction': action});
      return;
    }
    final text = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(context, 'Название набора')),
        content: TextField(controller: text, autofocus: true, maxLength: 100),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr(context, 'Отмена')),
          ),
          FilledButton(
            onPressed: () {
              if (text.text.trim().isNotEmpty) {
                Navigator.pop(context, text.text.trim());
              }
            },
            child: Text(tr(context, 'Сохранить')),
          ),
        ],
      ),
    );
    text.dispose();
    if (name == null || !context.mounted) return;
    Navigator.pop(context);
    await onApply({'specAction': action, 'name': name});
  }

  Future<void> changeClass(BuildContext context, int id) async {
    if (id == data['classId']) return;
    final used = (data['nodes'] as List).any(
      (n) =>
          n['allocated'] == true &&
          n['type'] != 'ClassStart' &&
          n['type'] != 'AscendClassStart',
    );
    String? choice = 'keep';
    if (used) {
      choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr(context, 'Изменить класс')),
          content: Text(
            tr(
              context,
              'Можно соединить дерево со стартом нового класса или сбросить назначенные умения. Изменение сохраняется в истории отмены.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr(context, 'Отмена')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'reset'),
              child: Text(tr(context, 'Сбросить дерево')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'connect'),
              child: Text(tr(context, 'Соединить путь')),
            ),
          ],
        ),
      );
    }
    if (choice == null || !context.mounted) return;
    Navigator.pop(context);
    await onApply({
      'class': id,
      if (choice == 'reset') 'reset': true,
      if (choice == 'connect') 'connect': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    final classes = (data['classes'] as List?) ?? [];
    final current = classes
        .where((c) => c['id'] == data['classId'])
        .firstOrNull;
    Future<void> apply(Map<String, dynamic> params) async {
      Navigator.pop(context);
      await onApply(params);
    }

    return AlertDialog(
      title: Text(tr(context, 'Настройки дерева')),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WorkshopSelect<int>(
                initialValue: data['classId'] as int?,
                decoration: InputDecoration(labelText: tr(context, 'Класс')),
                items: [
                  for (final c in classes)
                    DropdownMenuItem(
                      value: c['id'] as int,
                      child: Text(c['name'] as String),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) changeClass(context, id);
                },
              ),
              SizedBox(height: 16),
              WorkshopSelect<int>(
                initialValue: data['ascendancyId'] as int?,
                decoration: InputDecoration(
                  labelText: tr(context, 'Восхождение'),
                ),
                items: [
                  for (final asc in (current?['ascendancies'] as List?) ?? [])
                    DropdownMenuItem(
                      value: asc['id'] as int,
                      child: Text(asc['name'] as String),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) apply({'ascendancy': id});
                },
              ),
              SizedBox(height: 16),
              WorkshopSelect<int>(
                initialValue: data['activeSpec'] as int?,
                decoration: InputDecoration(
                  labelText: tr(context, 'Набор дерева'),
                ),
                items: [
                  for (final spec in (data['specs'] as List?) ?? [])
                    DropdownMenuItem(
                      value: spec['id'] as int,
                      child: Text(spec['name'] as String),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) apply({'spec': id});
                },
              ),
              SizedBox(height: 24),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => manage(context, 'new'),
                    child: Text(tr(context, 'Новый')),
                  ),
                  TextButton(
                    onPressed: () => manage(context, 'clone'),
                    child: Text(tr(context, 'Копия')),
                  ),
                  TextButton(
                    onPressed: () => manage(context, 'rename'),
                    child: Text(tr(context, 'Переименовать')),
                  ),
                  if (((data['specs'] as List?) ?? []).length > 1)
                    TextButton(
                      onPressed: () => manage(context, 'delete'),
                      child: Text(tr(context, 'Удалить')),
                    ),
                ],
              ),
              WorkshopSelect<int>(
                initialValue: data['compareSpec'] as int? ?? 0,
                decoration: InputDecoration(
                  labelText: tr(context, 'Сравнить с набором'),
                ),
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text(tr(context, 'Без сравнения')),
                  ),
                  for (final spec in (data['specs'] as List?) ?? [])
                    DropdownMenuItem(
                      value: spec['id'] as int,
                      child: Text(spec['name'] as String),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) apply({'compare': id});
                },
              ),
              SizedBox(height: 24),
              Text(tr(context, 'Оружейный режим назначения')),
              SizedBox(height: 8),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 0, label: Text(tr(context, 'Общее'))),
                  ButtonSegment(value: 1, label: Text(tr(context, 'Набор 1'))),
                  ButtonSegment(value: 2, label: Text(tr(context, 'Набор 2'))),
                ],
                selected: {data['mode'] as int? ?? 0},
                onSelectionChanged: (selection) =>
                    apply({'mode': selection.single}),
              ),
              SizedBox(height: 24),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(tr(context, 'Сбросить дерево?')),
                      content: Text(
                        tr(
                          context,
                          'Все назначения будут удалены. Отмена доступна через историю сборки.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(tr(context, 'Отмена')),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(tr(context, 'Сбросить')),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await apply({'reset': true});
                  }
                },
                icon: const Icon(Icons.restart_alt),
                label: Text(tr(context, 'Сбросить назначения')),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr(context, 'Закрыть')),
        ),
      ],
    );
  }
}

class TreeJewelPicker extends StatefulWidget {
  const TreeJewelPicker({super.key, required this.load});
  final Future<Map<String, dynamic>> Function() load;
  @override
  State<TreeJewelPicker> createState() => _TreeJewelPickerState();
}

class _TreeJewelPickerState extends State<TreeJewelPicker> {
  late final future = widget.load();
  final raw = TextEditingController();
  @override
  void dispose() {
    raw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(tr(context, 'Самоцвет в гнезде')),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    '${tr(context, 'Ошибка загрузки: ')}${snapshot.error}',
                  );
                }
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final items = snapshot.data!['items'] as List;
                return Column(
                  children: [
                    for (final item in items)
                      ListTile(
                        title: Text(item['name'] as String),
                        subtitle: Text(
                          item['raw'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: item['id'] == snapshot.data!['selected'],
                        onTap: () =>
                            Navigator.pop(context, {'item': item['id']}),
                      ),
                    if (items.isEmpty)
                      Text(
                        tr(
                          context,
                          'В сборке пока нет подходящих самоцветов. Вставьте текст предмета ниже.',
                        ),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, {'item': 0}),
                      child: Text(tr(context, 'Очистить гнездо')),
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            TextField(
              controller: raw,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: tr(context, 'Текст самоцвета из игры / PoB'),
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr(context, 'Отмена')),
      ),
      FilledButton(
        onPressed: () {
          if (raw.text.trim().isNotEmpty) {
            Navigator.pop(context, {'raw': raw.text});
          }
        },
        child: Text(tr(context, 'Вставить в гнездо')),
      ),
    ],
  );
}
