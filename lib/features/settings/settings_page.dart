import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../widgets/download_app_section.dart';
import '../../widgets/two_pane.dart';
import 'edit_profile_page.dart';
import 'profile_summary.dart';

/// Configurações da conta: perfil, aparência, aplicativo e saída.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _editProfile(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
    if (saved == true) {
      messenger.showSnackBar(const SnackBar(content: Text('Perfil salvo')));
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Seus dados continuam neste aparelho. Ao entrar com outro '
          'e-mail, presenças e contatos serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    navigator.popUntil((route) => route.isFirst);
    await state.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final profile = state.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: LayoutBuilder(
        builder: (_, constraints) => TwoPane(
          sideWidth: 420,
          side: [
            if (profile != null)
              ProfileSummary(
                profile: profile,
                onEdit: () => _editProfile(context),
              ),
          ],
          main: [
            // No celular, separa o perfil das preferências.
            if (!TwoPane.isWide(constraints)) const Divider(height: 40),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tema escuro'),
              value: state.darkMode,
              onChanged: state.setDarkMode,
            ),
            const Divider(height: 40),
            const DownloadAppSection(),
            Text('Conta', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
            ),
          ],
        ),
      ),
    );
  }
}
