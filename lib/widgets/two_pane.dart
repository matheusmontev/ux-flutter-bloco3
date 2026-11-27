import 'package:material_ui/material_ui.dart';

import 'page_body.dart';

/// Duas colunas em telas de computador. Em telas estreitas, o conteúdo de
/// [side] vem primeiro e o de [main] logo abaixo, em uma única lista.
class TwoPane extends StatelessWidget {
  const TwoPane({
    super.key,
    required this.side,
    required this.main,
    this.sideWidth = 380,
  });

  /// Largura disponível a partir da qual as colunas aparecem lado a lado.
  static const breakpoint = 900.0;
  static const maxWidth = 1200.0;

  /// Diz se há largura para duas colunas. Quem precisa adaptar o conteúdo ao
  /// layout deve passar as mesmas restrições que o [TwoPane] recebe.
  static bool isWide(BoxConstraints constraints) =>
      constraints.maxWidth >= breakpoint;

  final List<Widget> side;
  final List<Widget> main;
  final double sideWidth;

  Widget _column(List<Widget> children) => ListView(
    // Cada coluna tem a própria rolagem.
    primary: false,
    padding: const EdgeInsets.only(top: 24, bottom: 96),
    children: children,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isWide(constraints)) {
          return PageBody(children: [...side, ...main]);
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(
              key: const Key('two-pane'),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: sideWidth, child: _column(side)),
                    const SizedBox(width: 32),
                    Expanded(child: _column(main)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
