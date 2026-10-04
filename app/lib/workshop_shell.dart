import 'package:flutter/material.dart';

/// Оболочка отображает ответы движка; игровые значения здесь не вычисляются.
class WorkshopShell extends StatefulWidget {
  const WorkshopShell({
    super.key,
    required this.section,
    required this.onSection,
    required this.output,
    required this.tree,
    required this.editor,
    this.buildInfo = const {},
    this.onSkill,
  });
  final int section;
  final ValueChanged<int> onSection;
  final Map<String, dynamic> output;
  final Map<String, dynamic>? tree;
  final Widget editor;
  final Map<String, dynamic> buildInfo;
  final Future<void> Function(Map<String, dynamic>)? onSkill;

  @override
  State<WorkshopShell> createState() => _WorkshopShellState();
}

class _WorkshopShellState extends State<WorkshopShell> {
  bool showPulse = true;
  final _panelRevision = ValueNotifier<int>(0);

  @override
  void didUpdateWidget(covariant WorkshopShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _panelRevision.value++;
    });
  }

  @override
  void dispose() {
    _panelRevision.dispose();
    super.dispose();
  }

  int get section => widget.section;
  ValueChanged<int> get onSection => widget.onSection;
  Map<String, dynamic> get output => widget.output;
  Widget get editor => widget.editor;

  Future<void> openPulse(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => SizedBox(
      height: MediaQuery.sizeOf(context).height * .85,
      width: double.infinity,
      child: ValueListenableBuilder<int>(
        valueListenable: _panelRevision,
        builder: (context, revision, child) => pulse(context),
      ),
    ),
  );

  Widget pulseButton(BuildContext context, bool wide) => IconButton(
    tooltip: wide
        ? (showPulse ? 'Скрыть показатели' : 'Показать показатели')
        : 'Показать показатели',
    onPressed: () =>
        wide ? setState(() => showPulse = !showPulse) : openPulse(context),
    icon: Icon(
      showPulse && wide ? Icons.chevron_right : Icons.monitor_heart_outlined,
    ),
  );

  Widget navigation(BuildContext context) => SizedBox(
    width: 220,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('ВАША СБОРКА', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 16),
        Text(
          widget.buildInfo['name'] as String? ?? 'Откройте сборку',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (widget.buildInfo.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            [
              widget.buildInfo['class'],
              widget.buildInfo['ascendancy'],
            ].where((value) => value != null && value != '').join(' · '),
          ),
          const SizedBox(height: 12),
          Text('Уровень ${widget.buildInfo['level']}'),
        ],
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

  Widget skillSelector(String key, String label) {
    final control = widget.buildInfo[key] as Map?;
    final entries = control?['entries'] as List? ?? [];
    if (entries.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField<int>(
        initialValue: control?['selected'] as int?,
        key: ValueKey('$key-${control?['selected']}-${entries.toString()}'),
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (final entry in entries)
            DropdownMenuItem(
              value: entry['id'] as int,
              child: Text(
                entry['label'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: control?['enabled'] == true && widget.onSkill != null
            ? (id) {
                if (id != null) widget.onSkill!({'control': key, 'id': id});
              }
            : null,
      ),
    );
  }

  Widget pulse(BuildContext context) => SizedBox(
    width: 270,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('ПУЛЬС СБОРКИ', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),
        Text('Всё важное рядом', style: Theme.of(context).textTheme.titleLarge),
        skillSelector('groups', 'Основное умение'),
        skillSelector('skills', 'Активное умение'),
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
      final wide = size.maxWidth >= 1250;
      if (size.maxWidth < 760) {
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  pulseButton(context, false),
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
          Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: pulseButton(context, wide),
              ),
              Expanded(child: navigation(context)),
            ],
          ),
          const VerticalDivider(width: 1),
          editor,
          if (wide && showPulse) ...[
            const VerticalDivider(width: 1),
            pulse(context),
          ],
        ],
      );
    },
  );
}
