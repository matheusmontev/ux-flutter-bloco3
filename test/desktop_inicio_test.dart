import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final state = await newAppState();
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
}

Offset _at(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text));

void main() {
  testWidgets('no PC o resumo e as próximas atividades ficam lado a lado', (
    tester,
  ) async {
    await _pump(tester, const Size(1366, 768));

    final lista = _at(tester, 'Próximas atividades').dx;

    // "Contatos" é o último item do resumo, na coluna da esquerda.
    expect(lista, greaterThan(_at(tester, 'Contatos').dx));
    expect(lista, greaterThan(_at(tester, 'Olá, Ana').dx + 300));
    expect(find.text(eventName), findsOneWidget);
    expect(
      _at(tester, 'Próximas atividades').dy,
      closeTo(_at(tester, 'Olá, Ana').dy, 8),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('no celular as próximas atividades vêm abaixo do resumo', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));

    expect(
      _at(tester, 'Próximas atividades').dy,
      greaterThan(_at(tester, 'Contatos').dy),
    );
    expect(_at(tester, 'Próximas atividades').dx, _at(tester, 'Olá, Ana').dx);
  });
}
