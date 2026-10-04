import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';

import 'tree_art.dart';
import 'tree_tooltip.dart';
import 'tree_settings.dart';
import 'tree_geometry.dart';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

class PassiveTree extends StatefulWidget {
  const PassiveTree({
    super.key,
    required this.data,
    required this.onToggle,
    required this.enabled,
    this.mapHeight = 500,
    this.onInspect,
    this.onAction,
    this.onOptions,
    this.onJewels,
    this.onHistory,
  });
  final Map<String, dynamic> data;
  final Future<void> Function(int) onToggle;
  final bool enabled;
  final double mapHeight;
  final Future<Map<String, dynamic>> Function(int, bool)? onInspect;
  final Future<void> Function(Map<String, dynamic>)? onAction;
  final Future<void> Function(Map<String, dynamic>)? onOptions;
  final Future<Map<String, dynamic>> Function(int)? onJewels;
  final Future<void> Function(bool)? onHistory;
  @override
  State<PassiveTree> createState() => _PassiveTreeState();
}

class _PassiveTreeState extends State<PassiveTree>
    with SingleTickerProviderStateMixin {
  final camera = TransformationController();
  final keyboard = FocusNode();
  final searchFocus = FocusNode();
  late final AnimationController motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  Matrix4? motionStart, motionEnd;
  Timer? hoverDelay;
  int? hovered;
  Offset hoverPosition = Offset.zero;
  Map<String, dynamic>? detail;
  String? inspectError;
  bool compare = true, hideTooltip = false;
  int inspectGeneration = 0;
  final trace = <int>[];
  Map<int, Offset> positions = {};
  Map<int, Map<String, dynamic>> nodeMap = {};
  TreeGeometry? geometry;
  Map<String, dynamic>? geometryData;
  int flashEpoch = 0;
  int? flashNode;
  String query = '';
  int? selected;
  Size viewport = const Size(600, 500);
  bool positioned = false;
  Map<String, ui.Image> art = {};
  String? artVersion;
  String? artError;
  void center(Offset point, [double zoom = 1]) {
    final target = Matrix4.identity()
      ..translateByDouble(
        viewport.width / 2 - point.dx * zoom,
        viewport.height / 2 - point.dy * zoom,
        0,
        1,
      )
      ..scaleByDouble(zoom, zoom, 1, 1);
    motion.stop();
    if (MediaQuery.disableAnimationsOf(context)) {
      camera.value = target;
      return;
    }
    motionStart = camera.value.clone();
    motionEnd = target;
    motion.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    motion.addListener(() {
      final value = Curves.easeOutCubic.transform(motion.value);
      camera.value = Matrix4.fromList(
        List.generate(
          16,
          (i) =>
              motionStart!.storage[i] +
              (motionEnd!.storage[i] - motionStart!.storage[i]) * value,
        ),
      );
    });
  }

  @override
  void didUpdateWidget(covariant PassiveTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) {
      final previous = (oldWidget.data['nodes'] as List)
          .where((node) => node['id'] == selected)
          .firstOrNull;
      final current = (widget.data['nodes'] as List)
          .where((node) => node['id'] == selected)
          .firstOrNull;
      if (previous != null &&
          current != null &&
          previous['allocated'] != current['allocated']) {
        flashNode = selected;
        flashEpoch++;
      }
      detail = null;
      if (hovered != null) inspect(hovered!);
    }
  }

  int? hitTest(Offset point) {
    return geometry?.hitTest(point, camera.value.getMaxScaleOnAxis());
  }

  void inspect(int id) {
    hoverDelay?.cancel();
    final generation = ++inspectGeneration;
    hoverDelay = Timer(const Duration(milliseconds: 180), () async {
      if (widget.onInspect == null) return;
      try {
        final result = await widget.onInspect!(id, compare);
        if (mounted && generation == inspectGeneration && hovered == id) {
          setState(() => detail = result);
        }
      } catch (error) {
        if (mounted && generation == inspectGeneration) {
          setState(
            () => inspectError = 'Не удалось рассчитать подсказку: $error',
          );
        }
      }
    });
  }

  void hover(Offset point) {
    final id = hitTest(point);
    if (id == hovered) return;
    setState(() {
      hovered = id;
      hoverPosition = MatrixUtils.transformPoint(camera.value, point);
      detail = null;
      inspectError = null;
      if (HardwareKeyboard.instance.isShiftPressed && id != null) {
        if (trace.isEmpty && nodeMap[id]!['allocated'] == true) {
          trace.add(id);
        } else if (trace.isNotEmpty &&
            (widget.data['edges'] as List).any(
              (edge) => edge.contains(trace.last) && edge.contains(id),
            )) {
          final existing = trace.indexOf(id);
          if (existing >= 0) {
            trace.removeRange(existing + 1, trace.length);
          } else {
            trace.add(id);
          }
        }
      }
    });
    if (id != null) {
      inspect(id);
    } else {
      hoverDelay?.cancel();
      inspectGeneration++;
    }
  }

  int? get attributeHotkey {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    if (keys.contains(LogicalKeyboardKey.digit2) ||
        keys.contains(LogicalKeyboardKey.keyS)) {
      return 1;
    }
    if (keys.contains(LogicalKeyboardKey.digit3) ||
        keys.contains(LogicalKeyboardKey.keyD)) {
      return 2;
    }
    if (keys.contains(LogicalKeyboardKey.digit1) ||
        keys.contains(LogicalKeyboardKey.keyI)) {
      return 3;
    }
    return null;
  }

  Future<void> applyNode(int id, {bool secondary = false}) async {
    if (!widget.enabled) return;
    final node = nodeMap[id]!;
    setState(() => selected = id);
    if (widget.onAction == null) {
      await widget.onToggle(id);
      return;
    }
    if (secondary && HardwareKeyboard.instance.isShiftPressed) {
      await editNote(node);
      return;
    }
    if (secondary &&
        node['type'] == 'Socket' &&
        node['allocated'] == true &&
        widget.onJewels != null) {
      final choice = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => TreeJewelPicker(load: () => widget.onJewels!(id)),
      );
      if (choice != null && mounted) {
        await widget.onAction!({'id': id, 'action': 'jewel', ...choice});
      }
      return;
    }
    var attribute = attributeHotkey;
    if (!secondary &&
        node['isAttribute'] == true &&
        node['allocated'] != true &&
        attribute == null) {
      attribute = await chooseAttribute();
      if (attribute == null || !mounted) return;
    }
    int? mastery;
    if (node['type'] == 'Mastery' && (secondary || node['allocated'] != true)) {
      mastery = await chooseMastery(node);
      if (mastery == null || !mounted) return;
    }
    await widget.onAction!({
      'id': id,
      'action': secondary ? 'right' : 'toggle',
      'attribute': ?attribute,
      'mastery': ?mastery,
      if (trace.length > 1 && trace.last == id) 'path': List<int>.of(trace),
    });
    trace.clear();
  }

  Future<int?> chooseAttribute() => showDialog<int>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Выберите атрибут'),
      children: [
        for (final option in [
          (1, 'Сила', const Color(0xfffb4934)),
          (2, 'Ловкость', const Color(0xffb8bb26)),
          (3, 'Интеллект', const Color(0xff83a598)),
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, option.$1),
            child: Text(option.$2, style: TextStyle(color: option.$3)),
          ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Удерживайте 2 / S, 3 / D или 1 / I при нажатии.\nПКМ меняет атрибут назначенного узла.',
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
      ],
    ),
  );

  Future<int?> chooseMastery(Map<String, dynamic> node) => showDialog<int>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Выберите эффект мастерства'),
      children: [
        for (final option in (node['masteryEffects'] as List?) ?? [])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, option['effect']),
            child: Text((option['stats'] as List).join('\n')),
          ),
      ],
    ),
  );

  Future<void> editNote(Map<String, dynamic> node) async {
    final text = TextEditingController(text: node['note'] as String? ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Заметка: ${node['name']}'),
        content: TextField(
          controller: text,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Заметка к узлу'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, text.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    text.dispose();
    if (result != null && mounted) {
      await widget.onAction!({
        'id': node['id'],
        'action': 'note',
        'text': result,
      });
    }
  }

  Future<void> showNodeDetails(int id) async {
    final node = nodeMap[id]!;
    final future =
        widget.onInspect?.call(id, compare) ??
        Future.value(<String, dynamic>{
          'lines': [
            for (final text in node['stats'] as List) {'text': text},
          ],
        });
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: future,
                builder: (context, snapshot) => TreeTooltip(
                  node: node,
                  detail: snapshot.data,
                  error: snapshot.hasError ? '${snapshot.error}' : null,
                  maxHeight: MediaQuery.sizeOf(context).height * .65,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: widget.enabled
                        ? () {
                            Navigator.pop(context);
                            applyNode(id);
                          }
                        : null,
                    child: Text(
                      node['allocated'] == true
                          ? 'Вернуть узел'
                          : 'Назначить путь',
                    ),
                  ),
                  if (widget.onAction != null)
                    TextButton(
                      onPressed: widget.enabled
                          ? () {
                              Navigator.pop(context);
                              applyNode(id, secondary: true);
                            }
                          : null,
                      child: const Text('Дополнительное действие'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  KeyEventResult keyEvent(FocusNode focus, KeyEvent event) {
    final hidden =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isShiftPressed;
    if (hidden != hideTooltip) setState(() => hideTooltip = hidden);
    if (!HardwareKeyboard.instance.isShiftPressed && trace.isNotEmpty) {
      setState(trace.clear);
    }
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.onOptions != null &&
        [
          LogicalKeyboardKey.arrowLeft,
          LogicalKeyboardKey.arrowRight,
        ].contains(event.logicalKey)) {
      final next =
          ((widget.data['mode'] as int? ?? 0) +
                  (event.logicalKey == LogicalKeyboardKey.arrowLeft ? -1 : 1))
              .clamp(0, 2);
      if (widget.enabled) widget.onOptions!({'mode': next});
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f1 && hovered != null) {
      showNodeDetails(hovered!);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() {
        hovered = null;
        trace.clear();
      });
      return KeyEventResult.handled;
    }
    if (!HardwareKeyboard.instance.isControlPressed) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyF) {
      searchFocus.requestFocus();
      return KeyEventResult.handled;
    }
    if ([
          LogicalKeyboardKey.keyZ,
          LogicalKeyboardKey.keyY,
        ].contains(event.logicalKey) &&
        widget.onHistory != null &&
        widget.enabled) {
      widget.onHistory!(
        event.logicalKey == LogicalKeyboardKey.keyY ||
            HardwareKeyboard.instance.isShiftPressed,
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      setState(() {
        compare = !compare;
        detail = null;
      });
      if (hovered != null) inspect(hovered!);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyC && hovered != null) {
      final node = nodeMap[hovered]!;
      Clipboard.setData(
        ClipboardData(
          text: plainTreeText(
            '${node['name']}\n${(node['stats'] as List).join('\n')}',
          ),
        ),
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void zoom(double factor) {
    final point = camera.toScene(
      Offset(viewport.width / 2, viewport.height / 2),
    );
    center(point, (camera.value.getMaxScaleOnAxis() * factor).clamp(.15, 8));
  }

  Widget ringOverlay(int id, bool flash) => AnimatedBuilder(
    animation: camera,
    builder: (context, child) {
      final point = MatrixUtils.transformPoint(camera.value, positions[id]!);
      return Positioned(
        left: point.dx - 40,
        top: point.dy - 40,
        width: 80,
        height: 80,
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            key: ValueKey(flash ? 'flash-$flashEpoch' : 'hover-$id'),
            tween: Tween(begin: 0, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : Duration(milliseconds: flash ? 450 : 160),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final radius = flash ? 13 + value * 24 : 13 + (1 - value) * 4;
              final color = flash && nodeMap[id]?['allocated'] != true
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary;
              final opacity = flash ? 1 - value : value;
              return Center(
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: opacity),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: opacity * .25),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );

  @override
  void dispose() {
    hoverDelay?.cancel();
    keyboard.dispose();
    searchFocus.dispose();
    motion.dispose();
    camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final version = widget.data['version'] as String;
    if (version != artVersion) {
      artVersion = version;
      art = TreeArt.ready[version] ?? {};
      TreeArt.load(version)
          .then((images) {
            if (mounted && artVersion == version) {
              setState(() {
                art = images;
                artError = null;
              });
            }
          })
          .catchError((Object error) {
            if (mounted) {
              setState(() => artError = 'Текстуры этой версии недоступны');
            }
          });
    }
    final nodes = (widget.data['nodes'] as List).cast<Map<String, dynamic>>();
    if (nodes.isEmpty) return const Text('Дерево пустое');
    if (!identical(geometryData, widget.data)) {
      geometryData = widget.data;
      geometry = TreeGeometry(nodes);
      positions = geometry!.positions;
      nodeMap = geometry!.byId;
    }
    final scale = geometry!.scale;
    final chosen = nodes.where((n) => n['id'] == selected).firstOrNull;
    final matches = query.isEmpty
        ? <Map<String, dynamic>>[]
        : nodes
              .where(
                (n) => '${n['name']} ${n['stats']}'.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .take(15)
              .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: treeTextSpans(
                    widget.data['pointDisplay'] as String? ??
                        'Дерево $version · ${nodes.length} узлов',
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            if (((widget.data['warnings'] as List?) ?? []).isNotEmpty)
              Tooltip(
                message: ((widget.data['warnings'] as List).map(
                  (line) => plainTreeText(line.toString()),
                )).join('\n'),
                child: Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            if (widget.onOptions != null)
              IconButton(
                tooltip: 'Класс, набор и оружейные режимы',
                onPressed: widget.enabled
                    ? () => showDialog<void>(
                        context: context,
                        builder: (context) => TreeSettings(
                          data: widget.data,
                          onApply: widget.onOptions!,
                        ),
                      )
                    : null,
                icon: const Icon(Icons.tune),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (artError != null) Text(artError!),
        TextField(
          focusNode: searchFocus,
          decoration: const InputDecoration(
            labelText: 'Поиск по названию и свойствам',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => query = value),
        ),
        if (matches.isNotEmpty)
          Wrap(
            children: matches
                .map(
                  (node) => TextButton(
                    onPressed: () {
                      setState(() => selected = node['id'] as int);
                      center(positions[selected]!, 2);
                    },
                    child: Text(node['name'] as String),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: widget.mapHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              viewport = Size(constraints.maxWidth, widget.mapHeight);
              if (!positioned) {
                positioned = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final start = nodes
                      .where(
                        (n) =>
                            n['type'] == 'ClassStart' && n['allocated'] == true,
                      )
                      .firstOrNull;
                  center(
                    start == null
                        ? const Offset(900, 900)
                        : positions[start['id']]!,
                  );
                });
              }
              return Focus(
                focusNode: keyboard,
                onKeyEvent: keyEvent,
                child: Listener(
                  onPointerDown: (event) {
                    keyboard.requestFocus();
                    if (!widget.enabled || widget.onHistory == null) return;
                    if (event.buttons == kBackMouseButton) {
                      widget.onHistory!(false);
                    }
                    if (event.buttons == kForwardMouseButton) {
                      widget.onHistory!(true);
                    }
                  },
                  onPointerMove: (event) {
                    if (event.buttons == kMiddleMouseButton ||
                        event.buttons == kSecondaryMouseButton &&
                            hovered == null) {
                      motion.stop();
                      camera.value = camera.value.clone()
                        ..setTranslationRaw(
                          camera.value.storage[12] + event.delta.dx,
                          camera.value.storage[13] + event.delta.dy,
                          0,
                        );
                    }
                  },
                  child: Stack(
                    key: const ValueKey('tree-viewport'),
                    children: [
                      ClipRect(
                        child: ColoredBox(
                          color: const Color(0xff090d10),
                          child: InteractiveViewer(
                            transformationController: camera,
                            constrained: false,
                            boundaryMargin: const EdgeInsets.all(1800),
                            minScale: .15,
                            maxScale: 8,
                            onInteractionStart: (_) {
                              motion.stop();
                              setState(() => hovered = null);
                            },
                            child: MouseRegion(
                              cursor: hovered == null
                                  ? SystemMouseCursors.grab
                                  : SystemMouseCursors.click,
                              onEnter: (_) => keyboard.requestFocus(),
                              onHover: (event) => hover(event.localPosition),
                              onExit: (_) {
                                setState(() => hovered = null);
                                hoverDelay?.cancel();
                                inspectGeneration++;
                              },
                              child: GestureDetector(
                                onLongPressStart: (event) {
                                  final id = hitTest(event.localPosition);
                                  if (id != null) showNodeDetails(id);
                                },
                                onTapUp: (event) {
                                  final nearest = hitTest(event.localPosition);
                                  setState(() => selected = nearest);
                                  if (nearest != null &&
                                      event.kind == PointerDeviceKind.mouse) {
                                    applyNode(nearest);
                                  }
                                },
                                onSecondaryTapUp: (event) {
                                  final id = hitTest(event.localPosition);
                                  if (id != null) {
                                    applyNode(id, secondary: true);
                                  }
                                },
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    size: const Size(1800, 1800),
                                    painter: _TreePainter(
                                      nodes,
                                      positions,
                                      widget.data['edges'] as List,
                                      selected,
                                      query,
                                      Theme.of(context).colorScheme,
                                      art,
                                      (widget.data['backgrounds'] as List?) ??
                                          [],
                                      geometry!.origin,
                                      scale,
                                      (widget.data['connectors'] as List?) ??
                                          [],
                                      hovered,
                                      trace.isNotEmpty
                                          ? trace.toSet()
                                          : ((nodeMap[hovered]?[nodeMap[hovered]?['allocated'] ==
                                                                true
                                                            ? 'depends'
                                                            : 'path']
                                                        as List?) ??
                                                    [])
                                                .cast<int>()
                                                .toSet(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (hovered != null && positions[hovered] != null)
                        ringOverlay(hovered!, false),
                      if (flashNode != null && positions[flashNode] != null)
                        ringOverlay(flashNode!, true),
                      Positioned(
                        left: (hoverPosition.dx + 22).clamp(
                          8,
                          math.max(
                            8,
                            viewport.width -
                                math.min(440, viewport.width - 16) -
                                8,
                          ),
                        ),
                        top: (hoverPosition.dy + 18).clamp(
                          8,
                          math.max(
                            8,
                            viewport.height -
                                math.min(420, viewport.height - 16) -
                                8,
                          ),
                        ),
                        width: math.min(440, viewport.width - 16),
                        child: IgnorePointer(
                          child: AnimatedSwitcher(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 160),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: .98,
                                      end: 1,
                                    ).animate(animation),
                                    alignment: Alignment.topLeft,
                                    child: child,
                                  ),
                                ),
                            child: hovered == null || hideTooltip
                                ? const SizedBox.shrink()
                                : TreeTooltip(
                                    key: ValueKey(hovered),
                                    node: nodeMap[hovered]!,
                                    detail: detail,
                                    error: inspectError,
                                    maxHeight: math.min(
                                      420,
                                      viewport.height - 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Wrap(
          children: [
            TextButton(
              onPressed: () => center(
                const Offset(900, 900),
                (math.min(viewport.width, viewport.height) / 1800).clamp(
                  .15,
                  8,
                ),
              ),
              child: const Text('Всё дерево'),
            ),
            IconButton(
              onPressed: () => zoom(1.3),
              tooltip: 'Увеличить дерево',
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () => zoom(1 / 1.3),
              tooltip: 'Уменьшить дерево',
              icon: const Icon(Icons.remove),
            ),
            const Text('Перетаскивание · колесо / pinch zoom'),
          ],
        ),
        if (chosen != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chosen['name'] as String,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text((chosen['stats'] as List).join('\n')),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: widget.enabled
                        ? () => applyNode(chosen['id'] as int)
                        : null,
                    child: Text(
                      chosen['allocated'] == true
                          ? 'Вернуть узел и зависимые узлы'
                          : 'Назначить путь к узлу',
                    ),
                  ),
                ],
              ),
            ),
          ),
        const Text(
          'ЛКМ — назначить / вернуть · ПКМ — атрибут · СКМ — перемещение · Shift — проложить путь',
        ),
      ],
    );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter(
    this.nodes,
    this.positions,
    this.edges,
    this.selected,
    this.query,
    this.colors,
    this.art,
    this.backgrounds,
    this.origin,
    this.scale,
    this.connectors,
    this.hovered,
    this.path,
  );
  final List<Map<String, dynamic>> nodes;
  final Map<int, Offset> positions;
  final List edges;
  final int? selected;
  final String query;
  final ColorScheme colors;
  final Map<String, ui.Image> art;
  final List backgrounds;
  final Offset origin;
  final double scale;
  final List connectors;
  final int? hovered;
  final Set<int> path;
  late final byId = {for (final node in nodes) node['id'] as int: node};
  Offset treePoint(num x, num y) =>
      Offset((x - origin.dx) * scale + 50, (y - origin.dy) * scale + 50);
  void connector(
    Canvas canvas,
    Map<String, dynamic> connector,
    String state,
    Color tint,
  ) {
    final texture = art[connector['assets'][state]];
    if (texture == null) return;
    final vertices = connector['vertices'][state] as List;
    final uv = connector['uv'] as List;
    final points = [
      for (var i = 0; i < 8; i += 2)
        treePoint(vertices[i] as num, vertices[i + 1] as num),
    ];
    final bounds = Rect.fromLTRB(
      points.map((p) => p.dx).reduce(math.min),
      points.map((p) => p.dy).reduce(math.min),
      points.map((p) => p.dx).reduce(math.max),
      points.map((p) => p.dy).reduce(math.max),
    );
    if (!bounds.overlaps(canvas.getLocalClipBounds())) return;
    final coordinates = [
      for (var i = 0; i < 8; i += 2)
        Offset(
          (uv[i] as num).toDouble() * texture.width,
          (uv[i + 1] as num).toDouble() * texture.height,
        ),
    ];
    canvas.drawVertices(
      ui.Vertices(
        ui.VertexMode.triangles,
        points,
        textureCoordinates: coordinates,
        indices: [0, 1, 2, 0, 2, 3],
      ),
      BlendMode.srcOver,
      Paint()
        ..colorFilter = ColorFilter.mode(tint, BlendMode.modulate)
        ..shader = ui.ImageShader(
          texture,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        )
        ..filterQuality = FilterQuality.medium,
    );
  }

  void image(
    Canvas canvas,
    ui.Image image,
    Rect destination, [
    double brightness = 1,
    double opacity = 1,
  ]) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destination,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, opacity)
        ..colorFilter = ColorFilter.matrix([
          brightness,
          0,
          0,
          0,
          0,
          0,
          brightness,
          0,
          0,
          0,
          0,
          0,
          brightness,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ])
        ..filterQuality = FilterQuality.medium,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final background in backgrounds) {
      final texture = art[background['image']];
      if (texture == null) continue;
      final center = treePoint(background['x'] as num, background['y'] as num);
      final width = (background['width'] as num) * scale;
      final height = (background['height'] as num) * scale;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(((background['rotation'] as num?) ?? 0).toDouble());
      image(
        canvas,
        texture,
        Rect.fromCenter(
          center: background['half'] == true
              ? Offset(0, -height / 2)
              : Offset.zero,
          width: width,
          height: height,
        ),
        ((background['brightness'] as num?) ?? 1).toDouble(),
      );
      if (background['half'] == true) {
        canvas.scale(1, -1);
        image(
          canvas,
          texture,
          Rect.fromCenter(
            center: Offset(0, -height / 2),
            width: width,
            height: height,
          ),
        );
      }
      canvas.restore();
    }
    final allocated = nodes
        .where((n) => n['allocated'] == true)
        .map((n) => n['id'])
        .toSet();
    for (final data in connectors) {
      final a = byId[data['a']], b = byId[data['b']];
      if (a == null || b == null) continue;
      final modeA = a['allocMode'] as int? ?? 0;
      final modeB = b['allocMode'] as int? ?? 0;
      final active =
          allocated.contains(data['a']) &&
          allocated.contains(data['b']) &&
          (modeA == 0 || modeB == 0 || modeA == modeB);
      final compared =
          a['compareAllocated'] == true && b['compareAllocated'] == true;
      final preview =
          (path.contains(data['a']) || a['allocated'] == true) &&
          (path.contains(data['b']) || b['allocated'] == true) &&
          (path.contains(data['a']) || path.contains(data['b']));
      var tint = Colors.white;
      if (a['compareAllocated'] != null && active != compared) {
        tint = compared ? const Color(0xffb8bb26) : const Color(0xfffb4934);
      } else if (preview && byId[hovered]?['allocated'] == true) {
        tint = const Color(0xfffb4934);
      } else if (active && (modeA != 0 || modeB != 0)) {
        tint = (modeA != 0 ? modeA : modeB) == 1
            ? const Color(0xfffb4934)
            : const Color(0xffb8bb26);
      }
      connector(
        canvas,
        data as Map<String, dynamic>,
        active || compared
            ? 'Active'
            : preview
            ? 'Intermediate'
            : 'Normal',
        tint,
      );
    }
    for (final edge in connectors.isEmpty ? edges : []) {
      final a = positions[edge[0]], b = positions[edge[1]];
      if (a == null || b == null) continue;
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = allocated.contains(edge[0]) && allocated.contains(edge[1])
              ? const Color(0xffbfa16a)
              : const Color(0xff423b2a)
          ..strokeWidth = 1,
      );
    }
    for (final node in nodes) {
      final id = node['id'] as int;
      final point = positions[id]!;
      if (!Rect.fromCircle(
        center: point,
        radius: 400 * scale,
      ).overlaps(canvas.getLocalClipBounds())) {
        continue;
      }
      final match =
          query.isNotEmpty &&
          '${node['name']} ${node['stats']}'.toLowerCase().contains(
            query.toLowerCase(),
          );
      final kind = node['type'];
      final texture = art[kind == 'OnlyImage' ? node['effect'] : node['icon']];
      final target = node['targetSize'] as Map<String, dynamic>?;
      final radius = ((target?['width'] as num?) ?? 37) * scale;
      final effect = art[node['effect']];
      if (effect != null && kind != 'OnlyImage') {
        final effectSize = target?['effect'] as Map<String, dynamic>?;
        image(
          canvas,
          effect,
          Rect.fromCenter(
            center: point,
            width: ((effectSize?['width'] as num?) ?? 380) * scale * 2,
            height: ((effectSize?['height'] as num?) ?? 380) * scale * 2,
          ),
          1,
          allocated.contains(id) ? 1 : .15,
        );
      }
      if (kind == 'ClassStart' || kind == 'AscendClassStart') continue;
      if (texture != null) {
        image(
          canvas,
          texture,
          Rect.fromCircle(center: point, radius: radius),
          kind == 'OnlyImage' || allocated.contains(id) ? 1 : .5,
          kind == 'OnlyImage' ? .15 : 1,
        );
      } else {
        canvas.drawCircle(
          point,
          radius,
          Paint()
            ..color = allocated.contains(id)
                ? colors.primary
                : colors.onSurfaceVariant,
        );
      }
      final frames = {
        'Normal': ['PSSkillFrame', 'PSSkillFrameActive'],
        'Notable': ['NotableFrameUnallocated', 'NotableFrameAllocated'],
        'Keystone': ['KeystoneFrameUnallocated', 'KeystoneFrameAllocated'],
        'Socket': ['JewelFrameUnallocated', 'JewelFrameAllocated'],
      };
      final names = frames[kind] ?? frames['Normal']!;
      final overlay = node['overlay'] as Map<String, dynamic>?;
      final frame =
          art[overlay?[allocated.contains(id) || id == hovered
                  ? 'alloc'
                  : path.contains(id)
                  ? 'path'
                  : 'unalloc'] ??
              names[allocated.contains(id) ? 1 : 0]];
      final overlaySize = target?['overlay'] as Map<String, dynamic>?;
      if (frame != null && kind != 'ClassStart' && kind != 'OnlyImage') {
        image(
          canvas,
          frame,
          Rect.fromCenter(
            center: point,
            width: ((overlaySize?['width'] as num?) ?? 54) * scale * 2,
            height: ((overlaySize?['height'] as num?) ?? 54) * scale * 2,
          ),
        );
      }
      final jewel = art[node['jewel']];
      if (jewel != null) {
        image(
          canvas,
          jewel,
          Rect.fromCircle(center: point, radius: radius * .75),
        );
      }
      final jewelRadius = node['radius'] as Map<String, dynamic>?;
      if (jewelRadius != null) {
        final outer = (jewelRadius['outer'] as num).toDouble() * scale;
        final inner = (jewelRadius['inner'] as num).toDouble() * scale;
        final ring = Path()
          ..fillType = PathFillType.evenOdd
          ..addOval(Rect.fromCircle(center: point, radius: outer));
        if (inner > 0) {
          ring.addOval(Rect.fromCircle(center: point, radius: inner));
        }
        canvas.drawPath(
          ring,
          Paint()..color = colors.primary.withValues(alpha: .04),
        );
        canvas.drawCircle(
          point,
          outer,
          Paint()
            ..color = colors.primary.withValues(alpha: .5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .8,
        );
        if (inner > 0) {
          canvas.drawCircle(
            point,
            inner,
            Paint()
              ..color = colors.primary.withValues(alpha: .5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = .8,
          );
        }
      }
      if (id == selected || id == hovered || match) {
        canvas.drawCircle(
          point,
          radius + 4,
          Paint()
            ..color = colors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      if (node['compareAllocated'] != null &&
          node['compareAllocated'] != node['allocated']) {
        canvas.drawCircle(
          point,
          radius + 2,
          Paint()
            ..color = node['compareAllocated'] == true
                ? const Color(0xffb8bb26)
                : const Color(0xfffb4934)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => true;
}
