import 'package:material_ui/material_ui.dart';

import '../core/formatters.dart';
import '../models/activity.dart';

/// Soma a carga horária por tema, da maior para a menor.
List<({String theme, Duration total})> hoursByTheme(Iterable<Activity> source) {
  final totals = <String, Duration>{};
  for (final a in source) {
    totals[a.theme] = (totals[a.theme] ?? Duration.zero) + a.duration;
  }
  return [for (final e in totals.entries) (theme: e.key, total: e.value)]
    ..sort((a, b) {
      final byTotal = b.total.compareTo(a.total);
      return byTotal != 0 ? byTotal : a.theme.compareTo(b.theme);
    });
}

/// Barras horizontais a partir de zero, em uma só cor.
/// O nome e o valor ficam escritos, então a leitura não depende da cor.
class HoursChart extends StatelessWidget {
  const HoursChart({super.key, required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    final totals = hoursByTheme(activities);
    if (totals.isEmpty) return const SizedBox.shrink();

    // Tons conferidos quanto ao contraste com o fundo de cada tema.
    final color = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF006FA8)
        : const Color(0xFF0099B0);
    final max = totals.first.total.inMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (:theme, :total) in totals)
          Tooltip(
            message: '$theme: ${formatHours(total)}',
            child: MergeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(theme)),
                        Text(
                          formatHours(total),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FractionallySizedBox(
                      widthFactor: total.inMinutes / max,
                      child: SizedBox(
                        height: 10,
                        child: DecoratedBox(
                          key: ValueKey('bar-$theme'),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
