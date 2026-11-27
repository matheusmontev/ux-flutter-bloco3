/// Formatos de texto gravados nos QR Codes do aplicativo.
library;

import 'dart:convert';

import '../models/user_profile.dart';

const _checkInPrefix = 'EVENTO:';
const _cardPrefix = 'CARTAO:';

String checkInCode(String activityId) => '$_checkInPrefix$activityId';

/// Devolve o id da atividade, ou nulo se o texto não for de check-in.
String? parseCheckInCode(String raw) {
  final text = raw.trim();
  if (!text.toUpperCase().startsWith(_checkInPrefix)) return null;
  final id = text.substring(_checkInPrefix.length).trim().toLowerCase();
  return id.isEmpty ? null : id;
}

String cardCode(UserProfile profile) =>
    '$_cardPrefix${base64Url.encode(utf8.encode(jsonEncode(profile.toJson())))}';

/// Devolve o perfil do cartão, ou nulo se o código for inválido.
UserProfile? parseCardCode(String raw) {
  final text = raw.trim();
  if (!text.startsWith(_cardPrefix)) return null;
  try {
    final bytes = base64Url.decode(text.substring(_cardPrefix.length));
    final json = jsonDecode(utf8.decode(bytes));
    if (json is! Map<String, dynamic>) return null;
    return UserProfile.fromJson(json);
  } on FormatException {
    return null;
  }
}
