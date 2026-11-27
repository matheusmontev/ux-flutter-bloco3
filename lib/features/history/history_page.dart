import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/hours_chart.dart';
import '../../widgets/page_body.dart';
import 'certificate_page.dart';

/// Histórico de presença, resumo por tema e acesso aos certificados.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.onOpenSchedule});

  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final attended = state.attendedActivities;

    if (attended.isEmpty) {
      return PageBody(
        children: [
          EmptyState(
            icon: Icons.fact_check_outlined,
            title: 'Nenhuma presença ainda',
            message:
                'Faça check-in em uma atividade para liberar o certificado.',
            action: FilledButton(
              onPressed: onOpenSchedule,
              child: const Text('Ver programação'),
            ),
          ),
        ],
      );
    }

    return PageBody(
      children: [
        Text(
          '${attended.length} ${attended.length == 1 ? 'presença' : 'presenças'}'
          ' · ${formatHours(state.attendedHours)}',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carga horária por tema',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                HoursChart(activities: attended),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Certificados', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final activity in attended)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(activity.title),
                subtitle: Text(
                  '${formatDayShort(activity.start)} · '
                  '${formatHours(activity.duration)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => CertificatePage(activity: activity),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
