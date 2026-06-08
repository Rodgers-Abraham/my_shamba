import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../../domain/entities/calendar_entry_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'auth_screen.dart';

class CalendarScreen extends StatefulWidget {
  final String farmId;
  const CalendarScreen({super.key, required this.farmId});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    context.read<CalendarBloc>().add(LoadCalendar(widget.farmId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Farm Calendar')),
      body: BlocListener<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is CalendarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            if (state is CalendarLoading) return const Center(child: CircularProgressIndicator());
            
            List<CalendarEntryEntity> entries = [];
            if (state is CalendarLoaded) {
              entries = state.entries;
            }

            final selectedDayEntries = entries.where((e) => isSameDay(e.date, _selectedDay)).toList();

            return Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                    ),
                    eventLoader: (day) {
                      return entries.where((e) => isSameDay(e.date, day)).toList();
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('Activities & Due Dates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: selectedDayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = selectedDayEntries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            entry.isDueDate ? Icons.notification_important : Icons.event_note,
                            color: entry.isDueDate ? Colors.red : AppTheme.primary,
                          ),
                          title: Text(entry.title, style: TextStyle(
                            decoration: entry.isCompleted ? TextDecoration.lineThrough : null,
                          )),
                          subtitle: Text(entry.description),
                          trailing: Checkbox(
                            value: entry.isCompleted,
                            onChanged: (val) {
                              context.read<CalendarBloc>().add(ToggleEntryCompletion(entry.id, val!));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isDueDate = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              SwitchListTile(
                title: const Text('Is Due Date?'),
                value: isDueDate,
                onChanged: (val) => setDialogState(() => isDueDate = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                final newEntry = CalendarEntryEntity(
                  id: '',
                  farmId: widget.farmId,
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  date: _selectedDay ?? DateTime.now(),
                  isDueDate: isDueDate,
                );
                context.read<CalendarBloc>().add(AddCalendarEntry(newEntry));

                // Smart Diary Automated Cascades
                final lowerTitle = titleCtrl.text.toLowerCase();
                final baseDate = _selectedDay ?? DateTime.now();

                if (lowerTitle.contains('insemination') || lowerTitle.contains('ai') || lowerTitle.contains('bull service')) {
                  // Gestation logic (approx 283 days)
                  context.read<CalendarBloc>().add(AddCalendarEntry(CalendarEntryEntity(
                    id: '', farmId: widget.farmId, title: 'Dry Off: ${titleCtrl.text}',
                    description: 'Stop milking 60 days before expected calving.',
                    date: baseDate.add(const Duration(days: 223)), isDueDate: true,
                  )));
                  context.read<CalendarBloc>().add(AddCalendarEntry(CalendarEntryEntity(
                    id: '', farmId: widget.farmId, title: 'Calving Prep: ${titleCtrl.text}',
                    description: 'Move to maternity pen, monitor closely.',
                    date: baseDate.add(const Duration(days: 276)), isDueDate: true,
                  )));
                  context.read<CalendarBloc>().add(AddCalendarEntry(CalendarEntryEntity(
                    id: '', farmId: widget.farmId, title: 'Expected Calving: ${titleCtrl.text}',
                    description: 'Expected calving date (283 days post-insemination).',
                    date: baseDate.add(const Duration(days: 283)), isDueDate: true,
                  )));
                } else if (lowerTitle.contains('deworm') || lowerTitle.contains('vaccin')) {
                  // Recurring health check logic (approx 90 days)
                  context.read<CalendarBloc>().add(AddCalendarEntry(CalendarEntryEntity(
                    id: '', farmId: widget.farmId, title: 'Next: ${titleCtrl.text}',
                    description: 'Recurring 90-day health routine.',
                    date: baseDate.add(const Duration(days: 90)), isDueDate: true,
                  )));
                }

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
