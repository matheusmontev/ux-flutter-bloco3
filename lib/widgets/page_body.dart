import 'package:material_ui/material_ui.dart';

/// Lista rolável centralizada, com largura máxima para telas grandes.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = 720});

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final extra = (constraints.maxWidth - maxWidth) / 2;
        final side = extra > 16 ? extra : 16.0;
        return ListView(
          padding: EdgeInsets.fromLTRB(side, 16, side, 32),
          children: children,
        );
      },
    );
  }
}
