/// Turno de uma atividade, usado no filtro de horário.
enum Shift {
  morning('Manhã'),
  afternoon('Tarde'),
  evening('Noite');

  const Shift(this.label);

  final String label;
}

/// Uma atividade da programação do evento.
class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.speaker,
    required this.room,
    required this.theme,
    required this.type,
    required this.start,
    required this.end,
    required this.description,
  });

  final String id;
  final String title;
  final String speaker;
  final String room;
  final String theme;
  final String type;
  final DateTime start;
  final DateTime end;
  final String description;

  Duration get duration => end.difference(start);

  DateTime get day => DateTime(start.year, start.month, start.day);

  Shift get shift {
    if (start.hour < 12) return Shift.morning;
    if (start.hour < 18) return Shift.afternoon;
    return Shift.evening;
  }
}
