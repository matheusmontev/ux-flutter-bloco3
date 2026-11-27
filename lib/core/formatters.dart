import '../models/activity.dart';

const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

String _two(int value) => value.toString().padLeft(2, '0');

String formatTime(DateTime date) => '${_two(date.hour)}:${_two(date.minute)}';

String formatDate(DateTime date) =>
    '${_two(date.day)}/${_two(date.month)}/${date.year}';

String formatDayShort(DateTime date) =>
    '${_weekdays[date.weekday - 1]} ${_two(date.day)}/${_two(date.month)}';

String formatTimeRange(Activity activity) =>
    '${formatTime(activity.start)} às ${formatTime(activity.end)}';

String formatHours(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (minutes == 0) return '${hours}h';
  return '${hours}h${_two(minutes)}';
}
