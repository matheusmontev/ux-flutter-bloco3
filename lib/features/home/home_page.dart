import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../data/mock_data.dart';
import '../../widgets/activity_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_body.dart';
import '../schedule/activity_detail_page.dart';

/// Painel inicial: evento, resumo do participante e próximas atividades.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenTab});

  /// Abre uma das abas da navegação principal pelo índice.
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final upcoming = state.upcoming();
    final firstName = state.profile?.name.split(' ').first ?? '';

    return PageBody(
      children: [
        Text('Olá, $firstName', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDate(activities.first.start)} a '
                    '${formatDate(activities.last.start)}',
                  ),
                  const Text(eventPlace),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Stat(
              label: 'Presenças',
              value: '${state.attendedActivities.length}',
              onTap: () => onOpenTab(2),
            ),
            const SizedBox(width: 12),
            _Stat(
              label: 'Carga horária',
              value: formatHours(state.attendedHours),
              onTap: () => onOpenTab(2),
            ),
            const SizedBox(width: 12),
            _Stat(
              label: 'Contatos',
              value: '${state.contacts.length}',
              onTap: () => onOpenTab(3),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Próximas atividades', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (upcoming.isEmpty)
          const EmptyState(
            icon: Icons.celebration_outlined,
            title: 'Tudo concluído',
            message: 'Você registrou presença em todas as atividades.',
          )
        else
          for (final activity in upcoming)
            ActivityCard(
              activity: activity,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ActivityDetailPage(activity: activity),
                ),
              ),
            ),
        OutlinedButton(
          onPressed: () => onOpenTab(1),
          child: const Text('Ver programação completa'),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                FittedBox(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
