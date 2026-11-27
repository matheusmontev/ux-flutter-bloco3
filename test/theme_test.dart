import 'package:eventos_academicos/core/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Razão de contraste da WCAG entre duas cores opacas.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final high = la > lb ? la : lb;
  final low = la > lb ? lb : la;
  return (high + 0.05) / (low + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('usa as cores da identidade no tema claro', () {
    final colors = buildTheme(Brightness.light).colorScheme;

    expect(colors.primary, const Color(0xFF006FA8));
    expect(colors.tertiary, const Color(0xFFF2A900));
    expect(colors.surface, const Color(0xFFF7F9F9));
    expect(colors.onSurface, const Color(0xFF14213D));
  });

  for (final brightness in Brightness.values) {
    group('tema ${brightness.name}', () {
      final theme = buildTheme(brightness);
      final colors = theme.colorScheme;

      test('textos têm contraste mínimo de 4,5:1', () {
        final pairs = {
          'superfície': (colors.onSurface, colors.surface),
          'texto secundário': (colors.onSurfaceVariant, colors.surface),
          'primária': (colors.onPrimary, colors.primary),
          'primária como texto': (colors.primary, colors.surface),
          'sinal': (colors.onTertiary, colors.tertiary),
          'destaque': (colors.onPrimaryContainer, colors.primaryContainer),
          'etiqueta': (colors.onSecondaryContainer, colors.secondaryContainer),
          'erro': (colors.onErrorContainer, colors.errorContainer),
        };

        for (final MapEntry(key: name, value: (text, back)) in pairs.entries) {
          expect(
            _contrast(text, back),
            greaterThanOrEqualTo(4.5),
            reason: name,
          );
        }
      });

      test('usa a fonte Atkinson Hyperlegible', () {
        expect(theme.textTheme.bodyMedium?.fontFamily, 'Atkinson Hyperlegible');
        expect(theme.textTheme.titleLarge?.fontFamily, 'Atkinson Hyperlegible');
      });

      test('botão de check-in usa a cor de sinal', () {
        final button = theme.floatingActionButtonTheme;

        expect(button.backgroundColor, colors.tertiary);
        expect(button.foregroundColor, colors.onTertiary);
      });
    });
  }

  test('os arquivos da fonte e a licença estão no aplicativo', () async {
    for (final file in [
      'AtkinsonHyperlegible-Regular.ttf',
      'AtkinsonHyperlegible-Bold.ttf',
      'OFL.txt',
    ]) {
      final data = await rootBundle.load('assets/fonts/$file');

      expect(data.lengthInBytes, greaterThan(1000), reason: file);
    }
  });
}
