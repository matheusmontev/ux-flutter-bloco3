import 'package:material_ui/material_ui.dart';

import '../../models/user_profile.dart';

/// Perfil somente para leitura, com o acesso à edição.
class ProfileSummary extends StatelessWidget {
  const ProfileSummary({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(radius: 32, child: Text(profile.initials)),
            ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(profile.email, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _Detail(label: 'Curso ou área', value: profile.course),
            _Detail(label: 'Instituição', value: profile.institution),
            _Detail(label: 'Link profissional', value: profile.link),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(value.isEmpty ? 'Não informado' : value),
          ],
        ),
      ),
    );
  }
}
