import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/certificate.dart';
import '../../data/mock_data.dart';
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
    final profile = AppScope.of(context).profile!;
    final text = certificateText(profile, activity);
    final code = certificateCode(profile, activity);

    return Scaffold(
      appBar: AppBar(title: const Text('Certificado')),
      body: PageBody(
        maxWidth: 640,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'CERTIFICADO DE PARTICIPAÇÃO',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    text,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(eventPlace, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Código: $code', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(
                    'Documento de demonstração, sem validade acadêmica.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _copy(
              context,
              '$text\nCódigo: $code\n'
              'Documento de demonstração, sem validade acadêmica.',
            ),
            icon: const Icon(Icons.copy),
            label: const Text('Copiar texto'),
          ),
        ],
      ),
    );
  }
}
