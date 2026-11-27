import 'package:material_ui/material_ui.dart';

import '../core/app_info.dart';
import '../core/theme.dart';

/// Logo do aplicativo: um ingresso com o sinal de presença confirmada.
/// A geometria é a mesma de `tool/gerar_icones.py`, que gera os ícones.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo do $appName',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: const CustomPaint(painter: _LogoPainter()),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width, size.height);
    const ticket = Rect.fromLTRB(0.22, 0.16, 0.78, 0.84);
    const tear = 0.62;
    const notch = 0.055;
    final blue = Paint()..color = brandBlue;

    canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), blue);

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(ticket, const Radius.circular(0.07)),
    );
    canvas.drawRect(ticket, Paint()..color = Colors.white);
    canvas.drawRect(
      const Rect.fromLTRB(0, tear, 1, 1),
      Paint()..color = brandAmber,
    );
    canvas.restore();

    for (final x in [ticket.left, ticket.right]) {
      canvas.drawCircle(Offset(x, tear), notch, blue);
    }
    for (
      var x = ticket.left + notch + 0.025;
      x + 0.035 <= ticket.right - notch;
      x += 0.065
    ) {
      canvas.drawRect(Rect.fromLTWH(x, tear - 0.008, 0.035, 0.016), blue);
    }

    canvas.drawPath(
      Path()
        ..moveTo(0.37, 0.39)
        ..lineTo(0.47, 0.49)
        ..lineTo(0.65, 0.29),
      Paint()
        ..color = brandBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.075
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
