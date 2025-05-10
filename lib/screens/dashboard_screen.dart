import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/course_providers.dart';
import 'dashboard_screens/book_screen.dart'; // Importa la schermata dei materiali
import 'dashboard_screens/chapter_screen.dart'; // Importa la schermata dei capitoli
// import '../data/pdf_materials_data.dart'; // Importa il file dei dati mockati

// Define the providers
final completionPercentageProvider =
    StateProvider<double>((ref) => 0.72); // Esempio: 72%
final studyStreakProvider = StateProvider<int>((ref) => 5); // Esempio: 5 giorni
final chapterProgressProvider =
    StateProvider<double>((ref) => 0.45); // Esempio: 45%
final dailyActivityProvider =
    StateProvider<double>((ref) => 0.3); // Esempio: 30%
final todayPlannedActivitiesProvider =
    StateProvider<List<Map<String, String>>>((ref) => [
          {'description': 'Ripassa Algebra', 'time': '10:00'},
          {'description': 'Leggi Storia', 'time': '14:00'},
        ]);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionPercentage = ref.watch(completionPercentageProvider);
    final studyStreak = ref.watch(studyStreakProvider);
    final chapterProgress = ref.watch(chapterProgressProvider);
    final dailyActivity = ref.watch(dailyActivityProvider);
    final todayPlannedActivities = ref.watch(todayPlannedActivitiesProvider);
    final selectedCourse = ref.watch(selectedCourseProvider);
    final courses = ref.watch(coursesProvider);

    // Get the selected course's icon and id
    final selectedCourseInfo = courses
        .firstWhere(
          (course) => course.id == selectedCourse,
          orElse: () => courses.first,
        );
    final selectedCourseIcon = selectedCourseInfo.icon;

    // Ottieni una citazione motivazionale (potrebbe venire da un provider)
    const quote = "L'esperto in qualsiasi cosa è stato una volta un principiante.";
    const author = "Helen Hayes";

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header
            const Text(
              'Dashboard di Studio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),

            const SizedBox(height: 24),

            // Main statistics grid - reso più compatto
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0, // Reso più piccolo (prima era 1.4)
              children: [
                // Completion Percentage Card con navigazione alla pagina dei materiali
                _buildCompactStatCard(
                  context,
                  title: 'Materiale Completato',
                  value: '${(completionPercentage * 100).toStringAsFixed(0)}%',
                  icon: selectedCourseIcon,
                  color: Colors.blueAccent,
                  progress: completionPercentage,
                  description: 'del corso attuale',
                  onTap: () {
                    // Naviga alla pagina dei materiali (book_screen)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChapterProgressScreen(courseId: selectedCourseInfo.id),
                      ),
                    );
                  },
                ),

                // Study Streak Card
                _buildCompactStatCard(
                  context,
                  title: 'Serie di Studio',
                  value: '$studyStreak giorni',
                  imagePath: 'assets/images/brain.png',
                  color: Colors.redAccent,
                  progress: studyStreak / 7,
                  description: 'giorni consecutivi',
                  onTap: () {
                    // Nessuna navigazione specifica
                  },
                ),

                // Chapter Progress Card con navigazione a StudyWorkspaceScreen
                _buildCompactStatCard(
                  context,
                  title: 'Progresso Capitolo',
                  value: '${(chapterProgress * 100).toStringAsFixed(0)}%',
                  icon: Icons.book,
                  color: Colors.greenAccent,
                  progress: chapterProgress,
                  description: 'completato',
                  onTap: () {
                    // Naviga direttamente a StudyWorkspaceScreen quando si clicca sulla card
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudyWorkspaceScreen(
                          courseId: selectedCourseInfo.id,
                          chapterId: 'current_chapter', // Qui puoi passare l'ID del capitolo corrente
                        ),
                      ),
                    );
                  },
                ),

                // Daily Activity Card
                _buildCombinedProgressAndActivities(
                  context, 
                  dailyActivity, 
                  todayPlannedActivities
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Motivational Quote
            _buildMotivationalQuote(quote, author),
          ],
        ),
      ),
    );
  }

  // Card compatta senza bottone
  Widget _buildCompactStatCard(
    BuildContext context, {
    required String title,
    required String value,
    IconData? icon,
    String? imagePath,
    required Color color,
    required double progress,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundGrey,
              color: color,
              minHeight: 6,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Center(
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        icon,
                        color: icon == Icons.book ? Colors.white : color,
                        size: 40,
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedProgressAndActivities(
    BuildContext context,
    double dailyActivity, 
    List<Map<String, String>> activities
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purpleAccent.withOpacity(0.2), Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12), // Ridotto padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso di Oggi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8), // Ridotto spazio

          // Progress Section
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Obiettivo Giornaliero',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12, // Ridotto font
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(dailyActivity * 100).toStringAsFixed(0)}% completato',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Ridotto font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // Ridotto spazio
                    LinearProgressIndicator(
                      value: dailyActivity,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 6, // Ridotto altezza
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12), // Ridotto spazio
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tempo Studiato',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12, // Ridotto font
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(dailyActivity * 2).toStringAsFixed(1)}/2 ore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Ridotto font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12), // Ridotto spazio

          // Mostro solo un'attività per risparmiare spazio
          if (activities.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prossima attività',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 4, // Più sottile
                      height: 20, // Più corto
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activities.first['description']!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      activities.first['time']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote(String quote, String author) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Motivazione del Giorno',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '- $author',
            style: const TextStyle(
              color: AppColors.textMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}