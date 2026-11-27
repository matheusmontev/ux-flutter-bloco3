import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../auth/auth_page.dart';
import 'home_shell.dart';

/// Decide a primeira tela do aplicativo conforme a sessão.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) =>
      AppScope.of(context).isLogged ? const HomeShell() : const AuthPage();
}
