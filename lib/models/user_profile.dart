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

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'course': course,
    'institution': institution,
    'link': link,
  };
}
