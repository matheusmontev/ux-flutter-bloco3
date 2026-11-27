import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/codes.dart';
import 'package:eventos_academicos/core/theme.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/features/networking/networking_page.dart';
import 'package:eventos_academicos/widgets/badge_card.dart';
import 'package:eventos_academicos/widgets/qr_box.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

Future<AppState> _pump(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
  bool withContact = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final state = await newAppState();
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  if (withContact) await state.addContact(cardCode(sampleContact));
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        home: const Scaffold(body: NetworkingPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Finder _inBadge(Finder finder) =>
    find.descendant(of: find.byType(BadgeCard), matching: finder);

void main() {
  testWidgets('o cartão virtual é um crachá com nome e QR Code', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(BadgeCard), findsOneWidget);
    expect(_inBadge(find.text('Ana Lima')), findsOneWidget);
    expect(_inBadge(find.byType(QrBox)), findsOneWidget);
  });

  testWidgets('o crachá com o QR Code cabe na tela do celular', (tester) async {
    await _pump(tester);

    // Sobra espaço para a barra do topo e a navegação.
    expect(tester.getBottomLeft(find.byType(QrBox)).dy, lessThan(600));
  });

  testWidgets('ler um cartão é a ação em destaque', (tester) async {
    await _pump(tester);
    final button = find.byKey(const Key('ler-cartao'));
    await tester.scrollUntilVisible(
      button,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final style = tester.widget<FilledButton>(button).style;

    expect(
      style?.backgroundColor?.resolve({}),
      buildTheme(Brightness.light).colorScheme.tertiary,
    );
  });

  testWidgets('cada contato é uma linha, com remoção', (tester) async {
    await _pump(tester, withContact: true);
    final row = find.byKey(ValueKey('contato-${sampleContact.email}'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.descendant(of: row, matching: find.text(sampleContact.email)),
      findsOneWidget,
    );
    expect(find.descendant(of: row, matching: find.byType(Card)), findsNothing);
    expect(find.byTooltip('Remover ${sampleContact.name}'), findsOneWidget);
  });

  testWidgets('cabe em 320 px com fonte em 200%', (tester) async {
    await _pump(
      tester,
      size: const Size(320, 640),
      scale: 2,
      withContact: true,
    );

    expect(tester.takeException(), isNull);
  });
}
