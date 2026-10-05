import 'workshop_components.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_preferences.dart';
import 'ui_text.dart';

class WorkshopShortcuts extends StatelessWidget {
  const WorkshopShortcuts({
    super.key,
    required this.child,
    required this.search,
    required this.save,
    required this.undo,
    required this.redo,
  });
  final Widget child;
  final VoidCallback search, save, undo, redo;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      for (final meta in [false, true]) ...{
        SingleActivator(
          LogicalKeyboardKey.keyK,
          control: !meta,
          meta: meta,
          includeRepeats: false,
        ): search,
        SingleActivator(
          LogicalKeyboardKey.keyS,
          control: !meta,
          meta: meta,
          includeRepeats: false,
        ): save,
        SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: !meta,
          meta: meta,
          includeRepeats: false,
        ): undo,
        SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: !meta,
          meta: meta,
          shift: true,
          includeRepeats: false,
        ): redo,
      },
      const SingleActivator(
        LogicalKeyboardKey.keyY,
        control: true,
        includeRepeats: false,
      ): redo,
    },
    child: FocusTraversalGroup(child: child),
  );
}

class WorkshopToolbar extends StatelessWidget implements PreferredSizeWidget {
  const WorkshopToolbar({
    super.key,
    required this.search,
    required this.importExport,
    required this.settings,
    required this.mode,
    required this.onTheme,
    this.undo,
    this.redo,
    this.save,
    this.restore,
  });
  final VoidCallback search, importExport, settings;
  final VoidCallback? undo, redo, save, restore;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onTheme;
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AppBar(
      toolbarHeight: 64,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.diamond_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          if (width >= 1000) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                tr(context, 'Мастерская сборок'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          tooltip: tr(context, 'Поиск раздела · Ctrl+K'),
          onPressed: search,
          icon: const Icon(Icons.search),
        ),
        if (width >= 1300) ...[
          TextButton(
            onPressed: importExport,
            child: Text(tr(context, 'Экспорт')),
          ),
          FilledButton(
            onPressed: importExport,
            child: Text(tr(context, 'Импорт сборки')),
          ),
        ] else
          IconButton(
            tooltip: tr(context, 'Импорт / экспорт'),
            onPressed: importExport,
            icon: const Icon(Icons.import_export),
          ),
        if (width >= 1000) ...[
          IconButton(
            tooltip: tr(context, 'Отменить изменение'),
            onPressed: undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: tr(context, 'Повторить изменение'),
            onPressed: redo,
            icon: const Icon(Icons.redo),
          ),
          IconButton(
            tooltip: tr(context, 'Сохранить файл'),
            onPressed: save,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
        PopupMenuButton<String>(
          tooltip: tr(context, 'Команды сборки'),
          onSelected: (action) => switch (action) {
            'undo' => undo?.call(),
            'redo' => redo?.call(),
            'save' => save?.call(),
            _ => restore?.call(),
          },
          itemBuilder: (_) => [
            for (final entry in [
              ('undo', 'Отменить изменение', undo),
              ('redo', 'Повторить изменение', redo),
              ('save', 'Сохранить файл', save),
              ('restore', 'Восстановить последнюю сессию', restore),
            ])
              PopupMenuItem(
                value: entry.$1,
                enabled: entry.$3 != null,
                child: Text(tr(context, entry.$2)),
              ),
          ],
          icon: const Icon(Icons.more_horiz),
        ),
        ThemeMenu(mode: mode, onSelected: onTheme),
        IconButton(
          tooltip: tr(context, 'Настройки интерфейса'),
          onPressed: settings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

Future<(String, bool)?> showInterfaceSettings(
  BuildContext context,
  String language,
  bool reducedMotion,
) => showDialog<(String, bool)>(
  context: context,
  builder: (context) => StatefulBuilder(
    builder: (context, update) => AlertDialog(
      title: Text(tr(context, 'Настройки интерфейса')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WorkshopSelect<String>(
              initialValue: language,
              decoration: InputDecoration(
                labelText: tr(context, 'Язык интерфейса'),
              ),
              items: const [
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) => update(() => language = value ?? language),
            ),
            SwitchListTile(
              title: Text(tr(context, 'Уменьшить движение')),
              value: reducedMotion,
              onChanged: (value) => update(() => reducedMotion = value),
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
          onPressed: () => Navigator.pop(context, (language, reducedMotion)),
          child: Text(tr(context, 'Сохранить')),
        ),
      ],
    ),
  ),
);
