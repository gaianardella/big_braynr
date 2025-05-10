import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:big_braynr/core/theme/app_colors.dart';
import 'package:big_braynr/shared/widgets/content_card.dart';

// Model for study sessions
class StudySession {
  final String id;
  final String title;
  final String subject;
  final DateTime day;
  final TimeOfDay time;
  final Duration duration;
  final String? description;
  final Color color;

  StudySession({
    required this.id,
    required this.title,
    required this.subject,
    required this.day,
    required this.time,
    this.duration = const Duration(hours: 1),
    this.description,
    this.color = AppColors.primaryBlue,
  });

  DateTime get startDateTime => DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );

  DateTime get endDateTime => startDateTime.add(duration);

  String formattedTime(BuildContext context) =>
      '${time.format(context)} - ${TimeOfDay.fromDateTime(endDateTime).format(context)}';

  String get dayName => DateFormat('EEE').format(day);
}

// Providers
final currentWeekProvider = StateProvider<DateTime>((ref) => DateTime.now());
final studySessionsProvider = StateProvider<List<StudySession>>((ref) {
  final now = DateTime.now();
  return [
    StudySession(
      id: '1',
      title: 'Physics: Chapter 3 - Kinematics',
      subject: 'Physics',
      day: now,
      time: const TimeOfDay(hour: 10, minute: 0),
      duration: const Duration(hours: 2),
      color: AppColors.flashcards,
    ),
    StudySession(
      id: '2',
      title: 'Mathematics: Algebra Practice',
      subject: 'Mathematics',
      day: now,
      time: const TimeOfDay(hour: 14, minute: 0),
      duration: const Duration(hours: 1, minutes: 30),
      color: AppColors.notes,
    ),
    StudySession(
      id: '3',
      title: 'History: World War II Overview',
      subject: 'History',
      day: now.add(const Duration(days: 1)),
      time: const TimeOfDay(hour: 9, minute: 30),
      duration: const Duration(hours: 1),
      color: AppColors.questions,
    ),
    StudySession(
      id: '4',
      title: 'Chemistry: Organic Reactions',
      subject: 'Chemistry',
      day: now.add(const Duration(days: 1)),
      time: const TimeOfDay(hour: 13, minute: 0),
      duration: const Duration(hours: 1, minutes: 30),
      color: AppColors.primaryBlue,
    ),
    StudySession(
      id: '5',
      title: 'Biology: Cell Division and Mitosis',
      subject: 'Biology',
      day: now.add(const Duration(days: 2)),
      time: const TimeOfDay(hour: 11, minute: 0),
      duration: const Duration(hours: 2),
      color: AppColors.flashcards,
    ),
    StudySession(
      id: '6',
      title: 'English: Essay Writing Techniques',
      subject: 'English',
      day: now.add(const Duration(days: 3)),
      time: const TimeOfDay(hour: 15, minute: 0),
      duration: const Duration(hours: 1, minutes: 15),
      color: AppColors.notes,
    ),
    StudySession(
      id: '7',
      title: 'Computer Science: Data Structures',
      subject: 'Computer Science',
      day: now.add(const Duration(days: 4)),
      time: const TimeOfDay(hour: 10, minute: 0),
      duration: const Duration(hours: 2),
      color: AppColors.questions,
    ),
    StudySession(
      id: '8',
      title: 'Geography: Climate Zones',
      subject: 'Geography',
      day: now.add(const Duration(days: 5)),
      time: const TimeOfDay(hour: 14, minute: 30),
      duration: const Duration(hours: 1, minutes: 30),
      color: AppColors.primaryBlue,
    ),
    StudySession(
      id: '9',
      title: 'Art: Sketching Techniques',
      subject: 'Art',
      day: now.add(const Duration(days: 6)),
      time: const TimeOfDay(hour: 16, minute: 0),
      duration: const Duration(hours: 1),
      color: AppColors.flashcards,
    ),
    StudySession(
      id: '10',
      title: 'Economics: Supply and Demand',
      subject: 'Economics',
      day: now.add(const Duration(days: 6)),
      time: const TimeOfDay(hour: 18, minute: 0),
      duration: const Duration(hours: 1, minutes: 30),
      color: AppColors.notes,
    ),
  ];
});

class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeek = ref.watch(currentWeekProvider);
    final studySessions = ref.watch(studySessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekHeader(context, ref, currentWeek),
            const SizedBox(height: 16),
            Expanded(
              child: _buildWeekView(context, ref, currentWeek, studySessions),
            ),
            _buildAddSessionButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekHeader(
      BuildContext context, WidgetRef ref, DateTime currentWeek) {
    final firstDayOfWeek = _getFirstDayOfWeek(currentWeek);
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textLight),
          onPressed: () {
            ref.read(currentWeekProvider.notifier).state =
                currentWeek.subtract(const Duration(days: 7));
          },
        ),
        Text(
          '${DateFormat('MMM d').format(firstDayOfWeek)} - ${DateFormat('MMM d, y').format(lastDayOfWeek)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textLight),
          onPressed: () {
            ref.read(currentWeekProvider.notifier).state =
                currentWeek.add(const Duration(days: 7));
          },
        ),
      ],
    );
  }

  Widget _buildWeekView(BuildContext context, WidgetRef ref,
      DateTime currentWeek, List<StudySession> sessions) {
    final firstDayOfWeek = _getFirstDayOfWeek(currentWeek);
    final days =
        List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));

    return Column(
      children: [
        _buildDayNamesHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = days[index];
              final daySessions =
                  sessions.where((s) => _isSameDay(s.day, day)).toList();
              return _buildDayCard(context, ref, day, daySessions);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayNamesHeader() {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: dayNames.map((day) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCard(BuildContext context, WidgetRef ref, DateTime day,
      List<StudySession> sessions) {
    final isToday = _isSameDay(day, DateTime.now());

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: AppColors.primaryBlue, width: 2)
              : null,
        ),
        child: InkWell(
          onTap: () => _showDayDetails(context, ref, day, sessions),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isToday ? AppColors.primaryBlue : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                if (sessions.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: sessions.length > 3 ? 3 : sessions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: session.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${session.title} (${session.duration.inHours}h ${session.duration.inMinutes % 60}m)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (sessions.length > 3)
                  Text(
                    '+${sessions.length - 3} more',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddSessionButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showAddSessionDialog(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Add Study Session',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper methods
  DateTime _getFirstDayOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showDayDetails(BuildContext context, WidgetRef ref, DateTime day,
      List<StudySession> sessions) {
    // Implementation for showing day details
  }

  void _showAddSessionDialog(BuildContext context, WidgetRef ref) {
    // Implementation for adding a session
  }
}
