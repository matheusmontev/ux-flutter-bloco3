/// As abas são identificadas por nome, então reordenar o menu não muda para
/// onde cada atalho leva.
library;

import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/features/home/home_page.dart';
import 'package:eventos_academicos/features/shell/app_tab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

void main() {
  testWidgets('os atalhos do início pedem a aba pelo nome', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1600);
    addTearDown(tester.view.reset);
    final state = await newAppState();
    await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
    final opened = <AppTab>[];
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(
          home: Scaffold(body: HomePage(onOpenTab: opened.add)),
        ),
      ),
    );

    for (final label in [
      'Presenças',
      'Carga horária',
      'Contatos',
      'Ver programação completa',
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
    }

    expect(opened, [
      AppTab.history,
      AppTab.history,
      AppTab.networking,
      AppTab.schedule,
    ]);
  });

  test('só a Programação mostra o botão de check-in', () {
    expect(AppTab.values.where((tab) => tab.showsCheckInButton), [
      AppTab.schedule,
    ]);
  });
}
