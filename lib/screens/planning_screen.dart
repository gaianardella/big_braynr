import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:big_braynr/core/theme/app_colors.dart';
import '../../core/providers/course_providers.dart';
import '../../screens/course_model.dart';

// Model for study sessions
class StudySession {
  final String id;
  final String title;
  final String courseId; // Ora usa l'ID del corso invece della materia
  final DateTime day;
  final TimeOfDay time;
  final Duration duration;
  final String? description;

  StudySession({
    required this.id,
    required this.title,
    required this.courseId,
    required this.day,
    required this.time,
    this.duration = const Duration(hours: 1),
    this.description,
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

// Rimuove la ridefinizione di selectedCourseProvider, che è già nel file course_providers.dart

final studySessionsProvider = StateProvider<List<StudySession>>((ref) {
  final now = DateTime.now();
  return [
    StudySession(
      id: '1',
      title: 'Chapter 3 - Kinematics',
      courseId: 'physics',
      day: now,
      time: const TimeOfDay(hour: 10, minute: 0),
      duration: const Duration(hours: 2),
    ),
    StudySession(
      id: '2',
      title: 'Algebra Practice',
      courseId: 'math',
      day: now,
      time: const TimeOfDay(hour: 14, minute: 0),
      duration: const Duration(hours: 1, minutes: 30),
    ),
    StudySession(
      id: '3',
      title: 'World War II Overview',
      courseId: 'history',
      day: now.add(const Duration(days: 1)),
      time: const TimeOfDay(hour: 9, minute: 30),
      duration: const Duration(hours: 1),
    ),
    StudySession(
      id: '4',
      title: 'Cell Division and Mitosis',
      courseId: 'math', // Esempio (aggiunto matematica come sostituto per biologia)
      day: now.add(const Duration(days: 2)),
      time: const TimeOfDay(hour: 11, minute: 0),
      duration: const Duration(hours: 2),
    ),
    StudySession(
      id: '5',
      title: 'Essay Writing Techniques',
      courseId: 'history', // Usando storia come sostituto per inglese
      day: now.add(const Duration(days: 3)),
      time: const TimeOfDay(hour: 15, minute: 0),
      duration: const Duration(hours: 1, minutes: 15),
    ),
    StudySession(
      id: '6',
      title: 'Data Structures',
      courseId: 'cs',
      day: now.add(const Duration(days: 4)),
      time: const TimeOfDay(hour: 10, minute: 0),
      duration: const Duration(hours: 2),
    ),
    StudySession(
      id: '7',
      title: 'Climate Zones',
      courseId: 'physics', // Usando fisica come sostituto per geografia
      day: now.add(const Duration(days: 5)),
      time: const TimeOfDay(hour: 14, minute: 30),
      duration: const Duration(hours: 1, minutes: 30),
    ),
    StudySession(
      id: '8',
      title: 'Sketching Techniques',
      courseId: 'math', // Usando matematica come sostituto per arte
      day: now.add(const Duration(days: 6)),
      time: const TimeOfDay(hour: 16, minute: 0),
      duration: const Duration(hours: 1),
    ),
    StudySession(
      id: '9',
      title: 'Supply and Demand',
      courseId: 'cs', // Usando informatica come sostituto per economia
      day: now.add(const Duration(days: 6)),
      time: const TimeOfDay(hour: 18, minute: 0),
      duration: const Duration(hours: 1, minutes: 30),
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
              childAspectRatio: 0.3,
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
  final courses = ref.watch(coursesProvider); // Ottieni i corsi

  return Material(
    color: Colors.transparent,
    child: Container(
      margin: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minHeight: 180), // Aumentata l'altezza minima
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isToday ? AppColors.primaryBlue : AppColors.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (sessions.isNotEmpty)
                ...sessions
                    .take(3)
                    .map(
                      (session) {
                        // Trova il corso corrispondente in modo sicuro
                        CourseModel course;
                        try {
                          course = courses.firstWhere(
                            (c) => c.id == session.courseId,
                            orElse: () => CourseModel(
                              id: 'default',
                              name: 'Default',
                              color: AppColors.primaryBlue,
                              icon: Icons.book,
                            ),
                          );
                        } catch (e) {
                          // Se c'è qualche errore, usa un corso di default
                          course = CourseModel(
                            id: 'default',
                            name: 'Default',
                            color: AppColors.primaryBlue,
                            icon: Icons.book,
                          );
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6), // Aumentato il margine inferiore
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8), // Aumentato il padding verticale
                          decoration: BoxDecoration(
                            color: course.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(course.icon, size: 14, color: course.color), // Icona leggermente più grande
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      course.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: course.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4), // Spazio tra il nome del corso e il titolo
                              Text(
                                session.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 2), // Spazio tra il titolo e l'orario
                              Text(
                                '${session.time.format(context)} (${session.duration.inHours}h${session.duration.inMinutes % 60 > 0 ? ' ${session.duration.inMinutes % 60}m' : ''})',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    .toList(),
              if (sessions.length > 3)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '+${sessions.length - 3} more',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMedium,
                    ),
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
    final courses = ref.watch(coursesProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.cardDark, // Sostituito backgroundDark con cardDark
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(day),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: sessions.isEmpty
                    ? const Center(
                        child: Text(
                          'No study sessions for this day',
                          style: TextStyle(color: AppColors.textMedium),
                        ),
                      )
                    : ListView.builder(
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final course = courses.firstWhere(
                            (c) => c.id == session.courseId,
                            orElse: () => CourseModel(
                              id: 'default',
                              name: 'Default',
                              color: AppColors.primaryBlue,
                              icon: Icons.book,
                            ),
                          );
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: AppColors.cardDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: course.color.withOpacity(0.2),
                                child: Icon(course.icon, color: course.color),
                              ),
                              title: Text(
                                session.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: TextStyle(
                                      color: course.color,
                                    ),
                                  ),
                                  Text(
                                    '${session.time.format(context)} - ${TimeOfDay.fromDateTime(session.endDateTime).format(context)}',
                                    style: const TextStyle(
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                  if (session.description != null)
                                    Text(
                                      session.description!,
                                      style: const TextStyle(
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.textMedium),
                                onPressed: () {
                                  // Rimuovi la sessione
                                  final currentSessions = List<StudySession>.from(
                                      ref.read(studySessionsProvider));
                                  currentSessions.removeWhere((s) => s.id == session.id);
                                  ref.read(studySessionsProvider.notifier).state =
                                      currentSessions;
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSessionDialog(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    final formKey = GlobalKey<FormState>();
    String title = '';
    String selectedCourseId = courses.first.id;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int hours = 1;
    int minutes = 0;
    String? description;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.cardDark, // Sostituito backgroundDark con cardDark
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  const Text(
                    'Add New Study Session',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.cardDark,
                    ),
                    style: const TextStyle(color: AppColors.textLight),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a title' : null,
                    onChanged: (value) => title = value,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.cardDark,
                    ),
                    value: selectedCourseId,
                    items: courses
                        .map(
                          (course) => DropdownMenuItem(
                            value: course.id,
                            child: Row(
                              children: [
                                Icon(course.icon, color: course.color, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  course.name,
                                  style: TextStyle(color: course.color),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCourseId = value;
                      }
                    },
                    dropdownColor: AppColors.cardDark, // Sostituito backgroundDark con cardDark
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                if (child == null) return Container();
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppColors.primaryBlue,
                                      onPrimary: Colors.white,
                                      surface: AppColors.cardDark,
                                      onSurface: AppColors.textLight,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            );
                            if (picked != null) {
                              selectedDate = picked;
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMMM d, y').format(selectedDate),
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.textMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              builder: (context, child) {
                                if (child == null) return Container();
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppColors.primaryBlue,
                                      onPrimary: Colors.white,
                                      surface: AppColors.cardDark,
                                      onSurface: AppColors.textLight,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            );
                            if (picked != null) {
                              selectedTime = picked;
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedTime.format(context),
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const Icon(
                                  Icons.access_time,
                                  color: AppColors.textMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Duration:',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Hours',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: AppColors.cardDark,
                                ),
                                value: hours,
                                items: List.generate(
                                  8,
                                  (index) => DropdownMenuItem(
                                    value: index,
                                    child: Text(
                                      '$index',
                                      style: const TextStyle(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    hours = value;
                                  }
                                },
                                dropdownColor: AppColors.cardDark, // Sostituito backgroundDark con cardDark
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Minutes',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: AppColors.cardDark,
                                ),
                                value: minutes,
                                items: [0, 15, 30, 45]
                                    .map(
                                      (minute) => DropdownMenuItem(
                                        value: minute,
                                        child: Text(
                                          '$minute',
                                          style: const TextStyle(
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    minutes = value;
                                  }
                                },
                                dropdownColor: AppColors.cardDark, // Sostituito backgroundDark con cardDark
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.cardDark,
                    ),
                    style: const TextStyle(color: AppColors.textLight),
                    maxLines: 3,
                    onChanged: (value) => description = value,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Salva la nuova sessione
                        final currentSessions =
                            List<StudySession>.from(ref.read(studySessionsProvider));
                        final newSession = StudySession(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          courseId: selectedCourseId,
                          day: DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                          ),
                          time: selectedTime,
                          duration: Duration(hours: hours, minutes: minutes),
                          description: description,
                        );
                        currentSessions.add(newSession);
                        ref.read(studySessionsProvider.notifier).state =
                            currentSessions;
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}