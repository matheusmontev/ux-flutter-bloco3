import 'package:material_ui/material_ui.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'features/shell/auth_gate.dart';

class EventosApp extends StatelessWidget {
  const EventosApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'Eventos Acadêmicos',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthGate(),
        ),
      ),
    );
  }
}
