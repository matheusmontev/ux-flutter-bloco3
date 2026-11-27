import 'package:eventos_academicos/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<void> _open(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final state = await newAppState();
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  final menu = size.width >= 840 ? NavigationRail : NavigationBar;
  await tester.tap(
    find.descendant(of: find.byType(menu), matching: find.text('Programação')),
  );
  await tester.pumpAndSettle();
}

Finder _chip(String label) => find.widgetWithText(FilterChip, label);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no celular a primeira atividade aparece logo no alto', (
    tester,
  ) async {
    await _open(tester);

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('agenda-a01'))).dy,
      lessThan(340),
    );
  });

  testWidgets('turno e tema ficam em "Filtros" até serem pedidos', (
    tester,
  ) async {
    await _open(tester);

    expect(_chip('Qua 09/12'), findsOneWidget);
    expect(_chip('Manhã'), findsNothing);
    expect(_chip('UX'), findsNothing);

    await _tap(tester, find.text('Filtros'));

    expect(_chip('Manhã'), findsOneWidget);
    expect(_chip('UX'), findsOneWidget);
  });

  testWidgets('fechado, o botão informa quantos filtros estão ativos', (
    tester,
  ) async {
    await _open(tester);
    await _tap(tester, find.text('Filtros'));
    await _tap(tester, _chip('Tarde'));
    await _tap(tester, _chip('UX'));
    await _tap(tester, find.text('Filtros (2)'));

    expect(_chip('Tarde'), findsNothing);
    expect(find.text('Filtros (2)'), findsOneWidget);
    expect(find.text('1 atividade'), findsOneWidget);

    await _tap(tester, find.text('Limpar filtros'));

    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('10 atividades'), findsOneWidget);
  });

  testWidgets('no computador todos os filtros ficam visíveis', (tester) async {
    await _open(tester, size: const Size(1366, 768));

    expect(_chip('Manhã'), findsOneWidget);
    expect(_chip('UX'), findsOneWidget);
    expect(find.text('Filtros'), findsNothing);
  });

  testWidgets('cabe em 320 px com fonte em 200%, com filtros abertos', (
    tester,
  ) async {
    await _open(tester, size: const Size(320, 640), scale: 2);
    await _tap(tester, find.text('Filtros'));

    expect(tester.takeException(), isNull);
  });
}
