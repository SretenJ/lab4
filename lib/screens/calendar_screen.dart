import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/ispit.dart';

class CalendarScreen extends StatefulWidget {
  final List<Ispit> exams;
  const CalendarScreen({super.key, required this.exams});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late List<Ispit> examList;
  late final ValueNotifier<List<Ispit>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    examList = widget.exams;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getExamsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _createAppBar(), body: _createBody());
  }

  PreferredSizeWidget _createAppBar() {
    return AppBar(
      // The title text which will be shown on the action bar
      title: const Text(
        "Calendar for all exams",
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Ispit> _getExamsForDay(DateTime day) {
    List<Ispit> examsForDay = List.empty(growable: true);

    for (var exam in examList) {
      if (isSameDay(exam.datum, day)) {
        examsForDay.add(exam);
      }
    }
    return examsForDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getExamsForDay(selectedDay);
    }
  }

  Widget _createBody() {
    return Column(
      children: [
        TableCalendar(
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2024, 10, 16),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          eventLoader: _getExamsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Ispit>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(value[index].ime),
                      subtitle: Text(value[index].vreme.format(context)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
