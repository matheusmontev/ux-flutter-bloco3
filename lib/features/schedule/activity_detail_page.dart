import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../models/activity.dart';
import '../../widgets/page_body.dart';
import '../checkin/check_in_page.dart';

/// Detalhes de uma atividade e acesso ao check-in.
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attendedAt = AppScope.of(context).attendedAt(activity.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Atividade')),
      body: PageBody(
        children: [
          Text(activity.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${activity.type} · ${activity.theme}'),
          const SizedBox(height: 16),
          _Info(
            icon: Icons.schedule,
            text:
                '${formatDate(activity.start)}, ${formatTimeRange(activity)} '
                '(${formatHours(activity.duration)})',
          ),
          _Info(icon: Icons.place_outlined, text: activity.room),
          _Info(icon: Icons.person_outline, text: activity.speaker),
          const SizedBox(height: 16),
          Text(activity.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 32),
          if (attendedAt == null)
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => CheckInPage(activity: activity),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Fazer check-in'),
            )
          else
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Presença registrada'),
                subtitle: Text(
                  'Em ${formatDate(attendedAt)} às ${formatTime(attendedAt)}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
