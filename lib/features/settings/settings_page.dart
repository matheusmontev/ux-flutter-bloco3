import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/validators.dart';
import '../../models/user_profile.dart';
import '../../widgets/page_body.dart';

/// Configurações da conta: dados do cartão, aparência e saída.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _course = TextEditingController();
  final _institution = TextEditingController();
  final _link = TextEditingController();
  bool _filled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = AppScope.of(context).profile;
    if (_filled || profile == null) return;
    _filled = true;
    _name.text = profile.name;
    _course.text = profile.course;
    _institution.text = profile.institution;
    _link.text = profile.link;
  }

  @override
  void dispose() {
    _name.dispose();
    _course.dispose();
    _institution.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await state.updateProfile(
      UserProfile(
        name: _name.text.trim(),
        email: state.profile!.email,
        course: _course.text.trim(),
        institution: _institution.text.trim(),
        link: _link.text.trim(),
      ),
    );
    messenger.showSnackBar(const SnackBar(content: Text('Dados salvos')));
  }

  Future<void> _signOut() async {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: PageBody(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dados do cartão virtual',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('Conta: ${state.profile?.email ?? ''}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  maxLength: 60,
                  validator: validateName,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _course,
                  decoration: const InputDecoration(
                    labelText: 'Curso ou área (opcional)',
                  ),
                  maxLength: 60,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _institution,
                  decoration: const InputDecoration(
                    labelText: 'Instituição (opcional)',
                  ),
                  maxLength: 60,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _link,
                  decoration: const InputDecoration(
                    labelText: 'Link profissional (opcional)',
                  ),
                  keyboardType: TextInputType.url,
                  maxLength: 120,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Salvar dados'),
                ),
              ],
            ),
          ),
          const Divider(height: 40),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tema escuro'),
            value: state.darkMode,
            onChanged: state.setDarkMode,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }
}
