import 'ui_text.dart';
import 'workshop_components.dart';

import 'package:flutter/material.dart';

import 'design_theme.dart';

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
    this.initialShowPulse = true,
    this.onPulseVisibility,
    this.initialNavigationWidth = 220,
    this.initialPulseWidth = 286,
    this.onWidths,
  });
  final int section;
  final ValueChanged<int> onSection;
  final Map<String, dynamic> output;
  final Map<String, dynamic>? tree;
  final Expanded editor;
  final bool initialShowPulse;
  final double initialNavigationWidth, initialPulseWidth;
  final void Function(double, double)? onWidths;
  final ValueChanged<bool>? onPulseVisibility;
  final Map<String, dynamic> buildInfo;
  final Future<void> Function(Map<String, dynamic>)? onSkill;

  @override
  State<WorkshopShell> createState() => _WorkshopShellState();
}

class _WorkshopShellState extends State<WorkshopShell> {
  late bool showPulse;
  late double navigationWidth, pulseWidth;

  @override
  void initState() {
    super.initState();
    showPulse = widget.initialShowPulse;
    navigationWidth = widget.initialNavigationWidth.clamp(180, 280);
    pulseWidth = widget.initialPulseWidth.clamp(240, 360);
  }

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
  Expanded get editor => widget.editor;

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

  void togglePulse() {
    setState(() => showPulse = !showPulse);
    widget.onPulseVisibility?.call(showPulse);
  }

  Widget pulseButton(BuildContext context, bool wide) => IconButton(
    tooltip: wide
        ? (showPulse
              ? tr(context, 'Скрыть показатели')
              : tr(context, 'Показать показатели'))
        : tr(context, 'Показать показатели'),
    onPressed: () => wide ? togglePulse() : openPulse(context),
    icon: Icon(
      showPulse && wide ? Icons.chevron_right : Icons.monitor_heart_outlined,
    ),
  );

  Widget navigation(BuildContext context) => SizedBox(
    width: navigationWidth,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tr(context, 'ВАША СБОРКА'),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        SizedBox(height: 16),
        Text(
          widget.buildInfo['name'] as String? ?? tr(context, 'Откройте сборку'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (widget.buildInfo.isNotEmpty) ...[
          SizedBox(height: 12),
          Text(
            [
              widget.buildInfo['class'],
              widget.buildInfo['ascendancy'],
            ].where((value) => value != null && value != '').join(' · '),
          ),
          SizedBox(height: 12),
          Text('${tr(context, 'Уровень')} ${widget.buildInfo['level']}'),
        ],
        SizedBox(height: 32),
        for (final entry in workshopNavigation)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: section == entry.$1,
              selectedTileColor: Theme.of(context)
                  .extension<WorkshopColors>()
                  ?.raised,
              leading: Icon(entry.$3),
              title: Text(tr(context, entry.$2)),
              onTap: () => onSection(entry.$1),
            ),
          ),
        const Divider(height: 32),
        Text(
          tr(
            context,
            'Редакторы снаряжения, умений, группы и заметок ещё переносятся из Lua.',
          ),
        ),
      ],
    ),
  );

  Widget skillSelector(String key, String label) {
    final control = widget.buildInfo[key] as Map?;
    final entries = control?['entries'] as List? ?? [];
    if (entries.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: WorkshopSelect<int>(
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

  Widget pulse(BuildContext context) => Container(
    width: pulseWidth,
    color: Theme.of(context).colorScheme.surface,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          tr(context, 'ПУЛЬС СБОРКИ'),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        SizedBox(height: 12),
        Text(
          tr(context, 'Всё важное рядом'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        skillSelector('groups', tr(context, 'Основное умение')),
        skillSelector('skills', tr(context, 'Активное умение')),
        const Divider(height: 48),
        Text(tr(context, 'Урон в секунду')),
        SizedBox(height: 12),
        Text(
          value(context, 'TotalDPS'),
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        Text(tr(context, 'Результат оригинального движка Lua')),
        const Divider(height: 48),
        for (final pair in [
          ('Life', tr(context, 'Здоровье')),
          ('EnergyShield', tr(context, 'Энерг. щит')),
          ('Mana', tr(context, 'Мана')),
          ('Spirit', tr(context, 'Дух')),
          ('FireResist', tr(context, 'Огонь')),
          ('ColdResist', tr(context, 'Холод')),
          ('LightningResist', tr(context, 'Молния')),
          ('ChaosResist', tr(context, 'Хаос')),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Text(tr(context, pair.$2))),
                Flexible(
                  child: Text(
                    value(
                      context,
                      pair.$1,
                      percent: pair.$1.endsWith('Resist'),
                    ),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => onSection(0),
          child: Text(tr(context, 'Открыть расчёты →')),
        ),
      ],
    ),
  );

  String value(BuildContext context, String key, {bool percent = false}) =>
      formatUiNumber(context, output[key] as num?, percent: percent);

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
                  for (final entry in workshopNavigation)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: ChoiceChip(
                        label: Text(tr(context, entry.$2)),
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
          PanelResizeHandle(
            onDelta: (delta) => setState(
              () => navigationWidth = (navigationWidth + delta).clamp(180, 280),
            ),
            onEnd: () => widget.onWidths?.call(navigationWidth, pulseWidth),
          ),
          if (section == 3 && size.maxWidth >= 1100 && size.maxHeight >= 600)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WorkshopPageHeading(title: 'Дерево пассивных умений'),
                  editor,
                ],
              ),
            )
          else
            editor,
          if (wide && showPulse) ...[
            PanelResizeHandle(
              onDelta: (delta) => setState(
                () => pulseWidth = (pulseWidth - delta).clamp(240, 360),
              ),
              onEnd: () => widget.onWidths?.call(navigationWidth, pulseWidth),
            ),
            pulse(context),
          ],
        ],
      );
    },
  );
}
