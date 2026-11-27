import 'package:material_ui/material_ui.dart';

import '../../core/app_state.dart';
import '../../core/formatters.dart';
import '../../core/schedule_filter.dart';
import '../../data/mock_data.dart';
import '../../models/activity.dart';
import '../../widgets/agenda_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/two_pane.dart';
import 'activity_detail_page.dart';

/// Programação com filtros por dia, turno, tema e busca.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _search = TextEditingController();
  DateTime? _day;
  Shift? _period;
  String? _theme;

  /// No celular, turno e tema só aparecem quando pedidos.
  bool _showFilters = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _search.clear();
    _day = null;
    _period = null;
    _theme = null;
  });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final filter = ScheduleFilter(
      day: _day,
      period: _period,
      theme: _theme,
      query: _search.text,
    );
    final results = filter.apply(activities);
    final days = {for (final a in activities) a.day}.toList()..sort();
    final themes = {for (final a in activities) a.theme}.toList()..sort();

    final compact = MediaQuery.sizeOf(context).width < TwoPane.breakpoint;
    final extra = (_period == null ? 0 : 1) + (_theme == null ? 0 : 1);

    return TwoPane(
      sideWidth: 360,
      side: [
        TextField(
          key: const Key('search'),
          controller: _search,
          decoration: const InputDecoration(
            labelText: 'Buscar atividade, palestrante ou sala',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        if (compact)
          // Os dias ficam em uma linha, para a agenda aparecer logo.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final day in days)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(formatDayShort(day)),
                      selected: _day == day,
                      onSelected: (value) =>
                          setState(() => _day = value ? day : null),
                    ),
                  ),
              ],
            ),
          )
        else
          _FilterRow<DateTime>(
            title: 'Dia',
            options: days,
            selected: _day,
            label: formatDayShort,
            onChanged: (value) => setState(() => _day = value),
          ),
        if (!compact || _showFilters) ...[
          _FilterRow<Shift>(
            title: 'Turno',
            options: Shift.values,
            selected: _period,
            label: (period) => period.label,
            onChanged: (value) => setState(() => _period = value),
          ),
          _FilterRow<String>(
            title: 'Tema',
            options: themes,
            selected: _theme,
            label: (theme) => theme,
            onChanged: (value) => setState(() => _theme = value),
          ),
        ],
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (compact)
              TextButton.icon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(_showFilters ? Icons.expand_less : Icons.tune),
                label: Text(extra == 0 ? 'Filtros' : 'Filtros ($extra)'),
              ),
            Semantics(
              liveRegion: true,
              child: Text(
                results.length == 1
                    ? '1 atividade'
                    : '${results.length} atividades',
              ),
            ),
            if (!filter.isEmpty)
              TextButton(
                onPressed: _clear,
                child: const Text('Limpar filtros'),
              ),
          ],
        ),
      ],
      main: [
        if (results.isEmpty)
          EmptyState(
            icon: Icons.event_busy,
            title: 'Nenhuma atividade encontrada',
            message: 'Ajuste a busca ou os filtros.',
            action: FilledButton(
              onPressed: _clear,
              child: const Text('Ver todas'),
            ),
          )
        else
          for (final MapEntry(key: day, value: items) in groupByDay(
            results,
          ).entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 4),
              child: Semantics(
                header: true,
                child: Text(
                  formatDayLong(day),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const Divider(),
            for (final activity in items)
              AgendaItem(
                key: ValueKey('agenda-${activity.id}'),
                activity: activity,
                attended: state.hasAttended(activity.id),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ActivityDetailPage(activity: activity),
                  ),
                ),
              ),
          ],
      ],
    );
  }
}

/// Linha de filtro de escolha única; tocar de novo desmarca.
class _FilterRow<T> extends StatelessWidget {
  const _FilterRow({
    required this.title,
    required this.options,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.textScalerOf(context).scale(52),
            child: Text(title),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final option in options)
                  FilterChip(
                    label: Text(label(option)),
                    selected: selected == option,
                    onSelected: (value) => onChanged(value ? option : null),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
