/// Componentes usados em mais de uma tela. Fixam a aparência que cada tela
/// tinha antes de compartilhá-los.
library;

import 'package:eventos_academicos/core/formatters.dart';
import 'package:eventos_academicos/core/theme.dart';
import 'package:eventos_academicos/models/user_profile.dart';
import 'package:eventos_academicos/widgets/badge_avatar.dart';
import 'package:eventos_academicos/widgets/ticket_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final _theme = buildTheme(Brightness.light);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: _theme,
    home: Scaffold(body: child),
  ),
);

void main() {
  test('o botão de destaque usa o âmbar do tema', () {
    final style = accentButtonStyle(_theme.colorScheme);

    expect(style.backgroundColor?.resolve({}), _theme.colorScheme.tertiary);
    expect(style.foregroundColor?.resolve({}), _theme.colorScheme.onTertiary);
  });

  testWidgets('o horário e a sala do ingresso ficam em destaque', (
    tester,
  ) async {
    await _pump(
      tester,
      Column(
        children: [
          TicketTime(DateTime(2026, 12, 9, 8, 30)),
          const TicketPlace('Auditório A'),
        ],
      ),
    );

    for (final text in ['08:30', 'Auditório A']) {
      final style = tester.widget<Text>(find.text(text)).style!;
      expect(style.fontWeight, FontWeight.w700, reason: text);
      expect(style.color, _theme.colorScheme.onPrimaryContainer, reason: text);
    }
    expect(tester.widget<Icon>(find.byIcon(Icons.place)).size, 22);
  });

  testWidgets('o avatar do crachá mostra as iniciais invertendo as cores', (
    tester,
  ) async {
    await _pump(tester, const BadgeAvatar(initials: 'AL', radius: 26));

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, 26);
    expect(avatar.backgroundColor, _theme.colorScheme.onPrimary);
    expect(avatar.foregroundColor, _theme.colorScheme.primary);
    expect(find.text('AL'), findsOneWidget);
  });

  test('o perfil lista os dados opcionais com os rótulos', () {
    const profile = UserProfile(
      name: 'Ana',
      email: 'ana@exemplo.com',
      course: 'Design',
      link: 'exemplo.com/ana',
    );

    expect(profile.optionalDetails, [
      (label: 'Curso ou área', value: 'Design'),
      (label: 'Instituição', value: ''),
      (label: 'Link profissional', value: 'exemplo.com/ana'),
    ]);
  });

  test('o dia do canhoto tem sempre dois dígitos', () {
    expect(formatDayNumber(DateTime(2026, 12, 9)), '09');
    expect(formatDayNumber(DateTime(2026, 12, 11)), '11');
  });
}
