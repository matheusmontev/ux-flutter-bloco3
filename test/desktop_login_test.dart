import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

final _brand = find.byKey(const Key('auth-brand'));
final _email = find.byKey(const Key('email'));

Future<AppState> _pump(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final state = await newAppState();
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  return state;
}

void main() {
  testWidgets('no PC mostra o painel do evento ao lado do formulário', (
    tester,
  ) async {
    await _pump(tester, const Size(1366, 768));

    expect(_brand, findsOneWidget);
    expect(tester.getTopLeft(_brand), Offset.zero);
    expect(tester.getSize(_brand).height, 768);
    expect(
      tester.getTopLeft(_email).dx,
      greaterThan(tester.getTopRight(_brand).dx),
    );
    expect(tester.getSize(_email).width, lessThanOrEqualTo(420));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no PC o cadastro funciona', (tester) async {
    final state = await _pump(tester, const Size(1366, 768));

    await tester.tap(find.text('Criar uma conta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name')), 'Bia Souza');
    await tester.enterText(_email, 'bia@exemplo.com');
    await tester.enterText(find.byKey(const Key('password')), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(state.isLogged, isTrue);
  });

  testWidgets('em janela baixa o formulário rola sem estourar', (tester) async {
    await _pump(tester, const Size(1000, 360));

    expect(_brand, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no celular não há painel lateral', (tester) async {
    await _pump(tester, const Size(390, 844));

    expect(_brand, findsNothing);
    expect(_email, findsOneWidget);
  });
}
