import 'package:material_ui/material_ui.dart';

/// Fonte desenhada para distinguir bem os caracteres, útil em leitura rápida.
const appFont = 'Atkinson Hyperlegible';

const _ink = Color(0xFF14213D);
const _blue = Color(0xFF006FA8);
const _signal = Color(0xFFF2A900);
const _paper = Color(0xFFF7F9F9);

ColorScheme _colors(Brightness brightness) {
  final base = ColorScheme.fromSeed(seedColor: _blue, brightness: brightness);
  if (brightness == Brightness.light) {
    return base.copyWith(
      primary: _blue,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFCDE9F7),
      onPrimaryContainer: _ink,
      secondaryContainer: const Color(0xFFDCE7EA),
      onSecondaryContainer: _ink,
      tertiary: _signal,
      onTertiary: _ink,
      surface: _paper,
      onSurface: _ink,
      onSurfaceVariant: const Color(0xFF47546B),
      surfaceContainerLow: Colors.white,
      outlineVariant: const Color(0xFFC9D5D9),
    );
  }
  return base.copyWith(
    primary: const Color(0xFF7CCBEF),
    onPrimary: const Color(0xFF00283F),
    primaryContainer: const Color(0xFF0B4766),
    onPrimaryContainer: const Color(0xFFD6EFFC),
    secondaryContainer: const Color(0xFF243940),
    onSecondaryContainer: const Color(0xFFDCE7EA),
    tertiary: const Color(0xFFFFC247),
    onTertiary: _ink,
    surface: const Color(0xFF0F1A1D),
    onSurface: const Color(0xFFE6EEF0),
    onSurfaceVariant: const Color(0xFFB4C4C9),
    surfaceContainerLow: const Color(0xFF16252A),
    outlineVariant: const Color(0xFF33474E),
  );
}

ThemeData buildTheme(Brightness brightness) {
  final colors = _colors(brightness);
  return ThemeData(
    colorScheme: colors,
    fontFamily: appFont,
    scaffoldBackgroundColor: colors.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      centerTitle: false,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.tertiary,
      foregroundColor: colors.onTertiary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
