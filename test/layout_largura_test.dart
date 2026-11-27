/// A Programação decide o layout pela largura que as colunas recebem,
/// já sem o menu lateral.
library;

import 'package:eventos_academicos/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<void> _openSchedule(WidgetTester tester, double width) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 800);
  addTearDown(tester.view.reset);
  final state = await newAppState();
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Programação'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in const [900.0, 940.0, 1000.0, 1100.0, 1200.0, 1366.0]) {
    testWidgets('em ${width.toInt()}px os filtros combinam com as colunas', (
      tester,
    ) async {
      await _openSchedule(tester, width);

      final twoColumns = find
          .byKey(const Key('two-pane'))
          .evaluate()
          .isNotEmpty;
      final filtersButton = find.text('Filtros');

      // Uma coluna: filtros recolhidos. Duas colunas: todos visíveis.
      expect(filtersButton, twoColumns ? findsNothing : findsOneWidget);
      expect(
        find.widgetWithText(FilterChip, 'Manhã'),
        twoColumns ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
