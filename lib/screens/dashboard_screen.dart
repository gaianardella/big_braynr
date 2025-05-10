import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/course_providers.dart';
import 'dashboard_screens/book_screen.dart'; // Importa la schermata dei capitoli

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

            // Main statistics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4, // Slightly bigger boxes
              children: [
                // Completion Percentage Card - ora con navigazione alla pagina capitoli
                _buildStatCardWithNavigation(
                  context,
                  title: 'Materiale Completato',
                  value: '${(completionPercentage * 100).toStringAsFixed(0)}%',
                  icon: selectedCourseIcon,
                  color: Colors.blueAccent,
                  progress: completionPercentage,
                  description: 'del corso attuale',
                  courseId: selectedCourseInfo.id, // Passa l'ID del corso
                ),

                // Study Streak Card
                _buildStatCardWithImage(
                  context,
                  title: 'Serie di Studio',
                  value: '$studyStreak giorni',
                  imagePath: 'assets/images/brain.png',
                  color: Colors.redAccent, // More vibrant red
                  progress:
                      studyStreak / 7, // Assuming 7 is max for visualization
                  description: 'giorni consecutivi',
                  isStreak: true,
                ),

                // Chapter Progress Card (senza navigazione)
                _buildChapterProgressCard(
                  context,
                  ref,
                  progress: chapterProgress,
                ),

                // Daily Activity Card
                _buildCombinedProgressAndActivities(
                    context, dailyActivity, todayPlannedActivities),
              ],
            ),

            const SizedBox(height: 24),

            // Motivational Quote
            _buildMotivationalQuote(),
          ],
        ),
      ),
    );
  }

  // Nuovo metodo per la card con navigazione alla pagina capitoli
  Widget _buildStatCardWithNavigation(
    BuildContext context, {
    required String title,
    required String value,
    IconData? icon,
    String? imagePath,
    required Color color,
    required double progress,
    required String description,
    required String courseId, // Aggiungi courseId come parametro
    bool isStreak = false,
  }) {
    return GestureDetector(
      onTap: () {
        // Naviga alla pagina dei capitoli quando si clicca sul quadrato
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChapterProgressScreen(courseId: courseId),
          ),
        );
      },
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
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundGrey,
              color: color,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        icon,
                        color: color,
                        size: 48,
                      ),
              ),
            ),
            const SizedBox(height: 8),
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

  Widget _buildStatCardWithImage(
    BuildContext context, {
    required String title,
    required String value,
    IconData? icon,
    String? imagePath,
    required Color color,
    required double progress,
    required String description,
    bool isStreak = false,
  }) {
    return Container(
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
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.backgroundGrey,
            color: color,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: imagePath != null
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon,
                      color: color,
                      size: 48,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterProgressCard(
    BuildContext context,
    WidgetRef ref, {
    required double progress,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent.withOpacity(0.2), Colors.greenAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso Capitolo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% completato',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Icon(
                Icons.book,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Azione per continuare lo studio
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continua a Studiare',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedProgressAndActivities(BuildContext context,
      double dailyActivity, List<Map<String, String>> activities) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progresso di Oggi & Attività Pianificate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

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
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(dailyActivity * 100).toStringAsFixed(0)}% completato',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: dailyActivity,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tempo Studiato',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(dailyActivity * 2).toStringAsFixed(1)}/2 ore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Planned Activities Section
          const Text(
            'Matematica',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...activities.map((activity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['description']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity['time']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    const quote =
        "L'esperto in qualsiasi cosa è stato una volta un principiante.";
    const author = "Helen Hayes";

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