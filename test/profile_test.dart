import 'package:eventos_academicos/core/app_state.dart';
import 'package:eventos_academicos/features/settings/edit_profile_page.dart';
import 'package:eventos_academicos/features/settings/settings_page.dart';
import 'package:eventos_academicos/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _openSettings(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final state = AppState(await SharedPreferences.getInstance());
  await state.signIn(email: 'ana@exemplo.com', name: 'Ana Lima');
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: const MaterialApp(home: SettingsPage()),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openEditor(WidgetTester tester) =>
    _tap(tester, find.text('Editar perfil'));

Finder _field(String key) => find.byKey(Key('profile-$key'));

void main() {
  group('Configurações', () {
    testWidgets('abre mostrando o perfil, sem campos de edição', (
      tester,
    ) async {
      await _openSettings(tester);

      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Salvar'), findsNothing);
      expect(find.text('Ana Lima'), findsOneWidget);
      expect(find.text('ana@exemplo.com'), findsOneWidget);
      expect(find.text('AL'), findsOneWidget);
      expect(find.text('Editar perfil'), findsOneWidget);
    });

    testWidgets('indica os dados que ainda não foram preenchidos', (
      tester,
    ) async {
      await _openSettings(tester);

      for (final label in [
        'Curso ou área',
        'Instituição',
        'Link profissional',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('Não informado'), findsNWidgets(3));
    });
  });

  group('Edição do perfil', () {
    testWidgets('o botão abre a página com os dados atuais', (tester) async {
      await _openSettings(tester);
      await _openEditor(tester);

      expect(find.byType(EditProfilePage), findsOneWidget);
      expect(
        find.descendant(of: _field('name'), matching: find.text('Ana Lima')),
        findsOneWidget,
      );
    });

    testWidgets('salvar grava, volta e atualiza o perfil', (tester) async {
      final state = await _openSettings(tester);
      await _openEditor(tester);

      await tester.enterText(_field('name'), '  Ana Souza  ');
      await tester.enterText(_field('course'), 'Sistemas de Informação');
      await _tap(tester, find.widgetWithText(FilledButton, 'Salvar'));

      expect(find.byType(EditProfilePage), findsNothing);
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('Sistemas de Informação'), findsOneWidget);
      expect(find.text('Não informado'), findsNWidgets(2));
      expect(find.text('Perfil salvo'), findsOneWidget);
      expect(state.profile?.name, 'Ana Souza');
      expect(state.profile?.email, 'ana@exemplo.com');
    });

    testWidgets('cancelar descarta o que foi digitado', (tester) async {
      final state = await _openSettings(tester);
      await _openEditor(tester);

      await tester.enterText(_field('name'), 'Outro Nome');
      await _tap(tester, find.text('Cancelar'));

      expect(find.byType(EditProfilePage), findsNothing);
      expect(find.text('Ana Lima'), findsOneWidget);
      expect(state.profile?.name, 'Ana Lima');
    });

    testWidgets('nome inválido mostra erro e não salva', (tester) async {
      final state = await _openSettings(tester);
      await _openEditor(tester);

      await tester.enterText(_field('name'), 'A');
      await _tap(tester, find.widgetWithText(FilledButton, 'Salvar'));

      expect(find.text('Informe seu nome completo'), findsOneWidget);
      expect(find.byType(EditProfilePage), findsOneWidget);
      expect(state.profile?.name, 'Ana Lima');
    });

    testWidgets('dados longos cabem em 320 px', (tester) async {
      final state = await _openSettings(tester, size: const Size(320, 640));
      await state.updateProfile(
        const UserProfile(
          name: 'Ana Carolina de Albuquerque Vasconcelos Lima',
          email: 'ana@exemplo.com',
          course: 'Análise e Desenvolvimento de Sistemas para Dispositivos',
          link: 'https://exemplo.com/um/endereco/profissional/bem/comprido',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await _openEditor(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
