import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../courses/models/course_model.dart';
import '../../../shared/widgets/app_sidebar.dart';

/// Schermata delle flashcard
class FlashcardsScreen extends ConsumerWidget {
  final String courseId;
  
  const FlashcardsScreen({
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
          
          // Griglia di flashcards di esempio
          Expanded(
            child: isMobile ? _buildMobileList(course) : _buildDesktopGrid(course),
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
                Icons.view_carousel_outlined,
                color: AppColors.flashcards,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flashcards',
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
        
        // Pulsante per creare nuova flashcard
        if (!isMobile)
          OutlinedButton.icon(
            onPressed: () {
              // Azione per creare nuova flashcard
            },
            icon: Icon(Icons.add, color: course.color),
            label: Text(
              'Nuova flashcard',
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
  
  // Layout per mobile (lista)
  Widget _buildMobileList(CourseModel course) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFlashcardItem(index, true, course),
        );
      },
    );
  }
  
  // Layout per desktop (griglia)
  Widget _buildDesktopGrid(CourseModel course) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildFlashcardItem(index, false, course);
      },
    );
  }
  
  // Costruisce una singola flashcard
  Widget _buildFlashcardItem(int index, bool isMobile, CourseModel course) {
    // Dati di esempio per dimostrare flashcard del corso selezionato
    final coursePrefix = _getCoursePrefix(course.id);
    
    final titles = [
      '$coursePrefix: Concetto 1',
      '$coursePrefix: Definizione A',
      '$coursePrefix: Formula chiave',
      '$coursePrefix: Principio base',
      '$coursePrefix: Teoria fondamentale',
      '$coursePrefix: Applicazione pratica',
    ];
    
    final questions = [
      'Qual è il concetto 1 di ${course.name}?',
      'Come si definisce A in ${course.name}?',
      'Qual è la formula chiave di ${course.name}?',
      'Qual è il principio base di ${course.name}?',
      'Qual è la teoria fondamentale di ${course.name}?',
      'Come si applica ${course.name} nella pratica?',
    ];
    
    final title = titles[index % titles.length];
    final question = questions[index % questions.length];
    
    return Card(
      elevation: 0,
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
          // Azione quando si tocca la flashcard
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? _buildMobileItemContent(title, question, course)
              : _buildDesktopItemContent(title, question, course),
        ),
      ),
    );
  }
  
  // Helper per ottenere un prefisso basato sul corso
  String _getCoursePrefix(String courseId) {
    switch (courseId) {
      case 'math':
        return 'Matematica';
      case 'physics':
        return 'Fisica';
      case 'history':
        return 'Storia';
      case 'cs':
        return 'Informatica';
      default:
        return 'Corso';
    }
  }
  
  // Contenuto della flashcard per layout mobile
  Widget _buildMobileItemContent(String title, String question, CourseModel course) {
    return Row(
      children: [
        // Icona
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: course.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.view_carousel_outlined,
            color: course.color,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Titolo e domanda
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              const Text(
                'Aggiornato 2h fa',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        
        // Freccia per navigazione
        const Icon(
          Icons.chevron_right,
          color: AppColors.textMedium,
        ),
      ],
    );
  }
  
  // Contenuto della flashcard per layout desktop
  Widget _buildDesktopItemContent(String title, String question, CourseModel course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: icona e titolo
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.view_carousel_outlined,
                color: course.color,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Text(
                title,
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
        
        const SizedBox(height: 16),
        
        // Contenuto della flashcard
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Frontale
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Testo "Retro"
              Text(
                'Retro:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: course.color,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Anteprima del retro
              const Text(
                '(Tocca per vedere la risposta)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Orario ultimo aggiornamento
            const Text(
              'Aggiornato 2h fa',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
            
            // Durata di studio
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textMedium,
                ),
                const SizedBox(width: 4),
                const Text(
                  '5 min',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}