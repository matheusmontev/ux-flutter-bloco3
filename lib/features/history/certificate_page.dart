import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/certificate.dart';
import '../../models/activity.dart';
import '../../widgets/page_body.dart';

/// Certificado gerado a partir de uma presença registrada.
class CertificatePage extends StatelessWidget {
  const CertificatePage({super.key, required this.activity});

  final Activity activity;

  Future<void> _copy(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(
      const SnackBar(content: Text('Texto do certificado copiado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = AppScope.of(context);
    final profile = state.sessionProfile;
    final event = state.event;
    final text = certificateText(profile, activity, event);
    final code = certificateCode(profile, activity);

    return Scaffold(
      appBar: AppBar(title: const Text('Certificado')),
      body: PageBody(
        maxWidth: 640,
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(
                  color: theme.colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.workspace_premium_outlined,
                          size: 40,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Certificado de participação',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(event.place),
                      const Divider(height: 32),
                      Text(
                        'Código: $code',
                        key: const Key('cert-codigo'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        certificateDisclaimer,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () =>
                _copy(context, certificateShareText(profile, activity, event)),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar texto'),
          ),
        ],
      ),
    );
  }
}
