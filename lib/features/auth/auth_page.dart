import 'package:material_ui/material_ui.dart';

import '../../core/app_info.dart';
import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../core/schedule_filter.dart';
import '../../core/validators.dart';
import '../../widgets/app_logo.dart';
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
          if (!TwoPane.isWide(constraints)) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const _EventBand(),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 452),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _formContent(context),
                      ),
                    ),
                  ),
                ),
              ],
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

/// Nome, datas e local do evento sobre a cor principal.
class _EventTitle extends StatelessWidget {
  const _EventTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimary;
    final event = AppScope.of(context).event;
    return DefaultTextStyle.merge(
      style: TextStyle(color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // O contorno separa a logo do fundo, que tem a mesma cor.
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: AppLogo(size: 52),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formatPeriodLong(event.firstDay, event.lastDay),
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
          Text(event.place),
        ],
      ),
    );
  }
}

class _EventBand extends StatelessWidget {
  const _EventBand();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('auth-event'),
      color: Theme.of(context).colorScheme.primary,
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: _EventTitle(),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimary;
    return ColoredBox(
      key: const Key('auth-brand'),
      color: theme.colorScheme.primary,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _EventTitle(),
                const SizedBox(height: 32),
                for (final MapEntry(key: day, value: items) in groupByDay(
                  AppScope.of(context).event.activities,
                ).entries) ...[
                  Divider(color: color.withValues(alpha: 0.35)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDayLong(day),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${items.length} atividades, a partir das '
                          '${formatTime(items.first.start)}',
                          style: TextStyle(color: color),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
