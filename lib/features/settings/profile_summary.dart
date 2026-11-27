import 'package:material_ui/material_ui.dart';

import '../../models/user_profile.dart';
import '../../widgets/badge_avatar.dart';
import '../../widgets/badge_card.dart';

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
    return BadgeCard(
      header: ProfileBadgeHeader(
        initials: profile.initials,
        name: profile.name,
        email: profile.email,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (:label, :value) in profile.optionalDetails)
            _Detail(label: label, value: value),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }
}

/// Iniciais, nome e e-mail na faixa do crachá.
class ProfileBadgeHeader extends StatelessWidget {
  const ProfileBadgeHeader({
    super.key,
    required this.initials,
    required this.name,
    required this.email,
  });

  final String initials;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        BadgeAvatar(initials: initials, radius: 28),
        const SizedBox(height: 8),
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(email),
      ],
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
