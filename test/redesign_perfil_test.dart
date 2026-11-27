import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/theme.dart';
import 'package:eventos_academicos/features/settings/edit_profile_page.dart';
import 'package:eventos_academicos/features/settings/settings_page.dart';
import 'package:eventos_academicos/widgets/badge_card.dart';
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

final _preview = find.byKey(const Key('preview'));

Finder _inPreview(String text) =>
    find.descendant(of: _preview, matching: find.text(text));

void main() {
  testWidgets('o perfil usa o mesmo crachá do cartão virtual', (tester) async {
    await _pump(tester, const SettingsPage());

    expect(find.byType(BadgeCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BadgeCard),
        matching: find.text('Editar perfil'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('sair da conta fica na seção "Conta"', (tester) async {
    await _pump(tester, const SettingsPage());
    await tester.scrollUntilVisible(
      find.text('Sair da conta'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Conta'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Conta')).dy,
      lessThan(tester.getTopLeft(find.text('Sair da conta')).dy),
    );
  });

  testWidgets('a edição mostra o crachá mudando enquanto se digita', (
    tester,
  ) async {
    final state = await _pump(tester, const EditProfilePage());

    expect(_inPreview('AL'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('profile-name')),
      'Bruno Costa',
    );
    await tester.pump();

    expect(_inPreview('BC'), findsOneWidget);
    expect(_inPreview('Bruno Costa'), findsOneWidget);
    // A prévia não grava nada.
    expect(state.profile?.name, 'Ana Lima');
  });

  testWidgets('com o nome apagado, a prévia continua legível', (tester) async {
    await _pump(tester, const EditProfilePage());
    await tester.enterText(find.byKey(const Key('profile-name')), '');
    await tester.pump();

    expect(_inPreview('?'), findsOneWidget);
    expect(_inPreview('Seu nome'), findsOneWidget);
  });

  for (final page in const [SettingsPage(), EditProfilePage()]) {
    testWidgets('${page.runtimeType} cabe em 320 px com fonte em 200%', (
      tester,
    ) async {
      await _pump(tester, page, size: const Size(320, 640), scale: 2);

      expect(tester.takeException(), isNull);
    });
  }
}
