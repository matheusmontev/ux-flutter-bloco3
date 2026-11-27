/// As cores da marca e o desenho da logo têm cópias fora do tema. Estes testes
/// avisam quando uma delas fica para trás.
library;

import 'dart:convert';
import 'dart:io';

import 'package:eventos_academicos/core/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        .toUpperCase();

/// Os números de um trecho, na ordem em que aparecem.
List<double> _numbers(String source, String pattern) {
  final match = RegExp(pattern).firstMatch(source)!.group(1)!;
  return [
    for (final n in RegExp(r'\d+(\.\d+)?').allMatches(match))
      double.parse(n.group(0)!),
  ];
}

void main() {
  final light = buildTheme(Brightness.light).colorScheme;
  final dark = buildTheme(Brightness.dark).colorScheme;

  test('o tema usa as cores da marca', () {
    expect(light.primary, brandBlue);
    expect(light.tertiary, brandAmber);
  });

  test('a página e o manifesto usam as cores do tema', () {
    final html = _read('web/index.html');
    final manifest =
        jsonDecode(_read('web/manifest.json')) as Map<String, dynamic>;

    for (final (scheme, colors) in [('light', light), ('dark', dark)]) {
      expect(
        html,
        contains(
          'media="(prefers-color-scheme: $scheme)" '
          'content="${_hex(colors.surface)}"',
        ),
      );
    }
    expect(manifest['theme_color'], _hex(brandBlue));
    expect(manifest['background_color'], _hex(light.surface));
  });

  test('a logo e o gráfico não redefinem as cores da marca', () {
    for (final path in [
      'lib/widgets/app_logo.dart',
      'lib/widgets/hours_chart.dart',
    ]) {
      final source = _read(path).toUpperCase();
      for (final color in [brandBlue, brandAmber]) {
        expect(source, isNot(contains(_hex(color).substring(1))), reason: path);
      }
    }
  });

  test('o gerador de ícones usa as cores da marca', () {
    final script = _read('tool/gerar_icones.py');

    for (final (name, color) in [('BLUE', brandBlue), ('AMBER', brandAmber)]) {
      final argb = color.toARGB32();
      expect(
        _numbers(
          script.replaceAllMapped(
            RegExp(r'0x([0-9A-Fa-f]{2})'),
            (m) => '${int.parse(m.group(1)!, radix: 16)}',
          ),
          // O nome da cor seguido da tupla, entre parênteses.
          '$name = ${r'\(([^)]*)\)'}',
        ),
        [(argb >> 16) & 255, (argb >> 8) & 255, argb & 255, 255],
        reason: name,
      );
    }
  });

  test('o gerador de ícones desenha a mesma logo do aplicativo', () {
    final app = _read('lib/widgets/app_logo.dart');
    final script = _read('tool/gerar_icones.py');

    expect(
      _numbers(script, r'LEFT, TOP, RIGHT, BOTTOM = (.*)'),
      _numbers(app, r'ticket = Rect\.fromLTRB\(([^)]*)\)'),
    );
    expect(_numbers(script, r'RADIUS, TEAR, NOTCH = (.*)'), [
      ..._numbers(app, r'ticket, const Radius\.circular\(([^)]*)\)'),
      ..._numbers(app, r'const tear = (.*);'),
      ..._numbers(app, r'const notch = (.*);'),
    ]);
    expect(_numbers(script, r'CHECK = \[(.*)\]'), [
      ..._numbers(app, r'\.\.moveTo\(([^)]*)\)'),
      for (final line in RegExp(r'\.\.lineTo\(([^)]*)\)').allMatches(app))
        ..._numbers(line.group(0)!, r'\(([^)]*)\)'),
    ]);
    expect(
      _numbers(script, r'CHECK_WIDTH = (.*)'),
      _numbers(app, r'strokeWidth = (.*)'),
    );
  });
}
