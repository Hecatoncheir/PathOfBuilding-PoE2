import 'dart:math' as math;
import 'dart:ui' as ui;

import 'tree_art.dart';

import 'package:flutter/material.dart';

class PassiveTree extends StatefulWidget {
  const PassiveTree({
    super.key,
    required this.data,
    required this.onToggle,
    required this.enabled,
    this.mapHeight = 500,
  });
  final Map<String, dynamic> data;
  final Future<void> Function(int) onToggle;
  final bool enabled;
  final double mapHeight;
  @override
  State<PassiveTree> createState() => _PassiveTreeState();
}

class _PassiveTreeState extends State<PassiveTree> {
  final camera = TransformationController();
  String query = '';
  int? selected;
  Size viewport = const Size(600, 500);
  bool positioned = false;
  Map<String, ui.Image> art = {};
  String? artVersion;
  String? artError;
  void center(Offset point, [double zoom = 1]) {
    camera.value = Matrix4.identity()
      ..translateByDouble(
        viewport.width / 2 - point.dx * zoom,
        viewport.height / 2 - point.dy * zoom,
        0,
        1,
      )
      ..scaleByDouble(zoom, zoom, 1, 1);
  }

  void zoom(double factor) {
    final point = camera.toScene(
      Offset(viewport.width / 2, viewport.height / 2),
    );
    center(point, (camera.value.getMaxScaleOnAxis() * factor).clamp(.15, 8));
  }

  @override
  void dispose() {
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
    final minX = nodes.map((n) => (n['x'] as num).toDouble()).reduce(math.min);
    final maxX = nodes.map((n) => (n['x'] as num).toDouble()).reduce(math.max);
    final minY = nodes.map((n) => (n['y'] as num).toDouble()).reduce(math.min);
    final maxY = nodes.map((n) => (n['y'] as num).toDouble()).reduce(math.max);
    final scale = 1700 / math.max(1, math.max(maxX - minX, maxY - minY));
    final positions = {
      for (final node in nodes)
        node['id'] as int: Offset(
          ((node['x'] as num) - minX) * scale + 50,
          ((node['y'] as num) - minY) * scale + 50,
        ),
    };
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
        Text(
          'Дерево ${widget.data['version']} · ${nodes.length} узлов · ${nodes.where((n) => n['allocated'] == true).length} назначено (включая стартовые)',
        ),
        const SizedBox(height: 12),
        if (artError != null) Text(artError!),
        TextField(
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
              return ClipRect(
                child: ColoredBox(
                  color: const Color(0xff090d10),
                  child: InteractiveViewer(
                    transformationController: camera,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(1800),
                    minScale: .15,
                    maxScale: 8,
                    child: GestureDetector(
                      onTapUp: (event) {
                        int? nearest;
                        double distance = 22 / camera.value.getMaxScaleOnAxis();
                        for (final entry in positions.entries) {
                          final d =
                              (entry.value - event.localPosition).distance;
                          if (d < distance) {
                            nearest = entry.key;
                            distance = d;
                          }
                        }
                        setState(() => selected = nearest);
                      },
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
                          (widget.data['backgrounds'] as List?) ?? [],
                          Offset(minX, minY),
                          scale,
                        ),
                      ),
                    ),
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
                        ? () => widget.onToggle(chosen['id'] as int)
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
          'Базовый редактор: специальные выборы, самоцветы и оружейные наборы ещё не подключены.',
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
  void image(
    Canvas canvas,
    ui.Image image,
    Rect destination, [
    double opacity = 1,
  ]) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destination,
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, opacity)
        ..filterQuality = FilterQuality.medium,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final background in backgrounds) {
      final texture = art[background['image']];
      if (texture == null) continue;
      final center = Offset(
        ((background['x'] as num) - origin.dx) * scale + 50,
        ((background['y'] as num) - origin.dy) * scale + 50,
      );
      image(
        canvas,
        texture,
        Rect.fromCenter(
          center: center,
          width: (background['width'] as num) * scale,
          height: (background['height'] as num) * scale,
        ),
        .65,
      );
    }
    final allocated = nodes
        .where((n) => n['allocated'] == true)
        .map((n) => n['id'])
        .toSet();
    for (final edge in edges) {
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
      final match =
          query.isNotEmpty &&
          '${node['name']} ${node['stats']}'.toLowerCase().contains(
            query.toLowerCase(),
          );
      final texture = art[node['icon']];
      final radius = texture == null ? 32 * scale : texture.width * scale / 2;
      if (texture != null) {
        image(
          canvas,
          texture,
          Rect.fromCircle(center: point, radius: radius),
          allocated.contains(id) ? 1 : .65,
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
      final kind = node['type'];
      final frames = {
        'Normal': ['PSSkillFrame', 'PSSkillFrameActive'],
        'Notable': ['NotableFrameUnallocated', 'NotableFrameAllocated'],
        'Keystone': ['KeystoneFrameUnallocated', 'KeystoneFrameAllocated'],
        'Socket': ['JewelFrameUnallocated', 'JewelFrameAllocated'],
      };
      final names = frames[kind] ?? frames['Normal']!;
      final frame = art[names[allocated.contains(id) ? 1 : 0]];
      if (frame != null) {
        image(
          canvas,
          frame,
          Rect.fromCenter(
            center: point,
            width: frame.width * scale,
            height: frame.height * scale,
          ),
        );
      }
      if (id == selected || match) {
        canvas.drawCircle(
          point,
          radius + 4,
          Paint()
            ..color = colors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => true;
}
