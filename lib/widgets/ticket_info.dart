/// Horário e sala em destaque, como aparecem no corpo de um ingresso.
library;

import 'package:material_ui/material_ui.dart';

import '../core/formatters.dart';

class TicketTime extends StatelessWidget {
  const TicketTime(this.start, {super.key});

  final DateTime start;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      formatTime(start),
      style: theme.textTheme.displayMedium?.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class TicketPlace extends StatelessWidget {
  const TicketPlace(this.room, {super.key});

  final String room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onPrimaryContainer;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(Icons.place, size: 22, color: ink),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            room,
            style: theme.textTheme.titleLarge?.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
