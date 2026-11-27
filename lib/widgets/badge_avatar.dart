import 'package:material_ui/material_ui.dart';

/// Iniciais sobre a faixa do crachá, com as cores dela invertidas.
class BadgeAvatar extends StatelessWidget {
  const BadgeAvatar({super.key, required this.initials, required this.radius});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.onPrimary,
      foregroundColor: colors.primary,
      child: Text(
        initials,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
