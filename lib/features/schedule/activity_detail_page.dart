import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/activity.dart';
import '../../widgets/page_body.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/ticket_info.dart';
import '../checkin/check_in_page.dart';

/// Detalhes de uma atividade e acesso ao check-in.
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ink = colors.onPrimaryContainer;
    final attendedAt = AppScope.of(context).attendedAt(activity.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Atividade')),
      body: PageBody(
        maxWidth: 560,
        children: [
          Text(
            activity.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text('${activity.type} de ${activity.theme}'),
          const SizedBox(height: 20),
          TicketCard(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDayLong(activity.start)),
                TicketTime(activity.start),
                Text(
                  'até ${formatTime(activity.end)}, '
                  '${formatHours(activity.duration)} de atividade',
                ),
                const SizedBox(height: 16),
                TicketPlace(activity.room),
                const SizedBox(height: 4),
                Text('Com ${activity.speaker}'),
              ],
            ),
            stub: attendedAt == null
                ? FilledButton.icon(
                    style: accentButtonStyle(colors),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CheckInPage(activity: activity),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Fazer check-in'),
                  )
                : Row(
                    children: [
                      Icon(Icons.check_circle, color: ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Presença registrada',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Em ${formatDate(attendedAt)} às '
                              '${formatTime(attendedAt)}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          Text('Sobre', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(activity.description, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
