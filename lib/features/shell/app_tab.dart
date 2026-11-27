import 'package:material_ui/material_ui.dart';

/// Abas da navegação principal, na ordem em que aparecem no menu.
enum AppTab {
  home('Início', Icons.home_outlined, Icons.home),
  schedule(
    'Programação',
    Icons.event_note_outlined,
    Icons.event_note,
    showsCheckInButton: true,
  ),
  history('Presenças', Icons.verified_outlined, Icons.verified),
  networking('Networking', Icons.people_outline, Icons.people);

  const AppTab(
    this.label,
    this.icon,
    this.selectedIcon, {
    this.showsCheckInButton = false,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool showsCheckInButton;
}
