import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class TreeArt {
  static final ready = <String, Map<String, ui.Image>>{};
  static final Map<String, Future<Map<String, ui.Image>>> _cache = {};
  static Future<Map<String, ui.Image>> load(String version) =>
      _cache.putIfAbsent(version, () => _load(version));
  static Future<Map<String, ui.Image>> _load(String version) async {
    final prefix = 'assets/tree/$version/';
    final manifest = jsonDecode(
      await rootBundle.loadString('${prefix}manifest.json'),
    ) as Map<String, dynamic>;
    final images = <String, ui.Image>{};
    // Последовательная загрузка ограничивает пиковое потребление памяти декодера.
    for (final entry in manifest.entries) {
      final bytes = await rootBundle.load('$prefix${entry.value['file']}');
      final codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      images[entry.key] = (await codec.getNextFrame()).image;
      codec.dispose();
    }
    ready[version] = images;
    return images;
  }
}
