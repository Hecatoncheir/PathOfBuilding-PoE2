import 'dart:math' as math;

import 'package:flutter/material.dart';

class TreeGeometry {
  TreeGeometry(this.nodes) {
    final minX = nodes.map((n) => (n['x'] as num).toDouble()).reduce(math.min);
    final minY = nodes.map((n) => (n['y'] as num).toDouble()).reduce(math.min);
    final maxX = nodes.map((n) => (n['x'] as num).toDouble()).reduce(math.max);
    final maxY = nodes.map((n) => (n['y'] as num).toDouble()).reduce(math.max);
    origin = Offset(minX, minY);
    scale = 1700 / math.max(1, math.max(maxX - minX, maxY - minY));
    for (final node in nodes) {
      final id = node['id'] as int;
      final point = Offset(
        ((node['x'] as num) - minX) * scale + 50,
        ((node['y'] as num) - minY) * scale + 50,
      );
      positions[id] = point;
      byId[id] = node;
      final cell = (
        (point.dx / cellSize).floor(),
        (point.dy / cellSize).floor(),
      );
      cells.putIfAbsent(cell, () => []).add(id);
    }
  }
  static const cellSize = 64.0;
  final List<Map<String, dynamic>> nodes;
  late final Offset origin;
  late final double scale;
  final positions = <int, Offset>{};
  final byId = <int, Map<String, dynamic>>{};
  final cells = <(int, int), List<int>>{};

  int? hitTest(Offset point, double zoom) {
    final reach = math.max(12 / zoom, 120 * scale);
    var nearestDistance = double.infinity;
    int? nearest;
    for (
      var x = ((point.dx - reach) / cellSize).floor();
      x <= ((point.dx + reach) / cellSize).floor();
      x++
    ) {
      for (
        var y = ((point.dy - reach) / cellSize).floor();
        y <= ((point.dy + reach) / cellSize).floor();
        y++
      ) {
        for (final id in cells[(x, y)] ?? <int>[]) {
          final node = byId[id]!;
          if ([
            'OnlyImage',
            'ClassStart',
            'AscendClassStart',
          ].contains(node['type'])) {
            continue;
          }
          final target = node['targetSize'] as Map<String, dynamic>?;
          final radius = math.max(
            6 / zoom,
            ((target?['width'] as num?) ?? 37) * scale,
          );
          final distance = (positions[id]! - point).distance;
          if (distance <= radius && distance < nearestDistance) {
            nearest = id;
            nearestDistance = distance;
          }
        }
      }
    }
    return nearest;
  }
}
