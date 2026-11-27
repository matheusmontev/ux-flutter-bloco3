import 'package:material_ui/material_ui.dart';

import '../checkin/check_in_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../networking/networking_page.dart';
import '../schedule/schedule_page.dart';
import '../settings/settings_page.dart';
import 'app_tab.dart';

/// Navegação principal: barra inferior no celular, lateral em telas largas.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  AppTab _tab = AppTab.home;

  void _select(AppTab tab) => setState(() => _tab = tab);

  void _selectAt(int index) => _select(AppTab.values[index]);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 840;
    // Em telas de computador o menu mostra os nomes ao lado dos ícones.
    final extended = width >= 1200;
    // As abas que levam a outras abas são criadas aqui.
    final body = switch (_tab) {
      AppTab.home => HomePage(onOpenTab: _select),
      AppTab.schedule => const SchedulePage(),
      AppTab.history => HistoryPage(
        onOpenSchedule: () => _select(AppTab.schedule),
      ),
      AppTab.networking => const NetworkingPage(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_tab.label),
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
      // No início, o próprio ingresso já traz o check-in.
      floatingActionButton: _tab.showsCheckInButton
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
                  selectedIndex: _tab.index,
                  onDestinationSelected: _selectAt,
                  extended: extended,
                  labelType: extended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: [
                    for (final d in AppTab.values)
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
              selectedIndex: _tab.index,
              onDestinationSelected: _selectAt,
              destinations: [
                for (final d in AppTab.values)
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
