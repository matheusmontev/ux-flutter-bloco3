/// O evento é uma fonte só: ele garante a ordem das atividades, e as telas e
/// regras recebem os dados dele.
library;

import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/certificate.dart';
import 'package:eventos_academicos/core/formatters.dart';
import 'package:eventos_academicos/models/activity.dart';
import 'package:eventos_academicos/models/event.dart';
import 'package:eventos_academicos/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Activity _activity(String id, DateTime start, {String theme = 'UX'}) =>
    Activity(
      id: id,
      title: 'Atividade $id',
      speaker: 'Pessoa',
      room: 'Sala 1',
      theme: theme,
      type: 'Palestra',
      start: start,
      end: start.add(const Duration(hours: 1)),
      description: 'Descrição.',
    );

/// De propósito fora de ordem e atravessando a virada do mês.
Event _event() => Event(
  name: 'Jornada de Teste',
  place: 'Sala de teste',
  activities: [
    _activity('b02', DateTime(2027, 4, 2, 9), theme: 'Mobile'),
    _activity('b01', DateTime(2027, 3, 31, 14)),
    _activity('b03', DateTime(2027, 4, 2, 15)),
  ],
);

void main() {
  test('as atividades ficam em ordem de horário', () {
    expect([for (final a in _event().activities) a.id], ['b01', 'b02', 'b03']);
    expect(() => _event().activities.clear(), throwsUnsupportedError);
  });

  test('o evento informa dias, temas, período e busca por id', () {
    final event = _event();

    expect(event.days, [DateTime(2027, 3, 31), DateTime(2027, 4, 2)]);
    expect(event.themes, ['Mobile', 'UX']);
    expect(event.firstDay, DateTime(2027, 3, 31));
    expect(event.lastDay, DateTime(2027, 4, 2));
    expect(event.findActivity('b02')?.title, 'Atividade b02');
    expect(event.findActivity('x'), isNull);
  });

  test('o período por extenso cobre um ou dois meses', () {
    expect(
      formatPeriodLong(DateTime(2026, 12, 9), DateTime(2026, 12, 11)),
      '9 a 11 de dezembro',
    );
    expect(
      formatPeriodLong(DateTime(2027, 3, 31), DateTime(2027, 4, 2)),
      '31 de março a 2 de abril',
    );
  });

  test('o certificado usa o nome do evento recebido', () {
    const ana = UserProfile(name: 'Ana', email: 'ana@exemplo.com');

    expect(
      certificateText(ana, _event().activities.first, _event()),
      contains('no evento Jornada de Teste,'),
    );
  });

  testWidgets('as telas mostram o evento que o app recebe', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1600);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final state = AppState(
      await SharedPreferences.getInstance(),
      event: _event(),
    );
    await tester.pumpWidget(EventosApp(state: state));
    await tester.pumpAndSettle();

    expect(find.text('Jornada de Teste'), findsOneWidget);
    expect(find.text('31 de março a 2 de abril'), findsOneWidget);

    await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
    await tester.pumpAndSettle();

    expect(find.text('31/03/2027 a 02/04/2027, Sala de teste'), findsOneWidget);
    expect(find.text('Atividade b01'), findsOneWidget);
  });
}
