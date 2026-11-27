/// Confere a configuração que a Vercel usa para publicar o aplicativo.
library;

import 'dart:convert';
import 'dart:io';

import 'package:eventos_academicos/core/app_download.dart';
import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

String _flutterVersion(String text, RegExp pattern) =>
    pattern.firstMatch(text)!.group(1)!;

void main() {
  test('a Vercel executa o script e publica a pasta do build web', () {
    final config = jsonDecode(_read('vercel.json')) as Map<String, dynamic>;

    expect(config['buildCommand'], 'bash tool/vercel_build.sh');
    expect(config['outputDirectory'], 'build/web');
    expect(config['framework'], isNull);
    expect(config['installCommand'], '');
  });

  test('a publicação usa a mesma versão do Flutter da verificação', () {
    final script = _flutterVersion(
      _read('tool/vercel_build.sh'),
      RegExp(r'FLUTTER_VERSION="([\d.]+)"'),
    );
    final ci = _flutterVersion(
      _read('.github/workflows/ci.yml'),
      RegExp(r'flutter-version: ([\d.]+)'),
    );

    expect(script, ci);
  });

  test('o APK e o guia usam a mesma versão do Flutter da verificação', () {
    final ci = _flutterVersion(
      _read('.github/workflows/ci.yml'),
      RegExp(r'flutter-version: ([\d.]+)'),
    );

    expect(
      _flutterVersion(
        _read('.github/workflows/android.yml'),
        RegExp(r'flutter-version: ([\d.]+)'),
      ),
      ci,
    );
    expect(
      _flutterVersion(
        _read('docs/GUIA.md'),
        RegExp(r'Flutter \(canal stable\) \| ([\d.]+)'),
      ),
      ci,
    );
  });

  test('o app e o README baixam o arquivo que o workflow publica', () {
    final name = apkUrl.pathSegments.last;
    final workflow = _read('.github/workflows/android.yml');

    // Cópia do build, artefato enviado e arquivo anexado à release.
    expect(workflow, matches('app-release\\.apk $name\\s'));
    expect(workflow, matches('path: $name\\s'));
    expect(workflow, contains('gh release create "\$tag" $name '));
    expect(_read('README.md'), contains(apkUrl.toString()));
  });

  test('os testes rodam antes do build e uma falha interrompe', () {
    final script = _read('tool/vercel_build.sh');

    expect(script, contains('set -euo pipefail'));
    expect(script.indexOf('flutter test'), greaterThan(0));
    expect(
      script.indexOf('flutter test'),
      lessThan(script.indexOf('flutter build web --release')),
    );
  });

  test('o script usa fim de linha do Linux', () {
    expect(_read('.gitattributes'), contains('*.sh text eol=lf'));
    expect(_read('tool/vercel_build.sh'), isNot(contains('\r')));
  });
}
