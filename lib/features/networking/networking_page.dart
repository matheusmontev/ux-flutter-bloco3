import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/codes.dart';
import '../../data/mock_data.dart';
import '../../models/user_profile.dart';
import '../../widgets/badge_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/qr_box.dart';
import '../../widgets/two_pane.dart';
import '../checkin/scanner_page.dart';

/// Cartão virtual do participante e contatos recebidos.
class NetworkingPage extends StatelessWidget {
  const NetworkingPage({super.key});

  Future<void> _add(BuildContext context, String raw) async {
    final messenger = ScaffoldMessenger.of(context);
    final status = await AppScope.of(context).addContact(raw);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (status) {
          AddContactStatus.success => 'Contato adicionado',
          AddContactStatus.invalidCode => 'Código de cartão inválido',
          AddContactStatus.ownCard => 'Este é o seu próprio cartão',
          AddContactStatus.alreadyAdded => 'Esse contato já está na lista',
        }),
      ),
    );
  }

  Future<void> _scan(BuildContext context) async {
    final value = await ScannerPage.read(context);
    if (value != null && context.mounted) await _add(context, value);
  }

  Future<void> _paste(BuildContext context) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const _PasteDialog(),
    );
    if (value != null && context.mounted) await _add(context, value);
  }

  Future<void> _share(BuildContext context, UserProfile profile) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: cardCode(profile)));
    messenger.showSnackBar(
      const SnackBar(content: Text('Código do cartão copiado')),
    );
  }

  Future<void> _remove(BuildContext context, UserProfile contact) async {
    final state = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover contato?'),
        content: Text('${contact.name} sairá da sua lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true) await state.removeContact(contact.email);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final profile = state.sessionProfile;

    return TwoPane(
      sideWidth: 400,
      side: [
        BadgeCard(
          header: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.onPrimary,
                foregroundColor: theme.colorScheme.primary,
                child: Text(
                  profile.initials,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              for (final line in _details(profile)) Text(line),
            ],
          ),
          child: Column(
            children: [
              QrBox(
                data: cardCode(profile),
                label: 'QR Code do seu cartão virtual',
                size: 190,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _share(context, profile),
                icon: const Icon(Icons.copy),
                label: const Text('Copiar código do cartão'),
              ),
              Text(
                'Quem lê o cartão recebe os dados acima.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      main: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const Key('ler-cartao'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
                foregroundColor: theme.colorScheme.onTertiary,
              ),
              onPressed: () => _scan(context),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Ler cartão'),
            ),
            OutlinedButton.icon(
              onPressed: () => _paste(context),
              icon: const Icon(Icons.paste),
              label: const Text('Colar código'),
            ),
            TextButton(
              onPressed: () => _add(context, cardCode(sampleContact)),
              child: const Text('Adicionar contato de exemplo'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Meus contatos', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (state.contacts.isEmpty)
          const EmptyState(
            icon: Icons.people_outline,
            title: 'Nenhum contato ainda',
            message: 'Leia o cartão de outro participante para começar.',
          )
        else
          for (final contact in state.contacts)
            DecoratedBox(
              key: ValueKey('contato-${contact.email}'),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(child: Text(contact.initials)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          for (final line in _details(contact))
                            Text(
                              line,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remover ${contact.name}',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _remove(context, contact),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  static List<String> _details(UserProfile profile) => [
    profile.email,
    if (profile.course.isNotEmpty) profile.course,
    if (profile.institution.isNotEmpty) profile.institution,
    if (profile.link.isNotEmpty) profile.link,
  ];
}

class _PasteDialog extends StatefulWidget {
  const _PasteDialog();

  @override
  State<_PasteDialog> createState() => _PasteDialogState();
}

class _PasteDialogState extends State<_PasteDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Colar código do cartão'),
      content: TextField(
        controller: _code,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Código'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _code.text),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
