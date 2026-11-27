import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_download.dart';

Future<bool> _openExternally(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (error) {
    debugPrint('Falha ao abrir o download: $error');
    return false;
  }
}

/// Opção de levar o aplicativo para o celular, exibida na versão web.
/// O iPhone não instala APK, por isso recebe o passo a passo do navegador.
class DownloadAppSection extends StatelessWidget {
  const DownloadAppSection({
    super.key,
    this.isWeb = kIsWeb,
    this.platform,
    this.open = _openExternally,
  });

  final bool isWeb;

  /// Quando nulo, usa o sistema informado pelo aparelho.
  final TargetPlatform? platform;
  final Future<bool> Function(Uri) open;

  Future<void> _downloadApk(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await open(apkUrl)) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Não foi possível abrir o download. Acesse $apkUrl'),
      ),
    );
  }

  void _showIphoneSteps(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instalar no iPhone'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Abra este site no Safari.\n'
            '2. Toque no botão Compartilhar.\n'
            '3. Escolha "Adicionar à Tela de Início".\n'
            '4. Confirme em "Adicionar".',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isWeb) return const SizedBox.shrink();
    final isIphone = (platform ?? defaultTargetPlatform) == TargetPlatform.iOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Aplicativo no celular',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          isIphone
              ? 'Adicione o aplicativo à tela de início do seu iPhone.'
              : 'O download é um arquivo APK, para celulares Android. O '
                    'sistema pode pedir permissão para instalar.',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () =>
              isIphone ? _showIphoneSteps(context) : _downloadApk(context),
          icon: const Icon(Icons.download),
          label: const Text('Baixar o aplicativo'),
        ),
        if (!isIphone)
          TextButton(
            onPressed: () => _showIphoneSteps(context),
            child: const Text('Como instalar no iPhone'),
          ),
        const Divider(height: 40),
      ],
    );
  }
}
