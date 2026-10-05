import 'ui_text.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class UiPreferences {
  UiPreferences(this.file);
  final File file;
  Future<void> _pending = Future.value();

  factory UiPreferences.local() {
    final directory =
        Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
    return UiPreferences(
      File('$directory/PathOfBuildingWorkshop/settings.json'),
    );
  }

  Map<String, dynamic> _read() {
    try {
      return Map<String, dynamic>.from(
        jsonDecode(file.readAsStringSync()) as Map,
      );
    } on FileSystemException {
      return {};
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  ThemeMode readTheme() => switch (_read()['theme']) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };

  String readLanguage() => _read()['language'] == 'en' ? 'en' : 'ru';
  bool readReducedMotion() => _read()['reducedMotion'] == true;
  double readWidth(String key, double fallback) => (_read()[key] is num)
      ? (_read()[key] as num).toDouble().clamp(180, 360)
      : fallback;
  Future<void> saveLanguage(String value) => _save('language', value);
  Future<void> saveReducedMotion(bool value) => _save('reducedMotion', value);
  Future<void> saveWidths(double navigation, double pulse) async {
    await _save('navigationWidth', navigation);
    await _save('pulseWidth', pulse);
  }

  bool readPanel() => _read()['showPulse'] != false;

  Future<void> saveTheme(ThemeMode mode) => _save('theme', mode.name);
  Future<void> savePanel(bool visible) => _save('showPulse', visible);

  Future<void> _save(String key, Object value) {
    final operation = _pending.then((_) async {
      final values = _read()..[key] = value;
      await file.parent.create(recursive: true);
      final temporary = File('${file.path}.pending');
      await temporary.writeAsString(jsonEncode(values), flush: true);
      await temporary.rename(file.path);
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }
}

class ThemeMenu extends StatelessWidget {
  const ThemeMenu({super.key, required this.mode, required this.onSelected});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton<ThemeMode>(
    tooltip: tr(context, 'Выбрать тему'),
    initialValue: mode,
    onSelected: onSelected,
    icon: const Icon(Icons.contrast),
    itemBuilder: (_) => [
      for (final entry in [
        (ThemeMode.dark, 'Gruvbox Dark'),
        (ThemeMode.light, 'Gruvbox Light'),
        (ThemeMode.system, tr(context, 'Как в системе')),
      ])
        CheckedPopupMenuItem(
          value: entry.$1,
          checked: mode == entry.$1,
          child: Text(tr(context, entry.$2)),
        ),
    ],
  );
}
