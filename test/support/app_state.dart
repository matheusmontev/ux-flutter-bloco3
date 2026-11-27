/// Preparação comum dos testes. Mudanças na criação do [AppState] ficam aqui.
library;

import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/data/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Um estado novo, com o armazenamento do aparelho vazio.
Future<AppState> newAppState() async {
  SharedPreferences.setMockInitialValues({});
  return AppState(await SharedPreferences.getInstance(), event: demoEvent);
}
