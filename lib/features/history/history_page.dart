import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../models/activity.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/hours_chart.dart';
import '../../widgets/page_body.dart';
import '../../widgets/two_pane.dart';
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

    final count = attended.length;
    return TwoPane(
      sideWidth: 420,
      side: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Figure(
                key: const ValueKey('resumo-presencas'),
                value: '$count',
                label: count == 1 ? 'presença' : 'presenças',
              ),
              const VerticalDivider(width: 33),
              _Figure(
                key: const ValueKey('resumo-horas'),
                value: formatHours(state.attendedHours),
                label: 'de carga horária',
              ),
            ],
          ),
        ),
        const Divider(height: 40),
        Text('Carga horária por tema', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        HoursChart(activities: attended),
        const SizedBox(height: 24),
      ],
      main: [
        Text('Certificados', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final activity in attended)
          _CertificateRow(
            key: ValueKey('cert-${activity.id}'),
            activity: activity,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CertificatePage(activity: activity),
              ),
            ),
          ),
      ],
    );
  }
}

/// Número grande com a legenda logo abaixo.
class _Figure extends StatelessWidget {
  const _Figure({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              child: Text(
                value,
                style: Theme.of(context).textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Linha de certificado, com o dia da atividade como um canhoto.
class _CertificateRow extends StatelessWidget {
  const _CertificateRow({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: MediaQuery.textScalerOf(context).scale(52),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: colors.onPrimaryContainer),
                child: Column(
                  children: [
                    Text(
                      formatDayNumber(activity.start),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(formatMonthShort(activity.start)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title, style: theme.textTheme.titleMedium),
                  Text(
                    '${formatHours(activity.duration)} de ${activity.theme}',
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
