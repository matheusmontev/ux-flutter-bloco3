import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await SharedPreferences.getInstance());
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no celular o evento abre a tela, com datas e local', (
    tester,
  ) async {
    await _pump(tester);
    final band = find.byKey(const Key('auth-event'));

    expect(tester.getTopLeft(band), Offset.zero);
    expect(tester.getSize(band).width, 390);
    for (final text in [eventName, '9 a 11 de dezembro', eventPlace]) {
      expect(
        find.descendant(of: band, matching: find.text(text)),
        findsOneWidget,
        reason: text,
      );
    }
  });

  testWidgets('o botão de entrar continua visível sem rolar', (tester) async {
    await _pump(tester);

    expect(
      tester.getBottomLeft(find.widgetWithText(FilledButton, 'Entrar')).dy,
      lessThan(844),
    );
  });

  testWidgets('no computador o painel lista os três dias do evento', (
    tester,
  ) async {
    await _pump(tester, size: const Size(1366, 768));
    final panel = find.byKey(const Key('auth-brand'));

    for (final day in [
      'Quarta-feira, 9 de dezembro',
      'Quinta-feira, 10 de dezembro',
      'Sexta-feira, 11 de dezembro',
    ]) {
      expect(
        find.descendant(of: panel, matching: find.text(day)),
        findsOneWidget,
        reason: day,
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(320, 640), Size(1366, 768)]) {
    testWidgets('cabe em ${size.width.toInt()} px com fonte em 200%', (
      tester,
    ) async {
      await _pump(tester, size: size, scale: 2);

      expect(tester.takeException(), isNull);
    });
  }
}
