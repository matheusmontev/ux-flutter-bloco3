/// Convenções que as telas não precisam mais repetir.
library;

import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/features/checkin/scanner_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

void main() {
  testWidgets('encerrar a sessão fecha as telas abertas', (tester) async {
    final state = await newAppState();
    await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
    await tester.pumpWidget(EventosApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();

    // Quem encerra a sessão não precisa fechar as telas antes.
    await state.signOut();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    expect(find.text('Sair da conta'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('entrar de novo abre o início', (tester) async {
    final state = await newAppState();
    await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
    await tester.pumpWidget(EventosApp(state: state));
    await tester.pumpAndSettle();
    await state.signOut();
    await tester.pumpAndSettle();

    await state.signIn(email: 'ana@exemplo.com');
    await tester.pumpAndSettle();

    expect(find.text('Olá, Ana'), findsOneWidget);
  });

  testWidgets('abrir o leitor devolve o texto lido', (tester) async {
    String? read;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => read = await ScannerPage.read(context),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    tester.state<NavigatorState>(find.byType(Navigator)).pop('EVENTO:a01');
    await tester.pumpAndSettle();

    expect(read, 'EVENTO:a01');
  });

  test('uma tela com sessão sem perfil falha com uma mensagem clara', () async {
    final state = await newAppState();

    expect(() => state.sessionProfile, throwsStateError);
  });
}
