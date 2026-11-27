import 'package:eventos_academicos/core/certificate.dart';
import 'package:eventos_academicos/core/codes.dart';
import 'package:eventos_academicos/core/formatters.dart';
import 'package:eventos_academicos/core/schedule_filter.dart';
import 'package:eventos_academicos/core/validators.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/models/activity.dart';
import 'package:eventos_academicos/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Filtros da programação', () {
    test('sem critérios devolve tudo em ordem de horário', () {
      final result = const ScheduleFilter().apply(activities.reversed);

      expect(result.map((a) => a.id), activities.map((a) => a.id));
    });

    test('combina dia, turno e tema', () {
      final result = ScheduleFilter(
        day: DateTime(2026, 12, 10),
        period: Shift.afternoon,
        theme: 'UX',
      ).apply(activities);

      expect(result.map((a) => a.id), ['a06']);
    });

    test('busca ignora acentos e maiúsculas', () {
      final result = const ScheduleFilter(query: 'ANDRE').apply(activities);

      expect(result.map((a) => a.id), ['a05', 'a08']);
    });

    test('devolve lista vazia quando nada atende', () {
      const filter = ScheduleFilter(query: 'inexistente');

      expect(filter.apply(activities), isEmpty);
    });
  });

  group('Códigos QR', () {
    test('lê o código de check-in com espaços e caixa diferente', () {
      expect(parseCheckInCode('  evento:A01 '), 'a01');
    });

    test('recusa texto fora do formato', () {
      expect(parseCheckInCode('a01'), isNull);
      expect(parseCheckInCode('EVENTO:'), isNull);
      expect(parseCheckInCode(''), isNull);
    });

    test('cartão preserva os dados e os acentos', () {
      const profile = UserProfile(
        name: 'João Conceição',
        email: 'joao@exemplo.com',
        course: 'Computação',
      );

      final result = parseCardCode(cardCode(profile));

      expect(result?.toJson(), profile.toJson());
    });

    test('recusa cartão corrompido ou incompleto', () {
      expect(parseCardCode('CARTAO:%%%'), isNull);
      expect(parseCardCode('CARTAO:e30='), isNull); // objeto vazio
      expect(parseCardCode('CARTAO:W10='), isNull); // lista
      expect(parseCardCode('https://exemplo.com'), isNull);
    });
  });

  group('Formulários', () {
    test('valida nome, e-mail e senha', () {
      expect(validateName('Al'), isNotNull);
      expect(validateName('Ana'), isNull);
      expect(validateEmail('ana@'), isNotNull);
      expect(validateEmail('ana@exemplo.com'), isNull);
      expect(validatePassword('12345'), isNotNull);
      expect(validatePassword('123456'), isNull);
    });
  });

  group('Certificado e formatação', () {
    const ana = UserProfile(name: 'Ana Lima', email: 'ana@exemplo.com');

    test('código é estável e muda conforme a atividade', () {
      final first = certificateCode(ana, activities[0]);

      expect(certificateCode(ana, activities[0]), first);
      expect(certificateCode(ana, activities[1]), isNot(first));
    });

    test('texto traz nome, atividade e carga horária', () {
      final text = certificateText(ana, activities[0]);

      expect(text, contains('Ana Lima'));
      expect(text, contains(activities[0].title));
      expect(text, contains('1h30'));
    });

    test('formata duração e iniciais', () {
      expect(formatHours(const Duration(hours: 3)), '3h');
      expect(formatHours(const Duration(minutes: 65)), '1h05');
      expect(ana.initials, 'AL');
    });
  });
}
