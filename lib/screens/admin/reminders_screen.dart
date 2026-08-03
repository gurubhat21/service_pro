import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:service_pro/providers/auth_provider.dart';
import 'package:service_pro/providers/reminder_provider.dart';
import 'package:service_pro/widgets/empty_state.dart';

/// Reminders management screen
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReminders() {
    final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
    if (adminId.isNotEmpty) {
      context.read<ReminderProvider>().loadReminders(adminId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00BCD4),
          labelColor: const Color(0xFF00BCD4),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReminderList(upcoming: true),
          _buildReminderList(upcoming: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(context),
        backgroundColor: const Color(0xFF00BCD4),
        icon: const Icon(Icons.alarm_add, color: Colors.white),
        label: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildReminderList({required bool upcoming}) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)));
        }

        final now = DateTime.now();
        final reminders = provider.reminders.where((r) {
          return upcoming ? r.remindAt.isAfter(now) : r.remindAt.isBefore(now);
        }).toList();

        reminders.sort((a, b) => upcoming
            ? a.remindAt.compareTo(b.remindAt)
            : b.remindAt.compareTo(a.remindAt));

        if (reminders.isEmpty) {
          return EmptyState(
            icon: upcoming ? Icons.alarm : Icons.history,
            title: upcoming ? 'No upcoming reminders' : 'No past reminders',
            subtitle: upcoming ? 'Tap + to add a reminder' : 'Completed reminders will appear here',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            final isPast = reminder.remindAt.isBefore(now);

            return Dismissible(
              key: Key(reminder.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              onDismissed: (_) {
                provider.deleteReminder(reminder.id);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2128),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPast
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFAB47BC).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: (isPast ? Colors.grey : const Color(0xFFAB47BC)).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPast ? Icons.alarm_off : Icons.alarm,
                        color: isPast ? Colors.grey : const Color(0xFFAB47BC),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isPast ? Colors.white54 : Colors.white,
                            ),
                          ),
                          if (reminder.message != null && reminder.message!.isNotEmpty)
                            Text(
                              reminder.message!,
                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEE, MMM dd – hh:mm a').format(reminder.remindAt),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isPast ? Colors.white38 : const Color(0xFF00BCD4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.white.withOpacity(0.3), size: 20),
                      onPressed: () => provider.deleteReminder(reminder.id),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 40 * index)).fadeIn().slideX(begin: 0.05);
          },
        );
      },
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2128),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    const Text('Add Reminder', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Reminder title *',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        prefixIcon: Icon(Icons.title, color: Colors.white.withOpacity(0.4), size: 20),
                        filled: true, fillColor: const Color(0xFF0D1117),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: messageCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message (optional)',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true, fillColor: const Color(0xFF0D1117),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (c, child) => Theme(data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF00BCD4), surface: Color(0xFF1C2128))), child: child!),
                        );
                        if (date == null) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                          builder: (c, child) => Theme(data: Theme.of(c).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF00BCD4), surface: Color(0xFF1C2128))), child: child!),
                        );
                        if (time == null) return;
                        setSheet(() { selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute); });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF0D1117), borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.4), size: 20),
                          const SizedBox(width: 12),
                          Text(DateFormat('EEE, MMM dd, yyyy – hh:mm a').format(selectedDate), style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Title is required')));
                            return;
                          }
                          final adminId = context.read<AuthProvider>().currentUser?.uid ?? '';
                          context.read<ReminderProvider>().addReminder(
                            adminId: adminId,
                            title: titleCtrl.text.trim(),
                            message: messageCtrl.text.trim().isEmpty ? null : messageCtrl.text.trim(),
                            remindAt: selectedDate,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder added!'), backgroundColor: Color(0xFF66BB6A)));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
