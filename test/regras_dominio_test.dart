/// Regras de identidade e textos que antes ficavam repetidos nas telas.
library;

import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/core/certificate.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:eventos_academicos/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_state.dart';

const _ana = UserProfile(name: 'Ana Lima', email: 'ana@exemplo.com');

void main() {
  test('o e-mail identifica a pessoa sem diferenciar maiúsculas', () {
    expect(_ana.hasEmail(' ANA@Exemplo.com '), isTrue);
    expect(_ana.hasEmail('bia@exemplo.com'), isFalse);
  });

  test('remover um contato também ignora maiúsculas', () async {
    final state = await newAppState();
    await state.signIn(email: 'eu@exemplo.com');
    await state.addContact(
      'CARTAO:eyJuYW1lIjoiQW5hIiwiZW1haWwiOiJhbmFAZXhlbXBsby5jb20ifQ==',
    );
    expect(state.contacts, hasLength(1));

    await state.removeContact('ANA@exemplo.com');

    expect(state.contacts, isEmpty);
  });

  test('as iniciais não exigem um perfil', () {
    expect(UserProfile.initialsOf('Ana Beatriz Lima'), 'AL');
    expect(UserProfile.initialsOf(''), '?');
  });

  test('o texto copiado traz o certificado, o código e o aviso', () {
    final activity = activities.first;

    expect(
      certificateShareText(_ana, activity),
      '${certificateText(_ana, activity)}\n'
      'Código: ${certificateCode(_ana, activity)}\n'
      '$certificateDisclaimer',
    );
    expect(
      certificateDisclaimer,
      'Documento de demonstração, sem validade acadêmica.',
    );
  });

  test('o aviso de troca de conta fica junto da regra', () {
    expect(AppState.accountSwitchWarning, contains('serão apagados'));
  });
}
