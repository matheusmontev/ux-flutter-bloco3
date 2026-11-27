import 'package:material_ui/material_ui.dart';

import '../core/formatters.dart';
import '../models/activity.dart';

/// Resumo de uma atividade, com dia, horário, local e tema.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.attended = false,
    this.onTap,
  });

  final Activity activity;
  final bool attended;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatDayShort(activity.start)} · '
                  '${formatTimeRange(activity)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${activity.room} · ${activity.speaker}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _Tag(label: activity.theme),
                    _Tag(label: activity.type),
                    if (attended)
                      const _Tag(
                        label: 'Presença registrada',
                        icon: Icons.check_circle,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: colors.onSecondaryContainer),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: colors.onSecondaryContainer)),
        ],
      ),
    );
  }
}
