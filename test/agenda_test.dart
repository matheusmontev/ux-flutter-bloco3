import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/schedule_filter.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/widgets/agenda_item.dart';
import 'package:eventos_academicos/widgets/page_body.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _openSchedule(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  SharedPreferences.setMockInitialValues({});
  final state = AppState(await SharedPreferences.getInstance());
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Programação'),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Finder _item(String id) => find.byKey(ValueKey('agenda-$id'));

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    // A lista da página é o primeiro Scrollable; o outro é o campo de busca.
    scrollable: find
        .descendant(
          of: find.byType(PageBody),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Agrupamento por dia', () {
    test('separa os dias em ordem e mantém a ordem de horário', () {
      final groups = groupByDay(activities.reversed);

      expect(groups.keys, [
        DateTime(2026, 12, 9),
        DateTime(2026, 12, 10),
        DateTime(2026, 12, 11),
      ]);
      expect(groups.values.first.map((a) => a.id), ['a01', 'a02', 'a03']);
    });

    test('lista vazia não cria dias', () {
      expect(groupByDay(const []), isEmpty);
    });
  });

  group('Agenda', () {
    testWidgets('mostra o cabeçalho do dia antes das atividades', (
      tester,
    ) async {
      await _openSchedule(tester);
      final header = find.text('Quarta-feira, 9 de dezembro');
      await _reveal(tester, header);

      expect(header, findsOneWidget);
      expect(
        tester.getTopLeft(header).dy,
        lessThan(tester.getTopLeft(_item('a01')).dy),
      );
    });

    testWidgets('o horário fica à esquerda do título', (tester) async {
      await _openSchedule(tester);
      await _reveal(tester, _item('a01'));
      Finder inside(String text) =>
          find.descendant(of: _item('a01'), matching: find.text(text));

      expect(inside('08:30'), findsOneWidget);
      expect(inside('10:00'), findsOneWidget);
      expect(inside('Auditório A'), findsOneWidget);
      expect(
        tester.getTopRight(inside('08:30')).dx,
        lessThan(
          tester.getTopLeft(inside('Abertura: tecnologia e pessoas')).dx,
        ),
      );
    });

    testWidgets('filtrar por dia deixa só o cabeçalho dele', (tester) async {
      await _openSchedule(tester);
      await tester.tap(find.widgetWithText(FilterChip, 'Qui 10/12'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('Quinta-feira, 10 de dezembro'));

      expect(find.text('Quarta-feira, 9 de dezembro'), findsNothing);
    });

    testWidgets('marca a atividade com presença', (tester) async {
      final state = await _openSchedule(tester);
      await state.checkIn('EVENTO:a01');
      await tester.pumpAndSettle();
      await _reveal(tester, _item('a01'));

      expect(
        find.descendant(
          of: _item('a01'),
          matching: find.text('Presença registrada'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tocar no item abre os detalhes', (tester) async {
      await _openSchedule(tester);
      await _reveal(tester, _item('a01'));
      await tester.ensureVisible(_item('a01'));
      await tester.pumpAndSettle();
      await tester.tap(_item('a01'));
      await tester.pumpAndSettle();

      expect(find.text('Fazer check-in'), findsOneWidget);
    });

    testWidgets('cabe em 320 px com a fonte em 200%', (tester) async {
      await _openSchedule(tester, size: const Size(320, 700), textScale: 2);
      await _reveal(tester, _item('a02'));

      expect(find.byType(AgendaItem), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
