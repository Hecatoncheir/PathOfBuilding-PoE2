import 'package:flutter/material.dart';

@immutable
class WorkshopColors extends ThemeExtension<WorkshopColors> {
  const WorkshopColors({
    required this.raised,
    required this.line,
    required this.muted,
    required this.gold,
  });
  final Color raised, line, muted, gold;

  @override
  WorkshopColors copyWith({
    Color? raised,
    Color? line,
    Color? muted,
    Color? gold,
  }) => WorkshopColors(
    raised: raised ?? this.raised,
    line: line ?? this.line,
    muted: muted ?? this.muted,
    gold: gold ?? this.gold,
  );

  @override
  WorkshopColors lerp(covariant WorkshopColors? other, double t) {
    if (other == null) return this;
    return WorkshopColors(
      raised: Color.lerp(raised, other.raised, t)!,
      line: Color.lerp(line, other.line, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

ThemeData workshopTheme(bool dark) {
  final background = Color(dark ? 0xff282828 : 0xfffbf1c7);
  final panel = Color(dark ? 0xff32302f : 0xfff2e5bc);
  final text = Color(dark ? 0xffebdbb2 : 0xff3c3836);
  final accent = Color(dark ? 0xffb8bb26 : 0xff625e0a);
  final tokens = WorkshopColors(
    raised: Color(dark ? 0xff3c3836 : 0xffebdbb2),
    line: Color(dark ? 0xff665c54 : 0xffa89984),
    muted: Color(dark ? 0xffbdae93 : 0xff665c54),
    gold: Color(dark ? 0xfffabd2f : 0xff835000),
  );
  final scheme =
      ColorScheme.fromSeed(
        seedColor: accent,
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: accent,
        onPrimary: background,
        surface: panel,
        onSurface: text,
        onSurfaceVariant: tokens.muted,
        outline: tokens.line,
        outlineVariant: tokens.line,
        secondary: tokens.gold,
        error: Color(dark ? 0xfffb8c7e : 0xff9d0006),
        surfaceContainerHighest: tokens.raised,
      );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
  final button = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
    shape: WidgetStatePropertyAll(shape),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    extensions: [tokens],
    dividerColor: tokens.line,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(48, 48))),
    ),
    listTileTheme: const ListTileThemeData(minTileHeight: 48),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: tokens.line)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: panel,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: tokens.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(style: button),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: button.copyWith(
        foregroundColor: WidgetStatePropertyAll(text),
        side: WidgetStatePropertyAll(BorderSide(color: tokens.line)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: button),
    cardTheme: CardThemeData(
      color: panel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: tokens.line),
      ),
    ),
  );
}
