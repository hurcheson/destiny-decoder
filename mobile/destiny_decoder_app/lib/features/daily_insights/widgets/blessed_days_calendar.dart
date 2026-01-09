import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class BlessedDaysCalendar extends ConsumerStatefulWidget {
  final int dayOfBirth;
  final DateTime initialMonth;
  final void Function(DateTime selectedDate)? onSelectDate;

  const BlessedDaysCalendar({
    super.key,
    required this.dayOfBirth,
    required this.initialMonth,
    this.onSelectDate,
  });

  @override
  ConsumerState<BlessedDaysCalendar> createState() => _BlessedDaysCalendarState();
}

class _BlessedDaysCalendarState extends ConsumerState<BlessedDaysCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  String _fmtMonth(DateTime d) {
    return "${_monthName(d.month)} ${d.year}";
  }

  String _monthName(int m) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      blessedDaysProvider(
        BlessedDaysParams(
          dayOfBirth: widget.dayOfBirth,
          month: _currentMonth.month,
          year: _currentMonth.year,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              _fmtMonth(_currentMonth),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        async.when(
          data: (data) {
            final blessed = data.blessedDates.toSet();

            final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
            final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
            final startWeekday = firstDay.weekday % 7; // make Sunday=0
            final totalCells = startWeekday + daysInMonth;
            final rows = (totalCells / 7).ceil();

            return Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows * 7,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final dayNum = index - startWeekday + 1;
                    if (dayNum < 1 || dayNum > daysInMonth) {
                      return const SizedBox.shrink();
                    }
                    final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                    final iso = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}";
                    final isBlessed = blessed.contains(iso);

                    return InkWell(
                      onTap: widget.onSelectDate == null ? null : () => widget.onSelectDate!(date),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isBlessed
                              ? Colors.green.withValues(alpha: 0.18)
                              : Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: isBlessed ? Colors.green : Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            dayNum.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: isBlessed ? FontWeight.bold : FontWeight.normal,
                                  color: isBlessed ? Colors.green.shade800 : null,
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.18), border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 6),
                      Text('Blessed day', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (err, _) => SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Failed to load blessed days',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
