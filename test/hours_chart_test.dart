import 'package:eventos_academicos/core/theme.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/widgets/hours_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// a01: UX, 1h30. a02: Mobile, 3h. a05: Dados, 2h. a06: UX, 1h30.
List<T> _pick<T>(List<T> all, List<int> indexes) => [
  for (final i in indexes) all[i],
];

Future<void> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  double width = 360,
  List<int> indexes = const [0, 1, 4],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 640);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(brightness),
      home: Scaffold(body: HoursChart(activities: _pick(activities, indexes))),
    ),
  );
}

Finder _bar(String theme) => find.byKey(ValueKey('bar-$theme'));

void main() {
  test('soma as horas por tema, da maior para a menor', () {
    final totals = hoursByTheme(_pick(activities, [0, 1, 4, 5]));

    // UX soma 3h e empata com Mobile: o empate segue a ordem alfabética.
    expect(totals.map((e) => (e.theme, e.total.inMinutes)), [
      ('Mobile', 180),
      ('UX', 180),
      ('Dados', 120),
    ]);
  });

  testWidgets('o comprimento da barra é proporcional às horas', (tester) async {
    await _pump(tester);
    double width(String theme) => tester.getSize(_bar(theme)).width;

    expect(width('Dados') / width('Mobile'), closeTo(120 / 180, 0.01));
    expect(width('UX') / width('Mobile'), closeTo(90 / 180, 0.01));
  });

  testWidgets('as barras partem da mesma base e são finas', (tester) async {
    await _pump(tester);
    final left = tester.getTopLeft(_bar('Mobile')).dx;

    for (final theme in ['Dados', 'UX']) {
      expect(tester.getTopLeft(_bar(theme)).dx, left);
    }
    expect(tester.getSize(_bar('Mobile')).height, lessThanOrEqualTo(12));
  });

  testWidgets('não usa indicador de progresso nem trilho', (tester) async {
    await _pump(tester);

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('mostra o valor ao lado de cada tema', (tester) async {
    await _pump(tester);

    for (final text in ['Mobile', '3h', 'Dados', '2h', 'UX', '1h30']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.byTooltip('Mobile: 3h'), findsOneWidget);
  });

  for (final (brightness, color) in const [
    (Brightness.light, Color(0xFF006FA8)),
    (Brightness.dark, Color(0xFF0099B0)),
  ]) {
    testWidgets('usa uma só cor validada no tema ${brightness.name}', (
      tester,
    ) async {
      await _pump(tester, brightness: brightness);

      for (final theme in ['Mobile', 'Dados', 'UX']) {
        final box = tester.widget<DecoratedBox>(_bar(theme));
        final decoration = box.decoration as BoxDecoration;

        expect(decoration.color, color);
        // Só a ponta dos dados é arredondada; a base é reta.
        expect(
          decoration.borderRadius,
          const BorderRadius.horizontal(right: Radius.circular(4)),
        );
      }
    });
  }

  testWidgets('um único tema ocupa a largura toda sem estourar', (
    tester,
  ) async {
    await _pump(tester, width: 320, indexes: [0]);

    expect(_bar('UX'), findsOneWidget);
    expect(tester.getSize(_bar('UX')).width, greaterThan(200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem presenças não desenha barras', (tester) async {
    await _pump(tester, indexes: []);

    expect(find.byType(DecoratedBox), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
