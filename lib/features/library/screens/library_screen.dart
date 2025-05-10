import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../courses/models/course_model.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCourseId = ref.watch(selectedCourseProvider);
    final courses = ref.watch(coursesProvider);

    final selectedCourse = selectedCourseId != null
        ? courses.firstWhere((course) => course.id == selectedCourseId,
            orElse: () => courses.first)
        : null;

    return Scaffold(
      body: Row(
        children: [

          // Contenuto principale
          Expanded(
            child: selectedCourse == null
                ? _buildCourseGrid(context, courses, ref)
                : _buildCourseDetails(context, selectedCourse, ref),
          ),
        ],
      ),
    );
  }
  
  // Griglia dei corsi
  Widget _buildCourseGrid(BuildContext context, List<CourseModel> courses, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Libreria Corsi',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _buildCourseFolder(context, course, ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Cartella del corso nella griglia
  Widget _buildCourseFolder(BuildContext context, CourseModel course, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Imposta il corso selezionato
        ref.read(selectedCourseProvider.notifier).state = course.id;
      },
      child: Container(
        decoration: BoxDecoration(
          color: course.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: course.color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: course.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        course.icon,
                        color: course.color,
                        size: 32,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    course.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: course.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    '24 Risorse',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: course.color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Dettagli del corso specifico
  Widget _buildCourseDetails(BuildContext context, CourseModel course, WidgetRef ref) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con il nome del corso e le informazioni aggiuntive
          _buildHeader(course, ref),
          
          const SizedBox(height: 24),
          
          // Grid delle risorse del corso
          Expanded(
            child: _buildResourcesGrid(course),
          ),
        ],
      ),
    );
  }
  
  // Header con il nome del corso e i contatori
  Widget _buildHeader(CourseModel course, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pulsante indietro e titolo del corso
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
                onPressed: () {
                  // Deseleziona il corso corrente
                  ref.read(selectedCourseProvider.notifier).state = null;
                },
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: course.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  course.icon,
                  color: course.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                course.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Barra con i contatori delle risorse
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResourceCounter('Flashcards', '24', Icons.view_carousel_outlined),
                _buildResourceCounter('Note', '12', Icons.note_outlined),
                _buildResourceCounter('Mappe', '5', Icons.bubble_chart_outlined),
                _buildResourceCounter('Domande', '18', Icons.quiz_outlined),
                _buildResourceCounter('Parole', '32', Icons.key_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Contatore per ciascun tipo di risorsa
  Widget _buildResourceCounter(String label, String count, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.textMedium,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }
  
  // Grid che mostra tutte le risorse del corso
  Widget _buildResourcesGrid(CourseModel course) {
    // Titoli delle sezioni
    final sections = [
      'Flashcards recenti',
      'Note',
      'Mappe mentali',
      'Domande',
    ];
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return _buildResourceSection(sections[index], course);
      },
    );
  }
  
  // Sezione per un tipo di risorsa
  Widget _buildResourceSection(String title, CourseModel course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo della sezione con pulsante "Vedi tutti"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigazione alla vista completa
              },
              child: const Text(
                'Vedi tutti',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Grid di risorse (placeholder)
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  children: [
                    // Contenuto della risorsa
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titolo
                          Text(
                            'Elemento ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Descrizione
                          const Text(
                            'Descrizione dell\'elemento...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMedium,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const Spacer(),
                          
                          // Data di aggiornamento
                          const Text(
                            'Aggiornato 3 giorni fa',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Indicatore di colore in alto a destra
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: course.color,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}