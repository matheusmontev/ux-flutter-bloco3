import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/features/settings/profile_summary.dart';
import 'package:eventos_academicos/features/settings/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final state = await newAppState();
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: const MaterialApp(home: SettingsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final profile = find.byType(ProfileSummary);
  final dark = find.text('Tema escuro');

  testWidgets('no PC o perfil fica ao lado das preferências', (tester) async {
    await _pump(tester, const Size(1366, 768));

    expect(
      tester.getTopLeft(dark).dx,
      greaterThan(tester.getTopRight(profile).dx),
    );
    expect(tester.getTopLeft(dark).dy, lessThan(150));
    expect(find.text('Sair da conta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no celular as preferências vêm abaixo do perfil', (
    tester,
  ) async {
    await _pump(tester, const Size(390, 844));

    expect(
      tester.getTopLeft(dark).dy,
      greaterThan(tester.getBottomLeft(profile).dy),
    );
  });
}
