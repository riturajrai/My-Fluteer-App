import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('attendance_data');
    if (dataString != null) {
      final Map<String, dynamic> decoded = jsonDecode(dataString);
      setState(() {
        _attendanceData = decoded.map((key, value) {
          final date = DateTime.parse(key);
          final list = List<dynamic>.from(value);
          return MapEntry(date, list);
        });
      });
    } else {
      for (int i = 1; i <= 5; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        _attendanceData[DateTime(date.year, date.month, date.day)] = ['Present', Colors.green];
      }
      _saveAttendanceData();
    }
  }

  Future<void> _saveAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = _attendanceData.map((key, value) {
      return MapEntry(key.toIso8601String(), value);
    });
    await prefs.setString('attendance_data', jsonEncode(toSave));
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _attendanceData[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _markAttendance(String status, Color color) {
    if (_selectedDay != null) {
      final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      setState(() {
        _attendanceData[normalizedDay] = [status, color];
      });
      _saveAttendanceData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked $status for ${DateFormat('MMMM d, yyyy').format(normalizedDay)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Attendance Info'),
                  content: const Text('Select a date to mark attendance as Present or Absent. Data is saved locally.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Colors.cyan,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      final color = events[1] as Color;
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedDay != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Attendance for ${DateFormat('MMMM d, yyyy').format(_selectedDay!)}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getEventsForDay(_selectedDay!).isNotEmpty
                            ? _getEventsForDay(_selectedDay!)[0].toString()
                            : 'No attendance marked',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _markAttendance('Present', Colors.green),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Mark Present'),
                          ),
                          ElevatedButton(
                            onPressed: () => _markAttendance('Absent', Colors.red),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Mark Absent'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}