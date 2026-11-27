import 'package:characters/characters.dart';

/// Dados do participante. Também formam o cartão virtual.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.course = '',
    this.institution = '',
    this.link = '',
  });

  /// Lança [FormatException] quando faltam nome ou e-mail.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final email = json['email'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Cartão sem nome');
    }
    if (email is! String || !email.contains('@')) {
      throw const FormatException('Cartão sem e-mail');
    }
    String text(String key) => json[key] is String ? json[key] as String : '';
    return UserProfile(
      name: name,
      email: email,
      course: text('course'),
      institution: text('institution'),
      link: text('link'),
    );
  }

  final String name;
  final String email;
  final String course;
  final String institution;
  final String link;

  /// Primeira letra do primeiro e do último nome, sem contar sufixos.
  /// Usa caracteres completos, para não cortar um emoji ao meio.
  String get initials {
    final all = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (all.isEmpty) return '?';
    final named = all.where(_hasLetter.hasMatch).toList();
    // Sem nenhuma palavra com letras, mostra o primeiro símbolo inteiro.
    if (named.isEmpty) return all.first.characters.first;

    while (named.length > 1 && _isSuffix(named.last, named.length)) {
      named.removeLast();
    }
    final first = _firstLetter(named.first);
    final last = named.length > 1 ? _firstLetter(named.last) : '';
    return '$first$last'.toUpperCase();
  }

  static final _hasLetter = RegExp(r'\p{L}', unicode: true);

  static String _firstLetter(String word) =>
      word.characters.firstWhere(_hasLetter.hasMatch);

  static bool _isSuffix(String word, int words) {
    final text = word.toLowerCase().replaceAll(RegExp(r'[.,]'), '');
    if (const {'jr', 'sr', 'ii', 'iii', 'iv'}.contains(text)) return true;
    // Estes também são sobrenomes: só são sufixo quando sobra outro.
    return words > 2 &&
        const {'júnior', 'junior', 'filho', 'neto', 'sobrinho'}.contains(text);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'course': course,
    'institution': institution,
    'link': link,
  };
}
