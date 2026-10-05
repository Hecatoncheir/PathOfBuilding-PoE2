import 'dart:io';

import 'package:flutter/material.dart';

import 'build_library.dart';
import 'ui_text.dart';

class BuildLibraryView extends StatefulWidget {
  const BuildLibraryView({
    super.key,
    required this.library,
    required this.onOpen,
    required this.onSave,
    required this.enabled,
    required this.canSave,
    required this.onRename,
  });
  final BuildLibrary library;
  final Future<void> Function(File) onOpen;
  final Future<void> Function(String, String) onSave;
  final bool enabled, canSave;
  final void Function(File, File) onRename;
  @override
  State<BuildLibraryView> createState() => _BuildLibraryViewState();
}

class _BuildLibraryViewState extends State<BuildLibraryView> {
  List<File> files = [];
  String query = '', error = '';
  bool loading = true;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final result = await widget.library.list();
      if (mounted) {
        setState(() {
          files = result;
          error = '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> edit({File? source, bool copy = false}) async {
    final name = TextEditingController();
    final folder = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr(
            context,
            source == null
                ? 'Сохранить в библиотеку'
                : copy
                ? 'Копировать сборку'
                : 'Переименовать сборку',
          ),
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: tr(context, 'Название сборки'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: folder,
                decoration: InputDecoration(
                  labelText: tr(context, 'Папка (необязательно)'),
                ),
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
            onPressed: () => Navigator.pop(context, (folder.text, name.text)),
            child: Text(tr(context, 'Сохранить')),
          ),
        ],
      ),
    );
    // Контроллеры освобождаются после завершения анимации диалога.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    folder.dispose();
    if (result == null || !mounted) return;
    try {
      if (source == null) {
        await widget.onSave(result.$1, result.$2);
      } else if (copy) {
        await widget.library.copy(source, result.$1, result.$2);
      } else {
        final target = await widget.library.rename(
          source,
          result.$1,
          result.$2,
        );
        widget.onRename(source, target);
      }
      await refresh();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          FilledButton.icon(
            onPressed: widget.canSave ? () => edit() : null,
            icon: const Icon(Icons.save_outlined),
            label: Text(tr(context, 'Сохранить в библиотеку')),
          ),
          OutlinedButton.icon(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
            label: Text(tr(context, 'Обновить')),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextField(
        onChanged: (value) => setState(() => query = value.toLowerCase()),
        decoration: InputDecoration(
          labelText: tr(context, 'Поиск сборок'),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 12),
      if (loading) const LinearProgressIndicator(),
      if (error.isNotEmpty) SelectableText(error),
      if (!loading && files.isEmpty) Text(tr(context, 'Библиотека пока пуста')),
      for (final file in files.where(
        (file) => widget.library.relative(file).toLowerCase().contains(query),
      ))
        Card(
          child: ListTile(
            title: Text(widget.library.relative(file)),
            onTap: widget.enabled ? () => widget.onOpen(file) : null,
            leading: const Icon(Icons.description_outlined),
            trailing: PopupMenuButton<bool>(
              enabled: widget.enabled,
              onSelected: (copy) => edit(source: file, copy: copy),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: true,
                  child: Text(tr(context, 'Копировать сборку')),
                ),
                PopupMenuItem(
                  value: false,
                  child: Text(tr(context, 'Переименовать сборку')),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
