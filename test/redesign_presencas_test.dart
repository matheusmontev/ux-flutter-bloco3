import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/theme.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/features/history/certificate_page.dart';
import 'package:eventos_academicos/features/history/history_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _pump(
  WidgetTester tester,
  Widget page, {
  List<String> attended = const ['a01', 'a02'],
  Size size = const Size(390, 844),
  double scale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  SharedPreferences.setMockInitialValues({});
  final state = AppState(await SharedPreferences.getInstance());
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  for (final id in attended) {
    await state.checkIn('EVENTO:$id');
  }
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        home: Scaffold(body: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Finder _in(String key, String text) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(text));

final _history = HistoryPage(onOpenSchedule: () {});

void main() {
  group('Presenças', () {
    testWidgets('resume presenças e horas em dois números', (tester) async {
      await _pump(tester, _history);

      expect(_in('resumo-presencas', '2'), findsOneWidget);
      expect(_in('resumo-presencas', 'presenças'), findsOneWidget);
      expect(_in('resumo-horas', '4h30'), findsOneWidget);
      expect(find.textContaining('·'), findsNothing);
    });

    testWidgets('usa o singular com uma presença', (tester) async {
      await _pump(tester, _history, attended: ['a01']);

      expect(_in('resumo-presencas', 'presença'), findsOneWidget);
    });

    testWidgets('cada certificado traz o dia em destaque e abre', (
      tester,
    ) async {
      await _pump(tester, _history);
      final row = find.byKey(const ValueKey('cert-a02'));
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();

      expect(_in('cert-a02', '09'), findsOneWidget);
      expect(_in('cert-a02', 'dez'), findsOneWidget);

      await tester.tap(row);
      await tester.pumpAndSettle();

      expect(find.byType(CertificatePage), findsOneWidget);
    });
  });

  group('Certificado', () {
    testWidgets('tem título sem caixa alta, código e aviso', (tester) async {
      await _pump(tester, CertificatePage(activity: activities.first));

      expect(find.text('Certificado de participação'), findsOneWidget);
      expect(find.text('CERTIFICADO DE PARTICIPAÇÃO'), findsNothing);
      expect(find.byKey(const Key('cert-codigo')), findsOneWidget);
      expect(find.textContaining('sem validade'), findsOneWidget);
    });
  });

  testWidgets('cabe em 320 px com fonte em 200%', (tester) async {
    await _pump(tester, _history, size: const Size(320, 640), scale: 2);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      CertificatePage(activity: activities[3]),
      size: const Size(320, 640),
      scale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
