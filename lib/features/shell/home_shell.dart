import 'package:material_ui/material_ui.dart';

import '../../widgets/empty_state.dart';
import '../checkin/check_in_page.dart';
import '../home/home_page.dart';
import '../schedule/schedule_page.dart';
import '../settings/settings_page.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon, this.page);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

const _pending = EmptyState(
  icon: Icons.construction,
  title: 'Em construção',
  message: 'Esta área ainda será implementada.',
);

const _destinations = [
  _Destination('Início', Icons.home_outlined, Icons.home, SizedBox()),
  _Destination(
    'Programação',
    Icons.event_note_outlined,
    Icons.event_note,
    SchedulePage(),
  ),
  _Destination('Presenças', Icons.verified_outlined, Icons.verified, _pending),
  _Destination('Networking', Icons.people_outline, Icons.people, _pending),
];

/// Navegação principal: barra inferior no celular, lateral em telas largas.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    // A aba inicial precisa trocar de aba, por isso é criada aqui.
    final body = _index == 0
        ? HomePage(onOpenTab: _select)
        : _destinations[_index].page;

    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_index].label),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      floatingActionButton: _index <= 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const CheckInPage()),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Check-in'),
            )
          : null,
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
    );
  }
}
