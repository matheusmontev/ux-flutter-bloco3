import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../widgets/empty_state.dart';

/// Abre a câmera e devolve o texto do primeiro QR Code lido.
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done || !mounted) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        _done = true;
        Navigator.pop(context, value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ler QR Code')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: SingleChildScrollView(
                    child: EmptyState(
                      icon: Icons.no_photography_outlined,
                      title: 'Câmera indisponível',
                      message:
                          error.errorCode ==
                              MobileScannerErrorCode.permissionDenied
                          ? 'Libere o acesso à câmera nas permissões ou '
                                'digite o código.'
                          : 'Não foi possível abrir a câmera neste '
                                'aparelho. Digite o código.',
                      action: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Voltar e digitar'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aponte a câmera para o QR Code.'),
            ),
          ),
        ],
      ),
    );
  }
}
