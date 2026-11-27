import 'package:material_ui/material_ui.dart';

/// Crachá do participante: faixa com o furo do cordão e os dados abaixo.
class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: colors.primary,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  key: const Key('badge-slot'),
                  width: 56,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: colors.onPrimary),
                    textAlign: TextAlign.center,
                    child: header,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }
}
