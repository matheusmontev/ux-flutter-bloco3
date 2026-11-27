import 'activity.dart';

/// Um evento e a sua programação.
class Event {
  /// As atividades podem chegar em qualquer ordem: o evento as ordena por
  /// horário. Precisa haver ao menos uma, que define o período.
  Event({
    required this.name,
    required this.place,
    required Iterable<Activity> activities,
  }) : activities = List.unmodifiable(activities.toList()..sort(byStart));

  final String name;
  final String place;
  final List<Activity> activities;

  DateTime get firstDay => activities.first.day;
  DateTime get lastDay => activities.last.day;

  List<DateTime> get days => {for (final a in activities) a.day}.toList();

  List<String> get themes =>
      {for (final a in activities) a.theme}.toList()..sort();

  /// Não diferencia maiúsculas, porque o código pode ser digitado.
  Activity? findActivity(String id) {
    final wanted = id.toLowerCase();
    for (final activity in activities) {
      if (activity.id.toLowerCase() == wanted) return activity;
    }
    return null;
  }
}
