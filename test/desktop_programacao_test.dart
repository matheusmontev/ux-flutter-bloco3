import 'package:eventos_academicos/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

const _day = 'Quarta-feira, 9 de dezembro';

Future<void> _open(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
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

Offset _at(WidgetTester tester, Finder finder) => tester.getTopLeft(finder);

void main() {
  final search = find.byKey(const Key('search'));
  final first = find.byKey(const ValueKey('agenda-a01'));

  testWidgets('no PC os filtros ficam ao lado da agenda', (tester) async {
    await _open(tester, const Size(1366, 768));

    expect(
      _at(tester, find.text(_day)).dx,
      greaterThan(tester.getTopRight(search).dx),
    );
    // A primeira atividade aparece sem precisar rolar.
    expect(_at(tester, first).dy, lessThan(250));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no PC rolar a agenda mantém os filtros no lugar', (
    tester,
  ) async {
    await _open(tester, const Size(1366, 600));
    final before = _at(tester, search);

    await tester.drag(first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(_at(tester, search), before);
  });

  testWidgets('no PC o filtro atualiza a agenda ao lado', (tester) async {
    await _open(tester, const Size(1366, 768));

    await tester.tap(find.widgetWithText(FilterChip, 'Qui 10/12'));
    await tester.pumpAndSettle();

    expect(find.text(_day), findsNothing);
    expect(find.text('Quinta-feira, 10 de dezembro'), findsOneWidget);
    expect(find.text('4 atividades'), findsOneWidget);
  });

  testWidgets('no celular a agenda vem abaixo dos filtros', (tester) async {
    await _open(tester, const Size(390, 844));

    expect(
      _at(tester, find.text(_day)).dy,
      greaterThan(_at(tester, search).dy),
    );
    expect(_at(tester, find.text(_day)).dx, _at(tester, search).dx);
  });
}
