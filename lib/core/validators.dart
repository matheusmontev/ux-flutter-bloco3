/// Validações dos formulários. Devolvem a mensagem de erro ou nulo.
library;

import 'package:characters/characters.dart';

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Aceita nomes curtos, como "Jo", contando caracteres completos.
String? validateName(String? value) {
  if ((value ?? '').trim().characters.length < 2) {
    return 'Informe seu nome completo';
  }
  return null;
}

String? validateEmail(String? value) {
  if (!_email.hasMatch((value ?? '').trim())) return 'Informe um e-mail válido';
  return null;
}

String? validatePassword(String? value) {
  if ((value ?? '').length < 6) return 'Use pelo menos 6 caracteres';
  return null;
}
