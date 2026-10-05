import 'build_library.dart';
import 'build_library_view.dart';
import 'ui_text.dart';

import 'dart:io';

import 'package:flutter/material.dart';

import 'engine_client.dart';
import 'build_session.dart';
import 'passive_tree.dart';
import 'tree_settings.dart';
import 'tree_tooltip.dart';
import 'workshop_shell.dart';
import 'design_theme.dart';
import 'ui_preferences.dart';
import 'section_search.dart';
import 'workshop_components.dart';
import 'workshop_toolbar.dart';

void main() => runApp(const WorkshopApp());
ThemeData gruvbox(bool dark) => workshopTheme(dark);

class WorkshopApp extends StatefulWidget {
  const WorkshopApp({
    super.key,
    this.connectEngine = true,
    this.preferences,
    this.buildLibrary,
  });
  final bool connectEngine;
  final UiPreferences? preferences;
  final BuildLibrary? buildLibrary;
  @override
  State<WorkshopApp> createState() => _WorkshopState();
}

class _WorkshopState extends State<WorkshopApp> {
  final engine = EngineClient();
  late final library = widget.buildLibrary ?? BuildLibrary.local();
  final mods = TextEditingController();
  final xml = TextEditingController();
  final filePath = TextEditingController();
  BuildSession? session;
  Map<String, dynamic> output = {};
  Map<String, dynamic> buildInfo = {};
  Map<String, dynamic> workbench = {};
  Map<String, dynamic>? tree;
  String status = 'Подключение к Lua…';
  String? root;
  bool busy = true, ready = false;
  late final preferences = widget.preferences ?? UiPreferences.local();
  ThemeMode themeMode = ThemeMode.dark;
  bool showPulse = true;
  int section = 3;
  static const sections = workshopSections;
  String language = 'ru';
  bool reducedMotion = false;
  double navigationWidth = 220, pulseWidth = 286;
  @override
  void initState() {
    super.initState();
    themeMode = preferences.readTheme();
    showPulse = preferences.readPanel();
    language = preferences.readLanguage();
    reducedMotion = preferences.readReducedMotion();
    navigationWidth = preferences.readWidth('navigationWidth', 220);
    pulseWidth = preferences.readWidth('pulseWidth', 286);
    if (widget.connectEngine) {
      connect();
    } else {
      busy = false;
      status = 'Откройте сборку';
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    setState(() => themeMode = mode);
    try {
      await preferences.saveTheme(mode);
    } catch (error) {
      if (mounted) {
        setState(() => status = 'Не удалось сохранить тему: $error');
      }
    }
  }

  Future<void> savePanel(bool visible) async {
    showPulse = visible;
    try {
      await preferences.savePanel(visible);
    } catch (error) {
      if (mounted) {
        setState(
          () => status = 'Не удалось сохранить состояние панели: $error',
        );
      }
    }
  }

  Future<void> openSectionSearch(BuildContext context) async {
    final selected = await searchSections(context, sections);
    if (mounted && selected != null) setState(() => section = selected);
  }

  Future<void> history(bool redo) async {
    if (!editable || (redo ? !session!.canRedo : !session!.canUndo)) return;
    await perform(() async {
      if (redo) {
        await session!.redo();
      } else {
        await session!.undo();
      }
      if (mounted) {
        setState(() {
          output = session!.output;
          mods.clear();
        });
      }
    });
  }

  Future<void> saveBuild(BuildContext context) async {
    if (!editable) return;
    if (filePath.text.trim().isEmpty) {
      setState(() {
        section = 2;
        status = 'Укажите путь файла';
      });
      return;
    }
    final target = File(filePath.text.trim());
    if (await target.exists()) {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr(context, 'Заменить существующий файл?')),
          content: Text(target.path),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr(context, 'Отмена')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr(context, 'Заменить')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    if (mounted) await perform(() => session!.save(target));
  }

  Future<void> interfaceSettings(BuildContext context) async {
    final result = await showInterfaceSettings(
      context,
      language,
      reducedMotion,
    );
    if (!mounted || result == null) return;
    setState(() {
      language = result.$1;
      reducedMotion = result.$2;
    });
    try {
      await preferences.saveLanguage(language);
      await preferences.saveReducedMotion(reducedMotion);
    } catch (error) {
      if (mounted) {
        setState(() => status = 'Не удалось сохранить настройки: $error');
      }
    }
  }

  Future<void> saveWidths(double navigation, double pulse) async {
    navigationWidth = navigation;
    pulseWidth = pulse;
    try {
      await preferences.saveWidths(navigation, pulse);
    } catch (error) {
      if (mounted) {
        setState(() => status = 'Не удалось сохранить настройки: $error');
      }
    }
  }

  Future<void> connect() async {
    try {
      var dir = Directory.current;
      while (!File('${dir.path}/app/tools/headless_server.lua').existsSync()) {
        if (dir.parent.path == dir.path) {
          throw StateError(tr(context, 'Запустите из репозитория'));
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
          status = tr(context, 'Lua подключён');
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
        workbench = await engine.request('getWorkbench');
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
              'TotalDPS': tr(context, 'Урон в секунду'),
              'Life': tr(context, 'Здоровье'),
              'Mana': tr(context, 'Мана'),
              'EnergyShield': tr(context, 'Энерг. щит'),
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
                        Text(tr(context, entry.value)),
                        SizedBox(height: 12),
                        Text(
                          formatUiNumber(context, output[entry.key] as num?),
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
  Widget extraSection(BuildContext context) {
    final items = (workbench['items'] as List?) ?? [];
    final groups = (workbench['groups'] as List?) ?? [];
    if (section == 4 && items.isNotEmpty) {
      return Column(
        children: [
          for (final item in items)
            WorkshopItemCard(item: Map<String, dynamic>.from(item)),
        ],
      );
    }
    if (section == 5 && groups.isNotEmpty) {
      return WorkshopCard(
        title: 'Группы умений',
        child: WorkshopValueTable(
          values: {
            for (final group in groups)
              '${group['id']}': group['label'] as String? ?? '—',
          },
        ),
      );
    }
    if (section == 8 && (workbench['notes'] as String? ?? '').isNotEmpty) {
      return WorkshopCard(
        title: 'Заметки',
        child: SelectableText.rich(
          TextSpan(
            children: treeTextSpans(
              workbench['notes'] as String,
              Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }
    if (section == 6 && tree != null) {
      return WorkshopCard(
        title: 'Сравнение',
        child: FilledButton(
          onPressed: editable
              ? () => showDialog<void>(
                  context: context,
                  builder: (_) => TreeSettings(
                    data: tree!,
                    onApply: (params) => perform(() async {
                      await session!.treeOptions(params);
                      if (mounted) setState(() => output = session!.output);
                    }),
                  ),
                )
              : null,
          child: Text(tr(context, 'Сравнить с набором')),
        ),
      );
    }
    return WorkshopCard(
      title: sections[section],
      subtitle: 'Редактор будет подключён на следующем этапе.',
      child: Text(tr(context, 'Нет данных для отображения')),
    );
  }

  Widget content(
    BuildContext context, {
    double mapHeight = 500,
    bool fillViewport = false,
  }) {
    if (section == 3) {
      if (tree == null) {
        return Text(tr(context, 'Откройте сборку для загрузки дерева'));
      }
      return PassiveTree(
        mapHeight: mapHeight,
        fillViewport: fillViewport,
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
    if (section == 9) {
      return BuildLibraryView(
        library: library,
        onRename: (source, target) {
          if (File(filePath.text).absolute.path == source.absolute.path) {
            setState(() => filePath.text = target.path);
          }
        },
        enabled: ready && !busy,
        canSave: editable,
        onOpen: (file) => perform(() async {
          await load(await file.readAsString());
          if (mounted) {
            setState(() {
              filePath.text = file.path;
              section = 3;
            });
          }
        }),
        onSave: (folder, name) async {
          final file = await library.save(
            folder,
            name,
            await session!.export(),
          );
          if (mounted) setState(() => filePath.text = file.path);
        },
      );
    }
    if (section >= 4) return extraSection(context);
    if (section == 0) {
      return WorkshopCard(
        title: 'Расчёты',
        child: WorkshopValueTable(
          values: {
            for (final entry in output.entries)
              entry.key: formatUiNumber(context, entry.value as num?),
          },
        ),
      );
    }
    if (section == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: mods,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: tr(context, 'Модификаторы PoB'),
              hintText: '100% increased Spell Damage',
            ),
          ),
          SizedBox(height: 16),
          FilledButton(
            onPressed: editable
                ? () => perform(() async {
                    await session!.modify(mods.text);
                    if (mounted) {
                      setState(() => output = session!.output);
                    }
                  })
                : null,
            child: Text(tr(context, 'Применить и пересчитать')),
          ),
          SizedBox(height: 24),
          stats(context),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: filePath,
          decoration: InputDecoration(
            labelText: tr(context, 'Полный путь XML-файла'),
            hintText: 'C:/Builds/my-build.xml',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
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
              child: Text(tr(context, 'Открыть файл')),
            ),
            OutlinedButton(
              onPressed: editable ? () => saveBuild(context) : null,
              child: Text(tr(context, 'Сохранить файл')),
            ),
          ],
        ),
        SizedBox(height: 24),
        TextField(
          controller: xml,
          minLines: 8,
          maxLines: 14,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: tr(context, 'XML сборки'),
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: [
            FilledButton(
              onPressed: ready && !busy
                  ? () => perform(() => load(xml.text))
                  : null,
              child: Text(tr(context, 'Открыть XML')),
            ),
            OutlinedButton(
              onPressed: editable
                  ? () => perform(() async {
                      final result = await engine.request('exportBuild');
                      xml.text = result['xml'] as String;
                    })
                  : null,
              child: Text(tr(context, 'Получить XML')),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: tr(context, 'Path of Building · Мастерская'),
    theme: gruvbox(false),
    darkTheme: gruvbox(true),
    themeMode: themeMode,
    locale: Locale(language),
    supportedLocales: const [Locale('ru'), Locale('en')],
    localizationsDelegates: const [
      WorkshopMaterialDelegate(),
      WorkshopCupertinoDelegate(),
    ],
    themeAnimationDuration:
        (reducedMotion ||
            WidgetsBinding
                .instance
                .platformDispatcher
                .accessibilityFeatures
                .disableAnimations)
        ? Duration.zero
        : const Duration(milliseconds: 180),
    builder: (context, child) => WorkshopLocale(
      language: language,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              reducedMotion || MediaQuery.disableAnimationsOf(context),
        ),
        child: child!,
      ),
    ),
    home: Builder(
      builder: (context) => WorkshopShortcuts(
        search: () => openSectionSearch(context),
        save: () => saveBuild(context),
        undo: () => history(false),
        redo: () => history(true),
        child: Scaffold(
          appBar: WorkshopToolbar(
            search: () => openSectionSearch(context),
            importExport: () => setState(() => section = 2),
            settings: () => interfaceSettings(context),
            mode: themeMode,
            onTheme: changeTheme,
            undo: editable && session!.canUndo ? () => history(false) : null,
            redo: editable && session!.canRedo ? () => history(true) : null,
            save: editable ? () => saveBuild(context) : null,
            restore: ready && !busy
                ? () => perform(() async {
                    await load(await session!.recoveryFile.readAsString());
                  })
                : null,
          ),
          body: LayoutBuilder(
            builder: (context, size) {
              final editor = Expanded(
                child: section == 3 && tree != null
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: content(context, fillViewport: true),
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
                            SizedBox(height: 12),
                            Text(tr(context, status)),
                            if (busy) const LinearProgressIndicator(),
                            SizedBox(height: 20),
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
                              child: Text(
                                tr(context, 'Открыть эталон Fireball'),
                              ),
                            ),
                            SizedBox(height: 24),
                            content(context),
                            SizedBox(height: 32),
                            Text(
                              tr(
                                context,
                                'Windows-прототип · Python + Lua. Остальные редакторы ещё не перенесены.',
                              ),
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
                initialShowPulse: showPulse,
                initialNavigationWidth: navigationWidth,
                initialPulseWidth: pulseWidth,
                onWidths: saveWidths,
                onPulseVisibility: savePanel,
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
