import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/codes.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _load() async => AppState(
  await SharedPreferences.getInstance(),
  event: demoEvent,
  clock: () => DateTime(2026, 12, 9, 8, 35),
);

void main() {
  late AppState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = await _load();
    await state.signIn(email: 'Ana@Exemplo.com', name: 'Ana Lima');
  });

  group('Check-in', () {
    test('registra presença e soma a carga horária', () async {
      final result = await state.checkIn('EVENTO:a01');

      expect(result.status, CheckInStatus.success);
      expect(state.attendedAt('a01'), DateTime(2026, 12, 9, 8, 35));
      expect(state.attendedHours, const Duration(minutes: 90));
      expect(state.upcoming().first.id, 'a02');
    });

    test('não duplica a presença', () async {
      await state.checkIn('EVENTO:a01');
      final result = await state.checkIn('EVENTO:a01');

      expect(result.status, CheckInStatus.alreadyDone);
      expect(state.attendedActivities, hasLength(1));
    });

    test('recusa código inválido ou de atividade inexistente', () async {
      for (final code in ['qualquer coisa', 'EVENTO:zz9']) {
        final result = await state.checkIn(code);

        expect(result.status, CheckInStatus.invalidCode);
      }
      expect(state.attendedActivities, isEmpty);
    });

    test('recusa o código de outra atividade', () async {
      final result = await state.checkIn('EVENTO:a02', expectedId: 'a01');

      expect(result.status, CheckInStatus.otherActivity);
      expect(state.hasAttended('a02'), isFalse);
    });
  });

  group('Contatos', () {
    test('adiciona uma vez e permite remover', () async {
      final code = cardCode(sampleContact);

      expect(await state.addContact(code), AddContactStatus.success);
      expect(await state.addContact(code), AddContactStatus.alreadyAdded);
      await state.removeContact(sampleContact.email);

      expect(state.contacts, isEmpty);
    });

    test('recusa o próprio cartão e código inválido', () async {
      const own = UserProfile(name: 'Ana Lima', email: 'ANA@exemplo.com');

      expect(await state.addContact(cardCode(own)), AddContactStatus.ownCard);
      expect(await state.addContact('abc'), AddContactStatus.invalidCode);
    });
  });

  group('Sessão e persistência', () {
    test('restaura os dados salvos', () async {
      await state.checkIn('EVENTO:a01');
      await state.addContact(cardCode(sampleContact));
      await state.setDarkMode(true);

      final restored = await _load();

      expect(restored.isLogged, isTrue);
      expect(restored.profile?.email, 'ana@exemplo.com');
      expect(restored.hasAttended('a01'), isTrue);
      expect(restored.contacts, hasLength(1));
      expect(restored.darkMode, isTrue);
    });

    test('a mesma conta mantém os dados após sair', () async {
      await state.checkIn('EVENTO:a01');
      await state.signOut();
      await state.signIn(email: 'ana@exemplo.com');

      expect(state.hasAttended('a01'), isTrue);
      expect(state.profile?.name, 'Ana Lima');
    });

    test('outra conta não vê os dados da anterior', () async {
      await state.checkIn('EVENTO:a01');
      await state.addContact(cardCode(sampleContact));
      await state.signOut();
      await state.signIn(email: 'bia@exemplo.com');

      expect(state.attendedActivities, isEmpty);
      expect(state.contacts, isEmpty);
    });

    test('não armazena senha', () async {
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getKeys().where((k) => k.contains('pass')), isEmpty);
    });

    test('dados corrompidos não travam o aplicativo', () async {
      SharedPreferences.setMockInitialValues({
        'profile': '{quebrado',
        'logged': true,
      });

      final restored = await _load();

      expect(restored.isLogged, isFalse);
      expect(restored.attendedActivities, isEmpty);
    });
  });
}
