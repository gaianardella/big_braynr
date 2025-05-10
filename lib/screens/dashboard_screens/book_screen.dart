import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/course_providers.dart';
import '../course_model.dart';

// Modello per le lezioni
class LessonModel {
  final String id;
  final String title;
  final Duration duration;
  final bool isCompleted;
  final String type; // Video, Quiz, Documento, Esercizio, ecc.

  LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.isCompleted,
    required this.type,
  });
}

// Modello per i capitoli - aggiornato con colori e lezioni
class ChapterModel {
  final String id;
  final String title;
  final String description;
  final int totalLessons;
  final int completedLessons;
  final DateTime? lastStudied;
  final Duration estimatedDuration;
  final Color color; // Non nullable - ogni capitolo avrà un colore
  final List<LessonModel> lessons; // Lezioni del capitolo

  ChapterModel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalLessons,
    required this.completedLessons,
    this.lastStudied,
    required this.estimatedDuration,
    required this.color,
    required this.lessons,
  });

  double get progressPercentage =>
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;

  bool get isCompleted => completedLessons == totalLessons;

  bool get isStarted => completedLessons > 0;

  bool get isLocked =>
      false; // In futuro si può implementare una logica di sblocco
}

// Funzione helper per generare tipi di lezione alternati
String _getLessonType(int index) {
  final types = ['Video', 'Testo', 'Quiz', 'Documento', 'Esercizio'];
  return types[index % types.length];
}

// Provider per i capitoli del corso selezionato
final chaptersProvider =
    Provider.family<List<ChapterModel>, String>((ref, courseId) {
  // Colori brillanti per i capitoli
  const List<Color> chapterColors = [
    Color(0xFF00B0FF), // Bright Sky Blue
    Color(0xFFFF4081), // Bright Pink
    Color(0xFF76FF03), // Bright Lime Green
    Color(0xFFD500F9), // Bright Purple
    Color(0xFFFF1744), // Vivid Red
    Color(0xFF00E5FF), // Bright Cyan
    Color(0xFFFFEA00), // Bright Yellow
    Color(0xFF00C853), // Bright Green
  ];

  // Lista di capitoli di base
  final List<Map<String, dynamic>> baseChapters = [
    {
      'id': '1',
      'title': 'Introduzione',
      'description': 'Principi fondamentali e concetti base',
      'totalLessons': 5,
      'completedLessons': 5,
      'lastStudied': DateTime.now().subtract(const Duration(days: 1)),
      'estimatedDuration': const Duration(minutes: 45),
    },
    {
      'id': '2',
      'title': 'Concetti di Base',
      'description': 'Strutture e definizioni principali',
      'totalLessons': 8,
      'completedLessons': 6,
      'lastStudied': DateTime.now().subtract(const Duration(days: 3)),
      'estimatedDuration': const Duration(hours: 1, minutes: 30),
    },
    {
      'id': '3',
      'title': 'Applicazioni Pratiche',
      'description': 'Casi di studio ed esempi reali',
      'totalLessons': 10,
      'completedLessons': 3,
      'lastStudied': DateTime.now().subtract(const Duration(days: 5)),
      'estimatedDuration': const Duration(hours: 2, minutes: 15),
    },
    {
      'id': '4',
      'title': 'Esercizi Guidati',
      'description': 'Problemi con soluzioni dettagliate',
      'totalLessons': 12,
      'completedLessons': 0,
      'lastStudied': null,
      'estimatedDuration': const Duration(hours: 2, minutes: 30),
    },
    {
      'id': '5',
      'title': 'Approfondimenti',
      'description': 'Argomenti avanzati e correlati',
      'totalLessons': 7,
      'completedLessons': 0,
      'lastStudied': null,
      'estimatedDuration': const Duration(hours: 1, minutes: 45),
    },
    {
      'id': '6',
      'title': 'Conclusioni e Riassunto',
      'description': 'Ricapitolazione dei concetti chiave',
      'totalLessons': 4,
      'completedLessons': 0,
      'lastStudied': null,
      'estimatedDuration': const Duration(minutes: 50),
    },
  ];

  // Creiamo i capitoli con i colori assegnati e le lezioni
  return List.generate(baseChapters.length, (index) {
    final chapter = baseChapters[index];
    // Assegniamo un colore fisso dal nostro array, ciclando se necessario
    final chapterColor = chapterColors[index % chapterColors.length];

    // Generiamo alcune lezioni di esempio
    final List<LessonModel> lessons = List.generate(
      chapter['totalLessons'],
      (lessonIndex) => LessonModel(
        id: '${chapter['id']}.${lessonIndex + 1}',
        title: 'Lezione ${lessonIndex + 1}',
        duration: Duration(minutes: 10 + lessonIndex * 2),
        isCompleted: lessonIndex < chapter['completedLessons'],
        type: _getLessonType(lessonIndex),
      ),
    );

    // Restituiamo il capitolo completo
    return ChapterModel(
      id: chapter['id'],
      title: chapter['title'],
      description: chapter['description'],
      totalLessons: chapter['totalLessons'],
      completedLessons: chapter['completedLessons'],
      lastStudied: chapter['lastStudied'],
      estimatedDuration: chapter['estimatedDuration'],
      color: chapterColor,
      lessons: lessons,
    );
  });
});

