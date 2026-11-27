import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/widgets/ticket_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _pump(
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
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  return state;
}

Finder _inTicket(Finder finder) =>
    find.descendant(of: find.byType(TicketCard), matching: finder);

void main() {
  testWidgets('a próxima atividade é um ingresso com hora e sala', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(TicketCard), findsOneWidget);
    for (final text in ['08:30', 'Auditório A', 'Fazer check-in']) {
      expect(_inTicket(find.text(text)), findsOneWidget, reason: text);
    }
    expect(_inTicket(find.text(activities.first.title)), findsOneWidget);
    // Cabe sem rolar no celular.
    expect(
      tester.getBottomLeft(find.byType(TicketCard)).dy,
      lessThan(844 - 80),
    );
  });

  testWidgets('o botão do ingresso abre o check-in da atividade', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(_inTicket(find.text('Fazer check-in')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Check-in'), findsOneWidget);
    expect(find.text(activities.first.title), findsOneWidget);
  });

  testWidgets('a lista não repete a atividade do ingresso', (tester) async {
    await _pump(tester);

    expect(find.text(activities.first.title), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('proxima-a02')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('proxima-a02')), findsOneWidget);
    expect(find.byKey(const ValueKey('proxima-a01')), findsNothing);
  });

  testWidgets('o ingresso avança depois do check-in', (tester) async {
    final state = await _pump(tester);
    await state.checkIn('EVENTO:a01');
    await tester.pumpAndSettle();

    expect(_inTicket(find.text(activities[1].title)), findsOneWidget);
  });

  testWidgets('não há botão flutuante repetindo o check-in no início', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('sem atividades pendentes, mostra a conclusão', (tester) async {
    final state = await _pump(tester);
    for (final a in activities) {
      await state.checkIn('EVENTO:${a.id}');
    }
    await tester.pumpAndSettle();

    expect(find.byType(TicketCard), findsNothing);
    expect(find.text('Tudo concluído'), findsOneWidget);
  });

  testWidgets('cabe em 320 px com fonte em 200%', (tester) async {
    await _pump(tester, size: const Size(320, 640), scale: 2);

    expect(tester.takeException(), isNull);
  });
}
