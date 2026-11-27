import 'package:material_ui/material_ui.dart';

import '../../core/codes.dart';
import '../../core/formatters.dart';
import '../../data/mock_data.dart';
import '../../widgets/page_body.dart';
import '../../widgets/qr_box.dart';

/// Faz o papel dos cartazes da organização durante a demonstração.
class DemoCodesPage extends StatelessWidget {
  const DemoCodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Códigos de demonstração')),
      body: PageBody(
        maxWidth: 480,
        children: [
          const Text(
            'Abra esta tela em um aparelho e leia o QR Code com outro.',
          ),
          const SizedBox(height: 12),
          for (final activity in activities)
            Card(
              child: ExpansionTile(
                title: Text(activity.title),
                subtitle: Text(
                  '${formatDayShort(activity.start)} · '
                  '${checkInCode(activity.id)}',
                ),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  QrBox(
                    data: checkInCode(activity.id),
                    label: 'QR Code de ${activity.title}',
                  ),
                  const SizedBox(height: 8),
                  SelectableText(checkInCode(activity.id)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
