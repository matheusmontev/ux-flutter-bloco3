import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/codes.dart';
import '../../models/activity.dart';
import '../../widgets/page_body.dart';
import 'demo_codes_page.dart';
import 'scanner_page.dart';

/// Registro de presença por câmera ou código digitado.
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key, this.activity});

  /// Quando informada, só o código desta atividade é aceito.
  final Activity? activity;

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _code = TextEditingController();
  CheckInResult? _result;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _register(String raw) async {
    final result = await AppScope.of(context)
        .checkIn(raw, expectedId: widget.activity?.id);
    if (!mounted) return;
    setState(() => _result = result);
    if (result.status == CheckInStatus.success) _code.clear();
  }

  Future<void> _scan() async {
    final value = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );
    if (value != null && mounted) await _register(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activity = widget.activity;
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: PageBody(
        maxWidth: 480,
        children: [
          Text(
            activity?.title ?? 'Registre sua presença',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Leia o QR Code exibido na sala ou digite o código.'),
          const SizedBox(height: 24),
          if (result != null) ...[
            _ResultCard(result: result),
            const SizedBox(height: 24),
          ],
          FilledButton.icon(
            onPressed: _scan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Ler com a câmera'),
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('checkin-code'),
            controller: _code,
            decoration: const InputDecoration(
              labelText: 'Código da atividade',
              hintText: 'EVENTO:a01',
            ),
            autocorrect: false,
            onSubmitted: _register,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _register(_code.text),
            child: const Text('Confirmar código'),
          ),
          const Divider(height: 48),
          Text('Modo demonstração', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Recursos para apresentar o protótipo sem os cartazes do evento.',
          ),
          const SizedBox(height: 12),
          if (activity != null)
            TextButton.icon(
              onPressed: () => _register(checkInCode(activity.id)),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Simular leitura do QR Code'),
            ),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const DemoCodesPage()),
            ),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Ver códigos de demonstração'),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final CheckInResult result;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = result.activity?.title ?? '';
    final (icon, heading, message) = switch (result.status) {
      CheckInStatus.success => (
        Icons.check_circle,
        'Presença registrada',
        '$title. O certificado já está disponível em Presenças.',
      ),
      CheckInStatus.alreadyDone => (
        Icons.info,
        'Check-in já realizado',
        'Sua presença em "$title" já estava registrada.',
      ),
      CheckInStatus.otherActivity => (
        Icons.warning_amber,
        'Código de outra atividade',
        'Este código é de "$title".',
      ),
      CheckInStatus.invalidCode => (
        Icons.error,
        'Código inválido',
        'Confira o código e tente novamente.',
      ),
    };
    final ok = result.status == CheckInStatus.success;
    final background = ok ? colors.primaryContainer : colors.errorContainer;
    final foreground = ok ? colors.onPrimaryContainer : colors.onErrorContainer;

    return Semantics(
      liveRegion: true,
      child: Card(
        color: background,
        child: ListTile(
          leading: Icon(icon, color: foreground),
          title: Text(heading, style: TextStyle(color: foreground)),
          subtitle: Text(message, style: TextStyle(color: foreground)),
        ),
      ),
    );
  }
}
