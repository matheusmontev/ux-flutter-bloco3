import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/codes.dart';
import 'package:eventos_academicos/core/validators.dart';
import 'package:eventos_academicos/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/app_state.dart';

String _initials(String name) =>
    UserProfile(name: name, email: 'a@b.test').initials;

void main() {
  group('Iniciais', () {
    const cases = {
      'Ana Lima': 'AL',
      'dana': 'D',
      '  Sam   Lee ': 'SL',
      'María de la Cruz': 'MC',
      'Ólafur Darri Ólafsson': 'ÓÓ',
      '王秀英': '王',
      // Emojis soltos não contam quando há uma palavra com letras.
      '🦊 Fox': 'F',
      'Priya 👩🏽‍💻': 'P',
      // Um emoji composto é mantido inteiro.
      '👩🏽‍💻': '👩🏽‍💻',
      '': '?',
      '   ': '?',
    };

    for (final MapEntry(key: name, value: expected) in cases.entries) {
      test('"$name" vira "$expected"', () {
        expect(_initials(name), expected);
      });
    }

    test('ignoram sufixos como III e Jr.', () {
      expect(_initials('Christopher Montgomery III'), 'CM');
      expect(_initials('Carlos Souza Jr.'), 'CS');
      expect(_initials('John III'), 'J');
    });

    test('Filho e Neto só são sufixo quando há outro sobrenome', () {
      expect(_initials('João Silva Filho'), 'JS');
      expect(_initials('Pedro Alves Júnior'), 'PA');
      expect(_initials('Ana Neto'), 'AN');
    });
  });

  group('Validação do nome', () {
    test('aceita nomes de duas letras', () {
      for (final name in ['Jo', 'Li', '  Al  ', '王秀']) {
        expect(validateName(name), isNull, reason: name);
      }
    });

    test('recusa vazio, uma letra ou um único emoji', () {
      for (final name in [null, '', '   ', 'A', ' b ', '👩🏽‍💻']) {
        expect(validateName(name), isNotNull, reason: '$name');
      }
    });
  });

  group('Tela com nome que tem emoji', () {
    testWidgets('perfil e contato recebido abrem sem erro', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final state = await newAppState();
      await state.signIn(email: 'fox@exemplo.com', name: '🦊 Fox');
      await state.addContact(
        cardCode(
          const UserProfile(name: '🌵 Bia 🚀', email: 'bia@exemplo.com'),
        ),
      );
      await tester.pumpWidget(EventosApp(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Networking'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('F'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('🌵 Bia 🚀'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
