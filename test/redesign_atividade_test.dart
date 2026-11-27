import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/theme.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/features/checkin/check_in_page.dart';
import 'package:eventos_academicos/features/checkin/demo_codes_page.dart';
import 'package:eventos_academicos/features/schedule/activity_detail_page.dart';
import 'package:eventos_academicos/widgets/ticket_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<AppState> _pump(
  WidgetTester tester,
  Widget page, {
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
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(theme: buildTheme(Brightness.light), home: page),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Finder _inTicket(Finder finder) =>
    find.descendant(of: find.byType(TicketCard), matching: finder);

final _activity = activities.first;
final _frame = find.byKey(const Key('scan-frame'));
final _demo = find.byKey(const Key('demo-panel'));

void main() {
  group('Detalhes da atividade', () {
    testWidgets('é um ingresso com horário, sala e check-in', (tester) async {
      await _pump(tester, ActivityDetailPage(activity: _activity));

      for (final text in ['08:30', 'Auditório A', 'Fazer check-in']) {
        expect(_inTicket(find.text(text)), findsOneWidget, reason: text);
      }
      expect(find.textContaining('·'), findsNothing);
      expect(find.text(_activity.description), findsOneWidget);
    });

    testWidgets('com presença, o canhoto mostra a confirmação', (tester) async {
      final state = await _pump(
        tester,
        ActivityDetailPage(activity: _activity),
      );
      await state.checkIn('EVENTO:a01');
      await tester.pumpAndSettle();

      expect(_inTicket(find.text('Presença registrada')), findsOneWidget);
      expect(find.text('Fazer check-in'), findsNothing);
    });
  });

  group('Check-in', () {
    testWidgets('a câmera é a ação principal, em uma moldura', (tester) async {
      await _pump(tester, CheckInPage(activity: _activity));

      expect(_frame, findsOneWidget);
      expect(
        find.descendant(of: _frame, matching: find.text('Ler com a câmera')),
        findsOneWidget,
      );
    });

    testWidgets('a demonstração fica separada, abaixo do código', (
      tester,
    ) async {
      await _pump(tester, CheckInPage(activity: _activity));
      await tester.ensureVisible(_demo);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: _demo,
          matching: find.text('Simular leitura do QR Code'),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(_demo).dy,
        greaterThan(tester.getTopLeft(find.text('Confirmar código')).dy),
      );
    });
  });

  testWidgets('cada código de demonstração mostra dia e horário', (
    tester,
  ) async {
    await _pump(tester, const DemoCodesPage());

    expect(find.text('Qua 09/12, 08:30, EVENTO:a01'), findsOneWidget);
    expect(find.textContaining('·'), findsNothing);
  });

  for (final (name, page) in [
    ('detalhes', ActivityDetailPage(activity: activities[3])),
    ('check-in', CheckInPage(activity: activities[3])),
  ]) {
    testWidgets('$name cabe em 320 px com fonte em 200%', (tester) async {
      await _pump(tester, page, size: const Size(320, 640), scale: 2);

      expect(tester.takeException(), isNull);
    });
  }
}
