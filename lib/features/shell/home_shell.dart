import 'package:material_ui/material_ui.dart';

import '../../widgets/empty_state.dart';

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
  _Destination('Início', Icons.home_outlined, Icons.home, _pending),
  _Destination(
    'Programação',
    Icons.event_note_outlined,
    Icons.event_note,
    _pending,
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
    final body = _destinations[_index].page;

    return Scaffold(
      appBar: AppBar(title: Text(_destinations[_index].label)),
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
