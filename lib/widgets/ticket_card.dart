import 'package:material_ui/material_ui.dart';

const _radius = 16.0;
const _notch = 10.0;

/// Recorta o contorno do ingresso: cantos arredondados e um entalhe de cada
/// lado, na altura do picote.
class TicketClipper extends CustomClipper<Path> {
  const TicketClipper({required this.notchFromBottom});

  final double notchFromBottom;

  @override
  Path getClip(Size size) {
    final y = size.height - notchFromBottom;
    final card = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );
    final holes = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: _notch))
      ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: _notch));
    return Path.combine(PathOperation.difference, card, holes);
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) =>
      oldClipper.notchFromBottom != notchFromBottom;
}

/// Ingresso: o corpo traz a informação e o canhoto traz a ação.
class TicketCard extends StatefulWidget {
  const TicketCard({
    super.key,
    required this.body,
    required this.stub,
    this.onTap,
  });

  final Widget body;
  final Widget stub;

  /// Ação ao tocar no corpo.
  final VoidCallback? onTap;

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  final _stubKey = GlobalKey();
  double _stubHeight = 72;

  /// O picote acompanha a altura real do canhoto.
  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _stubKey.currentContext?.findRenderObject() as RenderBox?;
      if (!mounted || box == null) return;
      if ((box.size.height - _stubHeight).abs() > 0.5) {
        setState(() => _stubHeight = box.size.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _measure();
    final colors = Theme.of(context).colorScheme;
    return PhysicalShape(
      clipper: TicketClipper(notchFromBottom: _stubHeight + 1),
      clipBehavior: Clip.antiAlias,
      color: colors.primaryContainer,
      elevation: 1,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onPrimaryContainer),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: widget.body,
                ),
              ),
              SizedBox(
                key: const Key('ticket-tear'),
                height: 2,
                child: CustomPaint(
                  painter: _TearPainter(colors.onPrimaryContainer),
                ),
              ),
              Padding(
                key: _stubKey,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: widget.stub,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha tracejada do picote.
class _TearPainter extends CustomPainter {
  const _TearPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (var x = _notch + 4; x < size.width - _notch - 4; x += 10) {
      canvas.drawLine(Offset(x, 1), Offset(x + 5, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_TearPainter oldDelegate) => oldDelegate.color != color;
}
