import 'dart:io';

import 'package:flutter/material.dart';

import 'engine_client.dart';
import 'build_session.dart';
import 'passive_tree.dart';
import 'workshop_shell.dart';

void main() => runApp(const WorkshopApp());
ThemeData gruvbox(bool dark) => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Color(dark ? 0xff282828 : 0xfffbf1c7),
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: const Color(0xffb8bb26),
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: Color(dark ? 0xffb8bb26 : 0xff79740e),
        onPrimary: Color(dark ? 0xff282828 : 0xfffbf1c7),
        surface: Color(dark ? 0xff32302f : 0xfff2e5bc),
        onSurface: Color(dark ? 0xffebdbb2 : 0xff3c3836),
      ),
);

class WorkshopApp extends StatefulWidget {
  const WorkshopApp({super.key});
  @override
  State<WorkshopApp> createState() => _WorkshopState();
}

class _WorkshopState extends State<WorkshopApp> {
  final engine = EngineClient();
  final mods = TextEditingController();
  final xml = TextEditingController();
  final filePath = TextEditingController();
  BuildSession? session;
  Map<String, dynamic> output = {};
  Map<String, dynamic> buildInfo = {};
  Map<String, dynamic>? tree;
  String status = 'Подключение к Lua…';
  String? root;
  bool dark = true, busy = true, ready = false;
  int section = 3;
  static const sections = [
    'Расчёты',
    'Условия боя',
    'Импорт / экспорт',
    'Дерево',
  ];
  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    try {
      var dir = Directory.current;
      while (!File('${dir.path}/app/tools/headless_server.lua').existsSync()) {
        if (dir.parent.path == dir.path) {
          throw StateError('Запустите из репозитория');
        }
        dir = dir.parent;
      }
      root = dir.path;
      await engine.start(root!);
      final local =
          Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
      session = BuildSession(
        engine,
        File('$local/PathOfBuildingWorkshop/session.xml'),
      );
      if (mounted) {
        setState(() {
          ready = true;
          busy = false;
          status = 'Lua подключён';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          busy = false;
          status = '$error';
        });
      }
    }
  }

  Future<void> perform(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
      if (session != null && session!.output.isNotEmpty) {
        tree = await engine.request('getTree');
        final snapshot = await engine.request('getSnapshot');
        buildInfo = Map<String, dynamic>.from(snapshot['buildInfo'] as Map);
      }
      if (mounted) {
        setState(() => status = 'Результат Lua · ревизия ${engine.revision}');
      }
    } catch (error) {
      if (mounted) setState(() => status = '$error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> load(String text) async {
    await session!.open(text);
    if (mounted) {
      setState(() {
        output = session!.output;
        mods.clear();
      });
    }
  }

  bool get editable => ready && !busy && output.isNotEmpty;
  Widget stats(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 16,
    children:
        {
              'TotalDPS': 'Урон в секунду',
              'Life': 'Здоровье',
              'Mana': 'Мана',
              'EnergyShield': 'Энерг. щит',
            }.entries
            .map(
              (entry) => SizedBox(
                width: 200,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.value),
                        const SizedBox(height: 12),
                        Text(
                          (output[entry.key] as num?)?.toStringAsFixed(2) ??
                              '—',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
  );
  Widget content(BuildContext context, {double mapHeight = 500}) {
    if (section == 3) {
      if (tree == null) {
        return const Text('Откройте сборку для загрузки дерева');
      }
      return PassiveTree(
        mapHeight: mapHeight,
        data: tree!,
        enabled: editable,
        onHistory: (redo) => perform(() async {
          if (redo) {
            await session!.redo();
          } else {
            await session!.undo();
          }
          if (mounted) setState(() => output = session!.output);
        }),
        onJewels: (id) => engine.request('getJewels', {'id': id}),
        onOptions: (params) => perform(() async {
          await session!.treeOptions(params);
          if (mounted) setState(() => output = session!.output);
        }),
        onInspect: (id, compare) =>
            engine.request('getNodeTooltip', {'id': id, 'compare': compare}),
        onAction: (params) => perform(() async {
          await session!.treeAction(params);
          if (mounted) setState(() => output = session!.output);
        }),
        onToggle: (id) => perform(() async {
          await session!.toggleNode(id);
          if (mounted) setState(() => output = session!.output);
        }),
      );
    }
    if (section == 0) return stats(context);
    if (section == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: mods,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Модификаторы PoB',
              hintText: '100% increased Spell Damage',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: editable
                ? () => perform(() async {
                    await session!.modify(mods.text);
                    if (mounted) {
                      setState(() => output = session!.output);
                    }
                  })
                : null,
            child: const Text('Применить и пересчитать'),
          ),
          const SizedBox(height: 24),
          stats(context),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: filePath,
          decoration: const InputDecoration(
            labelText: 'Полный путь XML-файла',
            hintText: 'C:/Builds/my-build.xml',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton(
              onPressed: ready && !busy
                  ? () => perform(() async {
                      final text = await File(filePath.text.trim())
                          .readAsString();
                      await load(text);
                      xml.text = text;
                    })
                  : null,
              child: const Text('Открыть файл'),
            ),
            OutlinedButton(
              onPressed: editable
                  ? () async {
                      final target = File(filePath.text.trim());
                      if (filePath.text.trim().isEmpty) {
                        setState(() => status = 'Укажите путь файла');
                        return;
                      }
                      if (await target.exists()) {
                        if (!context.mounted) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Заменить существующий файл?'),
                            content: Text(target.path),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Отмена'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Заменить'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                      }
                      if (!mounted) return;
                      await perform(() => session!.save(target));
                    }
                  : null,
              child: const Text('Сохранить файл'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: xml,
          minLines: 8,
          maxLines: 14,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'XML сборки',
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: [
            FilledButton(
              onPressed: ready && !busy
                  ? () => perform(() => load(xml.text))
                  : null,
              child: const Text('Открыть XML'),
            ),
            OutlinedButton(
              onPressed: editable
                  ? () => perform(() async {
                      final result = await engine.request('exportBuild');
                      xml.text = result['xml'] as String;
                    })
                  : null,
              child: const Text('Получить XML'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Path of Building · Мастерская',
    theme: gruvbox(dark),
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('◈ Мастерская сборок'),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          actions: [
            IconButton(
              tooltip: 'Отменить изменение',
              onPressed: editable && session!.canUndo
                  ? () => perform(() async {
                      await session!.undo();
                      setState(() {
                        output = session!.output;
                        mods.clear();
                      });
                    })
                  : null,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: 'Повторить изменение',
              onPressed: editable && session!.canRedo
                  ? () => perform(() async {
                      await session!.redo();
                      setState(() {
                        output = session!.output;
                        mods.clear();
                      });
                    })
                  : null,
              icon: const Icon(Icons.redo),
            ),
            IconButton(
              tooltip: 'Восстановить последнюю сессию',
              onPressed: ready && !busy
                  ? () => perform(() async {
                      await load(await session!.recoveryFile.readAsString());
                    })
                  : null,
              icon: const Icon(Icons.restore),
            ),
            IconButton(
              onPressed: () => setState(() => dark = !dark),
              tooltip: 'Переключить тему',
              icon: const Icon(Icons.contrast),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, size) {
            final editor = Expanded(
              child: section == 3 && tree != null
                  ? LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: content(
                          context,
                          mapHeight: (constraints.maxHeight - 155).clamp(
                            250,
                            2000,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sections[section],
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(status),
                          if (busy) const LinearProgressIndicator(),
                          const SizedBox(height: 20),
                          FilledButton.tonal(
                            onPressed: ready && !busy
                                ? () => perform(() async {
                                    await load(
                                      await File(
                                        '$root/app/docs/flutter/fixtures/fireball-basic/build.xml',
                                      ).readAsString(),
                                    );
                                  })
                                : null,
                            child: const Text('Открыть эталон Fireball'),
                          ),
                          const SizedBox(height: 24),
                          content(context),
                          const SizedBox(height: 32),
                          const Text(
                            'Windows-прототип · Python + Lua. Остальные редакторы ещё не перенесены.',
                          ),
                        ],
                      ),
                    ),
            );
            return WorkshopShell(
              section: section,
              onSection: (value) => setState(() => section = value),
              output: output,
              buildInfo: buildInfo,
              onSkill: editable
                  ? (params) => perform(() async {
                      await session!.selectMainSkill(params);
                      if (mounted) setState(() => output = session!.output);
                    })
                  : null,
              tree: tree,
              editor: editor,
            );
          },
        ),
      ),
    ),
  );
  @override
  void dispose() {
    engine.dispose();
    mods.dispose();
    xml.dispose();
    filePath.dispose();
    super.dispose();
  }
}
