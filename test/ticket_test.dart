import 'dart:convert';
import 'dart:io';

import 'package:eventos_academicos/core/theme.dart';
import 'package:eventos_academicos/widgets/badge_card.dart';
import 'package:eventos_academicos/widgets/ticket_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child, {double width = 360}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 700);
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('Ingresso', () {
    testWidgets('mostra o corpo acima do canhoto, com o picote', (
      tester,
    ) async {
      await _pump(
        tester,
        const TicketCard(body: Text('corpo'), stub: Text('canhoto')),
      );
      final tear = find.byKey(const Key('ticket-tear'));

      expect(tear, findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('corpo')).dy,
        lessThan(tester.getTopLeft(tear).dy),
      );
      expect(
        tester.getTopLeft(find.text('canhoto')).dy,
        greaterThan(tester.getBottomLeft(tear).dy),
      );
    });

    testWidgets('tocar no corpo aciona a ação', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        TicketCard(
          body: const Text('corpo'),
          stub: const Text('canhoto'),
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('corpo'));

      expect(taps, 1);
    });

    test('o recorte abre um entalhe de cada lado na altura do picote', () {
      const size = Size(300, 200);
      final path = const TicketClipper(notchFromBottom: 60).getClip(size);

      expect(path.contains(const Offset(2, 140)), isFalse);
      expect(path.contains(const Offset(298, 140)), isFalse);
      expect(path.contains(const Offset(150, 140)), isTrue);
      expect(path.contains(const Offset(2, 70)), isTrue);
    });
  });

  group('Crachá', () {
    testWidgets('tem o furo do cordão e o cabeçalho acima do conteúdo', (
      tester,
    ) async {
      await _pump(
        tester,
        const BadgeCard(header: Text('nome'), child: Text('dados')),
        width: 320,
      );

      expect(find.byKey(const Key('badge-slot')), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('nome')).dy,
        lessThan(tester.getTopLeft(find.text('dados')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Cores do navegador e do app instalado', () {
    test('o navegador usa o fundo de cada tema', () {
      final html = File('web/index.html').readAsStringSync();

      for (final (scheme, color) in [
        ('light', '#F7F9F9'),
        ('dark', '#0F1A1D'),
      ]) {
        expect(
          html,
          contains(
            '<meta name="theme-color" '
            'media="(prefers-color-scheme: $scheme)" content="$color">',
          ),
        );
      }
    });

    test('o manifesto abandona o azul padrão do Flutter', () {
      final manifest = jsonDecode(
        File('web/manifest.json').readAsStringSync(),
      ) as Map<String, dynamic>;

      expect(manifest['theme_color'], '#006FA8');
      expect(manifest['background_color'], '#F7F9F9');
    });
  });
}
