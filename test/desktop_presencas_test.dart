import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/widgets/hours_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<void> _open(
  WidgetTester tester,
  Size size, {
  List<String> attended = const ['a01', 'a02'],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final state = await newAppState();
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  for (final id in attended) {
    await state.checkIn('EVENTO:$id');
  }
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  final menu = size.width >= 840 ? NavigationRail : NavigationBar;
  await tester.tap(
    find.descendant(of: find.byType(menu), matching: find.text('Presenças')),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no PC o gráfico e os certificados ficam lado a lado', (
    tester,
  ) async {
    await _open(tester, const Size(1366, 768));
    final chart = find.byType(HoursChart);
    final list = find.text('Certificados');

    expect(
      tester.getTopLeft(list).dx,
      greaterThan(tester.getTopRight(chart).dx),
    );
    expect(tester.getTopLeft(list).dy, lessThan(tester.getTopLeft(chart).dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no celular os certificados vêm abaixo do gráfico', (
    tester,
  ) async {
    await _open(tester, const Size(390, 844));

    expect(
      tester.getTopLeft(find.text('Certificados')).dy,
      greaterThan(tester.getBottomLeft(find.byType(HoursChart)).dy),
    );
  });

  testWidgets('no PC sem presenças mostra um único aviso central', (
    tester,
  ) async {
    await _open(tester, const Size(1366, 768), attended: const []);

    expect(find.text('Nenhuma presença ainda'), findsOneWidget);
    expect(find.byType(HoursChart), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
