import 'package:flutter/material.dart';

String plainTreeText(String text) =>
    text.replaceAll(RegExp(r'\^(?:x[0-9a-fA-F]{6}|[0-9])'), '');

List<TextSpan> treeTextSpans(String text, Color fallback) {
  const palette = [
    Color(0xff181818),
    Color(0xfffb4934),
    Color(0xffb8bb26),
    Color(0xfffabd2f),
    Color(0xff83a598),
    Color(0xffd3869b),
    Color(0xff8ec07c),
    Color(0xffebdbb2),
    Color(0xffa89984),
    Color(0xffd65d0e),
  ];
  final spans = <TextSpan>[];
  var color = fallback;
  var offset = 0;
  for (final match in RegExp(r'\^(x[0-9a-fA-F]{6}|[0-9])').allMatches(text)) {
    if (match.start > offset) {
      spans.add(
        TextSpan(
          text: text.substring(offset, match.start),
          style: TextStyle(color: color),
        ),
      );
    }
    final code = match.group(1)!;
    color = code.startsWith('x')
        ? Color(0xff000000 | int.parse(code.substring(1), radix: 16))
        : palette[int.parse(code)];
    if (code == '7') color = fallback;
    if (fallback.computeLuminance() < .3 && color.computeLuminance() > .3) {
      color = HSLColor.fromColor(color).withLightness(.32).toColor();
    }
    offset = match.end;
  }
  spans.add(
    TextSpan(
      text: text.substring(offset),
      style: TextStyle(color: color),
    ),
  );
  return spans;
}

class TreeTooltip extends StatelessWidget {
  const TreeTooltip({
    super.key,
    required this.node,
    this.detail,
    this.error,
    required this.maxHeight,
  });
  final Map<String, dynamic> node;
  final Map<String, dynamic>? detail;
  final String? error;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lines =
        (detail?['lines'] as List?) ??
        [
          for (final text in node['stats'] as List) {'text': text, 'size': 14},
        ];
    return Material(
      color: colors.surface.withValues(alpha: .97),
      elevation: 16,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.primary.withValues(alpha: .65)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plainTreeText(node['name'] as String),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(),
              Text(
                'F1 — открыть полную подсказку',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
              if (((detail?['recipe'] as List?) ?? []).isNotEmpty)
                Text(
                  'Рецепт: ${(detail!['recipe'] as List).join(' · ')}',
                  style: TextStyle(color: colors.primary),
                ),
              for (final line in lines)
                if (line['separator'] == true)
                  const Divider(height: 16)
                else if (line['size'] != 24)
                  Text.rich(
                    TextSpan(
                      children: treeTextSpans(
                        line['text'] as String,
                        colors.onSurface,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
              if (detail == null && error == null)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (error != null)
                Text(error!, style: TextStyle(color: colors.error)),
              const SizedBox(height: 10),
              Text(
                'ЛКМ — назначить / вернуть · ПКМ — атрибут\nCtrl — скрыть · Ctrl+C — копировать · Ctrl+D — сравнение',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
