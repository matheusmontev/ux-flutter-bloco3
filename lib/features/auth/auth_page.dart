import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/validators.dart';
import '../../data/mock_data.dart';
import '../../widgets/page_body.dart';
import '../../widgets/two_pane.dart';

/// Entrada e cadastro do participante.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    AppScope.of(context)
        .signIn(email: _email.text, name: _registering ? _name.text : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < TwoPane.breakpoint) {
            return SafeArea(
              child: PageBody(
                maxWidth: 420,
                children: [
                  const SizedBox(height: 24),
                  const _Header(),
                  const SizedBox(height: 24),
                  ..._formContent(context),
                ],
              ),
            );
          }
          // No computador, o evento ocupa um painel ao lado do formulário.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: _BrandPanel()),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 468),
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(24),
                      children: _formContent(context),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _formContent(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_registering) ...[
                TextFormField(
                  key: const Key('name'),
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: validateName,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const Key('email'),
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('password'),
                controller: _password,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    tooltip: _hidePassword ? 'Mostrar senha' : 'Ocultar senha',
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                onFieldSubmitted: (_) => _submit(),
                validator: validatePassword,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(_registering ? 'Criar conta' : 'Entrar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _registering = !_registering),
                child: Text(
                  _registering ? 'Já tenho conta' : 'Criar uma conta',
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Protótipo: o acesso é simulado, os dados ficam só neste '
        'aparelho e a senha não é armazenada.',
        style: theme.textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({this.color});

  /// Cor do texto e do ícone quando o cabeçalho fica sobre o painel.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.confirmation_number_outlined,
          size: 64,
          color: color ?? theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          eventName,
          style: theme.textTheme.headlineSmall?.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Programação, check-in, certificados e networking.',
          style: TextStyle(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      key: const Key('auth-brand'),
      color: colors.primary,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: _Header(color: colors.onPrimary),
        ),
      ),
    );
  }
}
