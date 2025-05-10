import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../courses/models/course_model.dart';
import '../../../shared/widgets/app_sidebar.dart';

/// Schermata delle note
class NotesScreen extends ConsumerWidget {
  final String courseId;
  
  const NotesScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    // Trova il corso selezionato
    final course = courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => courses.first,
    );
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header della sezione
          _buildHeader(context, isMobile, course),
          
          const SizedBox(height: 24),
          
          // Lista di note di esempio
          Expanded(
            child: _buildNotesList(course),
          ),
        ],
      ),
    );
  }
  
  // Costruisce l'header della schermata
  Widget _buildHeader(BuildContext context, bool isMobile, CourseModel course) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Titolo e icona
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.note_outlined,
                color: AppColors.notes,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Corso: ${course.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: course.color,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Pulsante per creare nuova nota
        if (!isMobile)
          OutlinedButton.icon(
            onPressed: () {
              // Azione per creare nuova nota
            },
            icon: Icon(Icons.add, color: course.color),
            label: Text(
              'Nuova nota',
              style: TextStyle(color: course.color),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: course.color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
      ],
    );
  }
  
  // Lista di note
  Widget _buildNotesList(CourseModel course) {
    // Dati di esempio per dimostrare note del corso selezionato
    final noteTitles = [
      'Lezione 1: Introduzione a ${course.name}',
      'Lezione 2: Concetti base di ${course.name}',
      'Appunti su formule di ${course.name}',
      'Riassunto capitolo 3',
      'Appunti di laboratorio',
      'Domande per l\'esame',
    ];
    
    final noteContents = [
      'In questa lezione abbiamo introdotto i principali concetti di ${course.name}...',
      'I concetti base di ${course.name} includono: ...',
      'Formule importanti da ricordare: ...',
      'Il capitolo 3 tratta di...',
      'Durante il laboratorio abbiamo osservato...',
      'Possibili domande per l\'esame: ...',
    ];
    
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
          color: AppColors.cardDark,
          child: InkWell(
            onTap: () {
              // Azione quando si tocca la nota
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo della nota
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: course.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.note_outlined,
                          color: course.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          noteTitles[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Contenuto della nota
                  Text(
                    noteContents[index],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Data di creazione/modifica
                      const Text(
                        'Modificato 3 giorni fa',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                      
                      // Tag o categoria della nota
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: course.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.name,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: course.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}