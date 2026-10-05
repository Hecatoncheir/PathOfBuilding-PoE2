import 'ui_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<int?> searchSections(BuildContext context, List<String> sections) =>
    showDialog<int>(
      context: context,
      builder: (_) => _SectionSearch(sections: sections),
    );

class _SectionSearch extends StatefulWidget {
  const _SectionSearch({required this.sections});
  final List<String> sections;
  @override
  State<_SectionSearch> createState() => _SectionSearchState();
}

class _SectionSearchState extends State<_SectionSearch> {
  String query = '';
  int selected = 0;
  List<int> get matches => [
    for (var i = 0; i < widget.sections.length; i++)
      if (tr(
        context,
        widget.sections[i],
      ).toLowerCase().contains(query.toLowerCase()))
        i,
  ];

  void move(int offset) {
    if (matches.isEmpty) return;
    setState(() => selected = (selected + offset).clamp(0, matches.length - 1));
  }

  void open() {
    if (matches.isNotEmpty) Navigator.pop(context, matches[selected]);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520, maxHeight: 420),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => move(1),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => move(-1),
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: tr(context, 'Поиск раздела'),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() {
                  query = value;
                  selected = 0;
                }),
                onSubmitted: (_) => open(),
              ),
              SizedBox(height: 12),
              if (matches.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(tr(context, 'Раздел не найден')),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (var index = 0; index < matches.length; index++)
                      ListTile(
                        selected: index == selected,
                        selectedTileColor: Theme.of(context).colorScheme.primary
                            .withValues(alpha: .12),
                        title: Text(
                          tr(context, widget.sections[matches[index]]),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => Navigator.pop(context, matches[index]),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                tr(context, '↑ ↓ — выбор · Enter — открыть · Esc — закрыть'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
