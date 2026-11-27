import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/event.dart';
import '../models/user_profile.dart';
import 'codes.dart';

enum CheckInStatus { success, invalidCode, otherActivity, alreadyDone }

class CheckInResult {
  const CheckInResult(this.status, [this.activity]);

  final CheckInStatus status;
  final Activity? activity;
}

enum AddContactStatus { success, invalidCode, ownCard, alreadyAdded }

/// Estado global do aplicativo, com persistência no próprio aparelho.
class AppState extends ChangeNotifier {
  AppState(this._prefs, {required this.event, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _restore();
  }

  static const _profileKey = 'profile';
  static const _loggedKey = 'logged';
  static const _attendanceKey = 'attendance';
  static const _contactsKey = 'contacts';
  static const _darkKey = 'dark';

  /// Descreve para quem usa a regra de troca de conta de [signIn].
  static const accountSwitchWarning =
      'Seus dados continuam neste aparelho. Ao entrar com outro '
      'e-mail, presenças e contatos serão apagados.';

  final Event event;
  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  UserProfile? _profile;
  bool _logged = false;
  bool _darkMode = false;
  final Map<String, DateTime> _attendance = {};
  final List<UserProfile> _contacts = [];

  UserProfile? get profile => _profile;

  /// O perfil, para as telas que só existem com a sessão aberta.
  UserProfile get sessionProfile =>
      _profile ?? (throw StateError('Tela aberta sem sessão'));
  bool get isLogged => _logged && _profile != null;
  bool get darkMode => _darkMode;
  List<UserProfile> get contacts => List.unmodifiable(_contacts);

  bool hasAttended(String activityId) => _attendance.containsKey(activityId);

  DateTime? attendedAt(String activityId) => _attendance[activityId];

  /// Atividades com presença registrada, em ordem de horário.
  List<Activity> get attendedActivities =>
      event.activities.where((a) => hasAttended(a.id)).toList();

  Duration get attendedHours =>
      attendedActivities.fold(Duration.zero, (total, a) => total + a.duration);

  /// Próximas atividades ainda sem presença.
  List<Activity> upcoming({int limit = 3}) =>
      event.activities.where((a) => !hasAttended(a.id)).take(limit).toList();

  /// Entrada simulada: não há servidor e a senha não é armazenada.
  /// Ao trocar de conta, os dados da conta anterior são apagados.
  Future<void> signIn({required String email, String? name}) async {
    final normalized = UserProfile.normalizeEmail(email);
    if (!(_profile?.hasEmail(normalized) ?? false)) {
      _attendance.clear();
      _contacts.clear();
      final typed = name?.trim() ?? '';
      _profile = UserProfile(
        name: typed.isNotEmpty ? typed : normalized.split('@').first,
        email: normalized,
      );
    }
    _logged = true;
    await _save();
  }

  Future<void> signOut() async {
    _logged = false;
    await _save();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    await _save();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _save();
  }

  /// Registra presença a partir do texto de um QR Code.
  /// Com [expectedId], recusa o código de outra atividade.
  Future<CheckInResult> checkIn(String raw, {String? expectedId}) async {
    final id = parseCheckInCode(raw);
    final activity = id == null ? null : event.findActivity(id);
    if (activity == null) {
      return const CheckInResult(CheckInStatus.invalidCode);
    }
    if (expectedId != null && activity.id != expectedId) {
      return CheckInResult(CheckInStatus.otherActivity, activity);
    }
    if (hasAttended(activity.id)) {
      return CheckInResult(CheckInStatus.alreadyDone, activity);
    }
    _attendance[activity.id] = _clock();
    await _save();
    return CheckInResult(CheckInStatus.success, activity);
  }

  Future<AddContactStatus> addContact(String raw) async {
    final contact = parseCardCode(raw);
    if (contact == null) return AddContactStatus.invalidCode;
    if (_profile?.hasEmail(contact.email) ?? false) {
      return AddContactStatus.ownCard;
    }
    if (_contacts.any((c) => c.hasEmail(contact.email))) {
      return AddContactStatus.alreadyAdded;
    }
    _contacts.add(contact);
    await _save();
    return AddContactStatus.success;
  }

  Future<void> removeContact(String email) async {
    _contacts.removeWhere((c) => c.hasEmail(email));
    await _save();
  }

  void _restore() {
    _darkMode = _prefs.getBool(_darkKey) ?? false;
    try {
      final profile = _prefs.getString(_profileKey);
      if (profile != null) {
        _profile = UserProfile.fromJson(
          jsonDecode(profile) as Map<String, dynamic>,
        );
      }
      final attendance = _prefs.getString(_attendanceKey);
      if (attendance != null) {
        (jsonDecode(attendance) as Map<String, dynamic>).forEach((id, value) {
          _attendance[id] = DateTime.parse(value as String);
        });
      }
      for (final item in _prefs.getStringList(_contactsKey) ?? <String>[]) {
        _contacts.add(
          UserProfile.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      }
      _logged = _prefs.getBool(_loggedKey) ?? false;
    } catch (error) {
      // Dados corrompidos: volta ao estado inicial em vez de travar o app.
      debugPrint('Falha ao restaurar dados locais: $error');
      _profile = null;
      _logged = false;
      _attendance.clear();
      _contacts.clear();
    }
  }

  Future<void> _save() async {
    notifyListeners();
    final profile = _profile;
    if (profile != null) {
      await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    }
    await _prefs.setBool(_loggedKey, _logged);
    await _prefs.setBool(_darkKey, _darkMode);
    await _prefs.setString(
      _attendanceKey,
      jsonEncode(_attendance.map((k, v) => MapEntry(k, v.toIso8601String()))),
    );
    await _prefs.setStringList(
      _contactsKey,
      _contacts.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}

/// Entrega o [AppState] à árvore de widgets e atualiza quem depende dele.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
