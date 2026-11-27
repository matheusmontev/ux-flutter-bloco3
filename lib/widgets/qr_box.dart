import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR Code sempre sobre fundo branco, para a leitura funcionar no tema escuro.
class QrBox extends StatelessWidget {
  const QrBox({
    super.key,
    required this.data,
    required this.label,
    this.size = 200,
  });

  final String data;

  /// Descrição lida por leitores de tela.
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox.square(
          dimension: size,
          child: QrImageView(
            data: data,
            backgroundColor: Colors.white,
            semanticsLabel: label,
          ),
        ),
      ),
    );
  }
}
