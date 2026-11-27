/// Nome e logo do aplicativo, na tela e nos arquivos de instalação.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:eventos_academicos/app.dart';
import 'package:eventos_academicos/core/app_info.dart';
import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/widgets/app_logo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _read(String path) => File(path).readAsStringSync();

/// Devolve o tamanho e a cor de alguns pontos de um PNG.
Future<(int, int, List<List<int>>)> _png(
  String path,
  List<(double, double)> points,
) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  final image = (await codec.getNextFrame()).image;
  final data = (await image.toByteData())!;
  final colors = [
    for (final (x, y) in points)
      () {
        final px = (x * (image.width - 1)).round();
        final py = (y * (image.height - 1)).round();
        final i = (py * image.width + px) * 4;
        return [for (var c = 0; c < 4; c++) data.getUint8(i + c)];
      }(),
  ];
  return (image.width, image.height, colors);
}

const _blue = [0x00, 0x6F, 0xA8, 255];
const _amber = [0xF2, 0xA9, 0x00, 255];
const _white = [255, 255, 255, 255];

void main() {
  test('o aplicativo se chama Presente', () {
    expect(appName, 'Presente');
  });

  test('o nome é o mesmo no navegador, no iPhone e no Android', () {
    final html = _read('web/index.html');
    final manifest =
        jsonDecode(_read('web/manifest.json')) as Map<String, dynamic>;

    expect(html, contains('<title>Presente</title>'));
    expect(
      html,
      contains('name="apple-mobile-web-app-title" content="Presente"'),
    );
    expect(manifest['name'], 'Presente');
    expect(manifest['short_name'], 'Presente');
    expect(
      _read('android/app/src/main/AndroidManifest.xml'),
      contains('android:label="Presente"'),
    );
  });

  final icons = <String, int>{
    'web/favicon.png': 48,
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
    for (final (folder, size) in const [
      ('mdpi', 48),
      ('hdpi', 72),
      ('xhdpi', 96),
      ('xxhdpi', 144),
      ('xxxhdpi', 192),
    ])
      'android/app/src/main/res/mipmap-$folder/ic_launcher.png': size,
  };

  for (final MapEntry(key: path, value: size) in icons.entries) {
    testWidgets('$path traz a logo em ${size}px', (tester) async {
      await tester.runAsync(() async {
        // Canto (fundo), parte de cima do ingresso e canhoto.
        final (w, h, colors) = await _png(path, const [
          (0.02, 0.02),
          (0.34, 0.30),
          (0.34, 0.70),
        ]);

        expect((w, h), (size, size));
        // Fundo cheio: o iPhone pintaria de preto uma área transparente.
        expect(colors[0], _blue);
        expect(colors[1], _white);
        expect(colors[2], _amber);
      });
    });
  }

  for (final size in const [Size(390, 844), Size(1366, 768)]) {
    testWidgets('a entrada mostra a logo e o nome em ${size.width.toInt()}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final state = AppState(await SharedPreferences.getInstance());
      await tester.pumpWidget(EventosApp(state: state));
      await tester.pumpAndSettle();

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text(appName), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
        appName,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a logo se anuncia pelo nome aos leitores de tela', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: AppLogo(size: 64))),
    );

    expect(find.bySemanticsLabel('Logo do $appName'), findsOneWidget);
    expect(tester.getSize(find.byType(AppLogo)), const Size(64, 64));
    handle.dispose();
  });
}
