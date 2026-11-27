/// Confere a configuração que a Vercel usa para publicar o aplicativo.
library;

import 'dart:convert';
import 'dart:io';

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
