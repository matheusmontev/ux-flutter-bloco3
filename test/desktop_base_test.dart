import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/widgets/two_pane.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _size(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> _pumpPanes(WidgetTester tester, Size size) async {
  _size(tester, size);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: TwoPane(side: [Text('lateral')], main: [Text('principal')]),
      ),
    ),
  );
}

Future<void> _pumpApp(WidgetTester tester, Size size) async {
  _size(tester, size);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await SharedPreferences.getInstance());
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(EventosApp(state: state));
  await tester.pumpAndSettle();
}

Offset _at(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text));

NavigationRail _rail(WidgetTester tester) =>
    tester.widget<NavigationRail>(find.byType(NavigationRail));

void main() {
  group('Layout em duas colunas', () {
    testWidgets('no PC as colunas ficam lado a lado', (tester) async {
      await _pumpPanes(tester, const Size(1280, 800));

      expect(
        _at(tester, 'principal').dx,
        greaterThan(_at(tester, 'lateral').dx + 300),
      );
      expect(_at(tester, 'principal').dy, _at(tester, 'lateral').dy);
    });

    testWidgets('no celular o conteúdo é empilhado', (tester) async {
      await _pumpPanes(tester, const Size(390, 844));

      expect(
        _at(tester, 'principal').dy,
        greaterThan(_at(tester, 'lateral').dy),
      );
      expect(_at(tester, 'principal').dx, _at(tester, 'lateral').dx);
    });

    testWidgets('em monitor largo o conteúdo não estica demais', (
      tester,
    ) async {
      await _pumpPanes(tester, const Size(2560, 1440));

      expect(tester.getSize(find.byKey(const Key('two-pane'))).width, 1200);
      expect(_at(tester, 'lateral').dx, greaterThan(600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('cada coluna rola sozinha', (tester) async {
      _size(tester, const Size(1280, 600));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TwoPane(
              side: const [Text('fixo')],
              main: [for (var i = 0; i < 60; i++) Text('item $i')],
            ),
          ),
        ),
      );
      final before = _at(tester, 'fixo');

      await tester.drag(find.text('item 5'), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(_at(tester, 'fixo'), before);
      expect(tester.takeException(), isNull);
    });
  });

  group('Menu principal', () {
    testWidgets('em tela grande mostra o menu lateral aberto', (tester) async {
      await _pumpApp(tester, const Size(1366, 768));

      expect(_rail(tester).extended, isTrue);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('em tela média o menu lateral é compacto', (tester) async {
      await _pumpApp(tester, const Size(900, 700));

      expect(_rail(tester).extended, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no celular continua a barra inferior', (tester) async {
      await _pumpApp(tester, const Size(390, 844));

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
