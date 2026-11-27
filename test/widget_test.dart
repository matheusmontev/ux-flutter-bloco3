import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  bool logged = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final state = AppState(await SharedPreferences.getInstance());
  if (logged) {
    await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  }
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
  return state;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _tab(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  testWidgets('login vazio mostra os erros', (tester) async {
    await _pumpApp(tester, logged: false);

    await _tap(tester, find.widgetWithText(FilledButton, 'Entrar'));

    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    expect(find.text('Use pelo menos 6 caracteres'), findsOneWidget);
  });

  testWidgets('cadastro leva à tela inicial', (tester) async {
    await _pumpApp(tester, logged: false);

    await _tap(tester, find.text('Criar uma conta'));
    await tester.enterText(find.byKey(const Key('name')), 'Bia Souza');
    await tester.enterText(find.byKey(const Key('email')), 'bia@exemplo.com');
    await tester.enterText(find.byKey(const Key('password')), '123456');
    await _tap(tester, find.widgetWithText(FilledButton, 'Criar conta'));

    expect(find.text('Olá, Bia'), findsOneWidget);
  });

  testWidgets('busca sem resultado mostra estado vazio e limpa', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _tap(tester, _tab('Programação'));
    await tester.enterText(find.byKey(const Key('search')), 'inexistente');
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma atividade encontrada'), findsOneWidget);

    await _tap(tester, find.text('Ver todas'));

    expect(find.text('10 atividades'), findsOneWidget);
  });

  testWidgets('fluxo: check-in, histórico e certificado', (tester) async {
    final state = await _pumpApp(tester);

    await _tap(tester, find.text('Abertura: tecnologia e pessoas'));
    await _tap(tester, find.text('Fazer check-in'));
    await _tap(tester, find.text('Simular leitura do QR Code'));

    expect(find.text('Presença registrada'), findsOneWidget);
    expect(state.hasAttended('a01'), isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await _tap(tester, _tab('Presenças'));
    await _tap(tester, find.text('Abertura: tecnologia e pessoas'));

    expect(find.text('CERTIFICADO DE PARTICIPAÇÃO'), findsOneWidget);
    expect(find.textContaining('Ana Lima'), findsOneWidget);
  });

  testWidgets('código digitado inválido mostra aviso', (tester) async {
    await _pumpApp(tester);

    await _tap(tester, find.byType(FloatingActionButton));
    await tester.enterText(find.byKey(const Key('checkin-code')), 'errado');
    await _tap(tester, find.text('Confirmar código'));

    expect(find.text('Código inválido'), findsOneWidget);
  });

  testWidgets('sair da conta volta ao login', (tester) async {
    await _pumpApp(tester);

    await _tap(tester, find.byTooltip('Configurações'));
    await tester.scrollUntilVisible(
      find.text('Sair da conta'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await _tap(tester, find.text('Sair da conta'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Sair'));

    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('tela larga usa navegação lateral', (tester) async {
    await _pumpApp(tester, size: const Size(1280, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  for (final size in const [Size(320, 568), Size(390, 844), Size(1280, 800)]) {
    testWidgets('abas sem estouro de layout em ${size.width.toInt()}px', (
      tester,
    ) async {
      final state = await _pumpApp(tester, size: size);
      await state.checkIn('EVENTO:a01');
      await tester.pumpAndSettle();

      for (final label in [
        'Programação',
        'Presenças',
        'Networking',
        'Início',
      ]) {
        final finder = size.width >= 840
            ? find.descendant(
                of: find.byType(NavigationRail),
                matching: find.text(label),
              )
            : _tab(label);
        await _tap(tester, finder);
        expect(tester.takeException(), isNull, reason: label);
      }
    });
  }
}
