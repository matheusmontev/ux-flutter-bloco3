import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/validators.dart';
import '../../models/user_profile.dart';
import '../../widgets/badge_card.dart';
import '../../widgets/page_body.dart';
import 'profile_summary.dart';

/// Edição dos dados do perfil, que também formam o cartão virtual.
/// Devolve `true` ao fechar quando os dados foram salvos.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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
    final navigator = Navigator.of(context);
    await state.updateProfile(
      UserProfile(
        name: _name.text.trim(),
        email: state.profile!.email,
        course: _course.text.trim(),
        institution: _institution.text.trim(),
        link: _link.text.trim(),
      ),
    );
    if (mounted) navigator.pop(true);
  }

  Widget _field(
    String id,
    String label,
    TextEditingController controller, {
    int maxLength = 60,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        key: Key('profile-$id'),
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: PageBody(
        children: [
          // Mostra como o crachá fica antes de salvar.
          ListenableBuilder(
            key: const Key('preview'),
            listenable: _name,
            builder: (context, _) {
              final email = AppScope.of(context).profile?.email ?? '';
              final typed = _name.text.trim();
              return BadgeCard(
                header: ProfileBadgeHeader(
                  initials: UserProfile.initialsOf(typed),
                  name: typed.isEmpty ? 'Seu nome' : typed,
                  email: email,
                ),
                child: const Text(
                  'Estes dados aparecem no seu cartão virtual.',
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field('name', 'Nome completo', _name, validator: validateName),
                _field('course', 'Curso ou área (opcional)', _course),
                _field('institution', 'Instituição (opcional)', _institution),
                _field(
                  'link',
                  'Link profissional (opcional)',
                  _link,
                  maxLength: 120,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _save, child: const Text('Salvar')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
