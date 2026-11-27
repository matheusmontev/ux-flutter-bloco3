import 'dart:io';

import 'package:eventos_academicos/core/app_download.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/features/settings/settings_page.dart';
import 'package:eventos_academicos/widgets/download_app_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _download = 'Baixar o aplicativo';
const _iphone = 'Como instalar no iPhone';

Future<List<Uri>> _pump(
  WidgetTester tester, {
  required TargetPlatform platform,
  bool isWeb = true,
  bool opens = true,
}) async {
  final opened = <Uri>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DownloadAppSection(
          isWeb: isWeb,
          platform: platform,
          open: (uri) async {
            opened.add(uri);
            return opens;
          },
        ),
      ),
    ),
  );
  return opened;
}

void main() {
  test('o link aponta para o APK da versão mais recente', () {
    expect(
      apkUrl.toString(),
      'https://github.com/matheusmontev/ux-flutter-bloco3/releases/latest/'
      'download/eventos-academicos.apk',
    );
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets('em ${platform.name} o botão baixa o APK', (tester) async {
      final opened = await _pump(tester, platform: platform);

      await tester.tap(find.widgetWithText(FilledButton, _download));
      await tester.pumpAndSettle();

      expect(opened, [apkUrl]);
      expect(find.textContaining('Android'), findsWidgets);
    });
  }

  testWidgets('no iPhone o botão ensina a instalar, sem baixar APK', (
    tester,
  ) async {
    final opened = await _pump(tester, platform: TargetPlatform.iOS);

    await tester.tap(find.widgetWithText(FilledButton, _download));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.textContaining('Safari'), findsOneWidget);
    expect(find.textContaining('Tela de Início'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('quem está no computador também vê o caminho do iPhone', (
    tester,
  ) async {
    await _pump(tester, platform: TargetPlatform.windows);

    await tester.tap(find.text(_iphone));
    await tester.pumpAndSettle();

    expect(find.textContaining('Safari'), findsOneWidget);
  });

  testWidgets('se o download não abrir, mostra o endereço', (tester) async {
    await _pump(tester, platform: TargetPlatform.android, opens: false);

    await tester.tap(find.widgetWithText(FilledButton, _download));
    await tester.pumpAndSettle();

    expect(find.textContaining(apkUrl.toString()), findsOneWidget);
  });

  testWidgets('no aplicativo já instalado a seção não aparece', (tester) async {
    await _pump(tester, platform: TargetPlatform.android, isWeb: false);

    expect(find.text(_download), findsNothing);
  });

  testWidgets('a seção está na tela de configurações', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await SharedPreferences.getInstance());
    await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    await tester.scrollUntilVisible(
      find.byType(DownloadAppSection, skipOffstage: false),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byType(DownloadAppSection, skipOffstage: false),
      findsOneWidget,
    );
  });

  group('Geração do APK no GitHub', () {
    String workflow() =>
        File('.github/workflows/android.yml').readAsStringSync();

    test('gera o APK e publica com o nome usado no link', () {
      expect(workflow(), contains('flutter build apk --release'));
      expect(workflow(), contains(apkUrl.pathSegments.last));
      expect(workflow(), contains('--latest'));
    });

    test('só publica em envios para a main e com permissão restrita', () {
      expect(
        workflow(),
        contains(
          "if: github.event_name == 'push' && github.ref == 'refs/heads/main'",
        ),
      );
      expect(workflow(), contains('contents: read'));
      expect('contents: write'.allMatches(workflow()), hasLength(1));
    });

    test('usa a mesma versão do Flutter da verificação', () {
      final version = RegExp(r'flutter-version: ([\d.]+)');
      final ci = File('.github/workflows/ci.yml').readAsStringSync();

      expect(
        version.firstMatch(workflow())!.group(1),
        version.firstMatch(ci)!.group(1),
      );
    });
  });
}
