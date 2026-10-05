import 'package:flutter/material.dart';

import 'workshop_components.dart';
import 'ui_text.dart';

class NewBuildDialog extends StatefulWidget {
  const NewBuildDialog({super.key, required this.classes});
  final List<Map<String, dynamic>> classes;
  @override
  State<NewBuildDialog> createState() => _NewBuildDialogState();
}

class _NewBuildDialogState extends State<NewBuildDialog> {
  final name = TextEditingController();
  final level = TextEditingController(text: '1');
  late int classId = widget.classes.first['id'] as int;
  bool get valid =>
      name.text.trim().isNotEmpty &&
      name.text.length <= 100 &&
      int.tryParse(level.text) != null &&
      int.parse(level.text) >= 1 &&
      int.parse(level.text) <= 100;
  @override
  void dispose() {
    name.dispose();
    level.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(tr(context, 'Новая сборка')),
    content: SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: tr(context, 'Название сборки'),
            ),
          ),
          const SizedBox(height: 16),
          WorkshopSelect<int>(
            initialValue: classId,
            decoration: InputDecoration(labelText: tr(context, 'Класс')),
            items: [
              for (final entry in widget.classes)
                DropdownMenuItem(
                  value: entry['id'] as int,
                  child: Text(entry['name'] as String),
                ),
            ],
            onChanged: (value) => setState(() => classId = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: level,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: tr(context, 'Уровень'),
              helperText: tr(context, 'От 1 до 100, ручной режим'),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr(context, 'Отмена')),
      ),
      FilledButton(
        onPressed: valid
            ? () => Navigator.pop(context, {
                'name': name.text.trim(),
                'level': int.parse(level.text),
                'classId': classId,
              })
            : null,
        child: Text(tr(context, 'Создать')),
      ),
    ],
  );
}

Future<String?> confirmBuildReplacement(
  BuildContext context, {
  required bool hasDraft,
}) => showDialog<String>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(tr(context, 'Есть несохранённые изменения')),
    content: Text(
      tr(
        context,
        hasDraft
            ? 'В полях есть неприменённый текст. Сохранение XML его не включает.'
            : 'Сохранить текущую сборку перед открытием другой?',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, 'cancel'),
        child: Text(tr(context, 'Отмена')),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, 'discard'),
        child: Text(tr(context, 'Продолжить без сохранения')),
      ),
      if (!hasDraft)
        FilledButton(
          onPressed: () => Navigator.pop(context, 'save'),
          child: Text(tr(context, 'Сохранить')),
        ),
    ],
  ),
);
