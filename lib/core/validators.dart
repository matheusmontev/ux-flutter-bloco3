/// Validações dos formulários. Devolvem a mensagem de erro ou nulo.
library;

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateName(String? value) {
  if ((value ?? '').trim().length < 3) return 'Informe seu nome completo';
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
