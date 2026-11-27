import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../core/schedule_filter.dart';
import '../../data/mock_data.dart';
import '../../models/activity.dart';
import '../../widgets/agenda_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/two_pane.dart';
import '../checkin/check_in_page.dart';
import '../schedule/activity_detail_page.dart';

/// Painel inicial: onde ir agora, resumo do participante e o que vem depois.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenTab});

  /// Abre uma das abas da navegação principal pelo índice.
  final ValueChanged<int> onOpenTab;

  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final upcoming = state.upcoming(limit: 4);
    final next = upcoming.isEmpty ? null : upcoming.first;
    final later = groupByDay(upcoming.skip(1));
    final firstName = state.profile?.name.trim().split(' ').first ?? '';

    return TwoPane(
      sideWidth: 420,
      side: [
        Text(
          'Olá, $firstName',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(eventName),
        Text(
          '${formatDate(activities.first.start)} a '
          '${formatDate(activities.last.start)}, $eventPlace',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        if (next != null)
          _NextTicket(
            activity: next,
            onDetails: () => _open(context, ActivityDetailPage(activity: next)),
            onCheckIn: () => _open(context, CheckInPage(activity: next)),
          )
        else
          const EmptyState(
            icon: Icons.celebration_outlined,
            title: 'Tudo concluído',
            message: 'Você registrou presença em todas as atividades.',
          ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Stat(
                label: 'Presenças',
                value: '${state.attendedActivities.length}',
                onTap: () => onOpenTab(2),
              ),
              const VerticalDivider(width: 1),
              _Stat(
                label: 'Carga horária',
                value: formatHours(state.attendedHours),
                onTap: () => onOpenTab(2),
              ),
              const VerticalDivider(width: 1),
              _Stat(
                label: 'Contatos',
                value: '${state.contacts.length}',
                onTap: () => onOpenTab(3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
      main: [
        Text('Próximas atividades', style: theme.textTheme.titleLarge),
        if (later.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Não há outras atividades pendentes.'),
          ),
        for (final MapEntry(key: day, value: items) in later.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              formatDayLong(day),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final activity in items)
            AgendaItem(
              key: ValueKey('proxima-${activity.id}'),
              activity: activity,
              onTap: () =>
                  _open(context, ActivityDetailPage(activity: activity)),
            ),
        ],
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => onOpenTab(1),
          child: const Text('Ver programação completa'),
        ),
      ],
    );
  }
}

/// A próxima atividade, com o que importa no caminho: horário e sala.
class _NextTicket extends StatelessWidget {
  const _NextTicket({
    required this.activity,
    required this.onDetails,
    required this.onCheckIn,
  });

  final Activity activity;
  final VoidCallback onDetails;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ink = colors.onPrimaryContainer;

    return TicketCard(
      onTap: onDetails,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A seguir, ${formatDayLong(activity.start).toLowerCase()}'),
          Text(
            formatTime(activity.start),
            style: theme.textTheme.displayMedium?.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(Icons.place, size: 22, color: ink),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  activity.room,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.title,
            style: theme.textTheme.titleMedium?.copyWith(color: ink),
          ),
          Text(activity.speaker),
        ],
      ),
      stub: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: colors.tertiary,
          foregroundColor: colors.onTertiary,
        ),
        onPressed: onCheckIn,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Fazer check-in'),
      ),
    );
  }
}

/// Número do participante; leva à área correspondente.
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              FittedBox(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              FittedBox(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}
