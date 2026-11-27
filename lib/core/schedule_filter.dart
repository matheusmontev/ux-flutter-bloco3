import '../models/activity.dart';

/// Critérios de filtro da programação. Campos nulos não filtram.
class ScheduleFilter {
  const ScheduleFilter({this.day, this.period, this.theme, this.query = ''});

  final DateTime? day;
  final Shift? period;
  final String? theme;
  final String query;

  bool get isEmpty =>
      day == null && period == null && theme == null && query.trim().isEmpty;

  /// Devolve as atividades que atendem aos critérios, em ordem de horário.
  List<Activity> apply(Iterable<Activity> source) {
    final term = _normalize(query);
    final result = source.where((a) {
      if (day != null && a.day != day) return false;
      if (period != null && a.shift != period) return false;
      if (theme != null && a.theme != theme) return false;
      if (term.isEmpty) return true;
      return _normalize('${a.title} ${a.speaker} ${a.room}').contains(term);
    }).toList();
    result.sort(byStart);
    return result;
  }

  /// Ignora maiúsculas e acentos na busca.
  static String _normalize(String value) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    var text = value.trim().toLowerCase();
    for (var i = 0; i < from.length; i++) {
      text = text.replaceAll(from[i], to[i]);
    }
    return text;
  }
}

/// Agrupa as atividades por dia, com dias e horários em ordem.
Map<DateTime, List<Activity>> groupByDay(Iterable<Activity> source) {
  final sorted = source.toList()..sort(byStart);
  final groups = <DateTime, List<Activity>>{};
  for (final activity in sorted) {
    groups.putIfAbsent(activity.day, () => []).add(activity);
  }
  return groups;
}