// Provider per tenere traccia dei capitoli espansi
final expandedChaptersProvider = StateProvider<Set<String>>((ref) => {});

class ChapterProgressScreen extends ConsumerWidget {
  final String courseId;

  const ChapterProgressScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(coursesProvider).firstWhere(
          (course) => course.id == courseId,
          orElse: () => CourseModel(
            id: 'default',
            name: 'Corso',
            color: AppColors.primaryBlue,
            icon: Icons.book,
          ),
        );

    final chapters = ref.watch(chaptersProvider(courseId));

    // Calcola le statistiche generali
    final totalLessons =
        chapters.fold<int>(0, (sum, chapter) => sum + chapter.totalLessons);
    final completedLessons =
        chapters.fold<int>(0, (sum, chapter) => sum + chapter.completedLessons);
    final overallProgress =
        totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final completedChapters =
        chapters.where((chapter) => chapter.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          course.name,
          style: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: course.color,
            ),
            onPressed: () {
              // Implementare la logica dei preferiti
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: course.color,
            ),
            onPressed: () {
              // Implementare la logica di condivisione
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress overview
          _buildProgressOverview(
            context,
            course,
            completedLessons,
            totalLessons,
            overallProgress,
            completedChapters,
            chapters.length,
            chapters,
          ),

          // Chapter list
          Expanded(
            child: _buildChaptersList(context, chapters, course, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(
    BuildContext context,
    CourseModel course,
    int completedLessons,
    int totalLessons,
    double overallProgress,
    int completedChapters,
    int totalChapters,
    List<ChapterModel> chapters,
  ) {
    // Calculate remaining time
    final remainingTime = chapters.where((c) => !c.isCompleted).fold<Duration>(
          Duration.zero,
          (sum, chapter) =>
              sum +
              (chapter.estimatedDuration * (1 - chapter.progressPercentage)),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panoramica del Progresso',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso Complessivo',
                    style: TextStyle(
                      fontSize: 14,
                      color: course.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: course.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  backgroundColor: course.color.withOpacity(0.2),
                  color: course.color,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedLessons/$totalLessons lezioni completate',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.book_outlined,
                  title: 'Capitoli',
                  value: '$completedChapters/$totalChapters',
                  subtitle: 'completati',
                  color: course.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  title: 'Tempo stimato',
                  value: _formatRemainingTime(remainingTime),
                  subtitle: 'per completare',
                  color: course.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersList(
    BuildContext context,
    List<ChapterModel> chapters,
    CourseModel course,
    WidgetRef ref,
  ) {
    final expandedChapters = ref.watch(expandedChaptersProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final isExpanded = expandedChapters.contains(chapter.id);

        return _buildExpandableChapterCard(
          context,
          chapter,
          course,
          isExpanded,
          ref,
        );
      },
    );
  }

  Widget _buildExpandableChapterCard(
    BuildContext context,
    ChapterModel chapter,
    CourseModel course,
    bool isExpanded,
    WidgetRef ref,
  ) {
    final isInProgress = chapter.isStarted && !chapter.isCompleted;

    return Column(
      children: [
        // Card principale con sfumatura di colore basata sul colore del capitolo
        GestureDetector(
          onTap: () {
            // Toggle espansione del capitolo
            final expandedChapters = ref.read(expandedChaptersProvider);
            if (isExpanded) {
              ref.read(expandedChaptersProvider.notifier).state =
                  Set.from(expandedChapters)..remove(chapter.id);
            } else {
              ref.read(expandedChaptersProvider.notifier).state =
                  Set.from(expandedChapters)..add(chapter.id);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  chapter.color.withOpacity(0.1),
                  chapter.color.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: chapter.isCompleted
                    ? chapter.color.withOpacity(0.5)
                    : AppColors.border,
                width: chapter.isCompleted ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: chapter.color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Chapter header with progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Chapter number or icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: chapter.isCompleted
                              ? chapter.color.withOpacity(0.2)
                              : AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: chapter.isCompleted
                              ? Icon(
                                  Icons.check_circle,
                                  color: chapter.color,
                                  size: 24,
                                )
                              : Text(
                                  chapter.id,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isInProgress
                                        ? chapter.color
                                        : AppColors.textMedium,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Chapter title and details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: chapter.isCompleted
                                    ? chapter.color
                                    : AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chapter.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMedium,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Expand/collapse icon
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: chapter.color,
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${chapter.completedLessons}/${chapter.totalLessons} lezioni',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                          Text(
                            '${(chapter.progressPercentage * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: chapter.isCompleted
                                  ? chapter.color
                                  : AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: chapter.progressPercentage,
                          backgroundColor: AppColors.backgroundGrey,
                          color: chapter.color,
                          minHeight: 6,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Last activity and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (chapter.lastStudied != null)
                            Text(
                              'Ultimo studio: ${_formatLastStudied(chapter.lastStudied!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMedium,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            const Text(
                              'Non ancora iniziato',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMedium,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          Text(
                            _formatDuration(chapter.estimatedDuration),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
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

        // Lezioni espandibili
        if (isExpanded) _buildLessonsList(context, chapter),
      ],
    );
  }

  Widget _buildLessonsList(BuildContext context, ChapterModel chapter) {
    // Container per le lezioni che appare quando il capitolo è espanso
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 8, left: 24, right: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chapter.color.withOpacity(0.3),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: chapter.lessons.length,
        separatorBuilder: (context, index) => Divider(
          color: chapter.color.withOpacity(0.2),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final lesson = chapter.lessons[index];
          return _buildLessonItem(context, lesson, chapter.color);
        },
      ),
    );
  }

  Widget _buildLessonItem(
      BuildContext context, LessonModel lesson, Color chapterColor) {
    // Icona in base al tipo di lezione
    IconData lessonIcon;
    switch (lesson.type) {
      case 'Video':
        lessonIcon = Icons.play_circle_outline;
        break;
      case 'Quiz':
        lessonIcon = Icons.quiz_outlined;
        break;
      case 'Documento':
        lessonIcon = Icons.article_outlined;
        break;
      case 'Esercizio':
        lessonIcon = Icons.assignment_outlined;
        break;
      case 'Testo':
        lessonIcon = Icons.text_snippet_outlined;
        break;
      default:
        lessonIcon = Icons.book_outlined;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: chapterColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          lessonIcon,
          color: chapterColor,
          size: 20,
        ),
      ),
      title: Text(
        lesson.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color:
              lesson.isCompleted ? AppColors.textLight : AppColors.textMedium,
          decoration: lesson.isCompleted ? TextDecoration.none : null,
        ),
      ),
      subtitle: Text(
        '${lesson.type} · ${_formatDuration(lesson.duration)}',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMedium,
        ),
      ),
      trailing: lesson.isCompleted
          ? Icon(
              Icons.check_circle,
              color: chapterColor,
              size: 20,
            )
          : Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMedium,
              size: 16,
            ),
      onTap: () {
        // Azione quando si clicca su una lezione
        // Navigare alla lezione o mostrarla in un dialog/bottom sheet
      },
    );
  }

  String _formatLastStudied(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return DateFormat('d MMM').format(date);
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) {
        return '$hours h';
      } else {
        return '$hours h $minutes min';
      }
    }
  }

  String _formatRemainingTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return '$minutes min';
    } else if (minutes == 0) {
      return '$hours h';
    } else {
      return '$hours h $minutes min';
    }
  }
}
