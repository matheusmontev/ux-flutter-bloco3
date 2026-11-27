import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/widgets/qr_box.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<AppState> _open(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final state = await newAppState();
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  final menu = size.width >= 840 ? NavigationRail : NavigationBar;
  await tester.tap(
    find.descendant(of: find.byType(menu), matching: find.text('Networking')),
  );
  await tester.pumpAndSettle();
  return state;
}

void main() {
  final contacts = find.text('Meus contatos');

  testWidgets('no PC o cartão fica ao lado dos contatos', (tester) async {
    await _open(tester, const Size(1366, 768));

    expect(
      tester.getTopLeft(contacts).dx,
      greaterThan(tester.getTopRight(find.byType(QrBox)).dx),
    );
    // A lista de contatos aparece sem rolar a tela.
    expect(tester.getTopLeft(contacts).dy, lessThan(300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no PC adicionar contato atualiza a coluna ao lado', (
    tester,
  ) async {
    final state = await _open(tester, const Size(1366, 768));

    await tester.tap(find.text('Adicionar contato de exemplo'));
    await tester.pumpAndSettle();

    expect(state.contacts, hasLength(1));
    expect(find.text('Marina Cordeiro'), findsOneWidget);
    expect(find.text('Contato adicionado'), findsOneWidget);
  });

  testWidgets('no celular os contatos vêm abaixo do cartão', (tester) async {
    await _open(tester, const Size(390, 844));
    await tester.scrollUntilVisible(
      contacts,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(tester.getTopLeft(contacts).dx, lessThan(60));
    expect(tester.takeException(), isNull);
  });
}
