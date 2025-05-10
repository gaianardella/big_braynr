import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../../core/providers/course_providers.dart';
import 'course_model.dart';
import 'dashboard_screen.dart'; // Importiamo la dashboard

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
                : _buildCourseWithDashboard(context, selectedCourse, ref),
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
  
  // Nuova funzione che combina l'header del corso con la dashboard
  Widget _buildCourseWithDashboard(BuildContext context, CourseModel course, WidgetRef ref) {
    return Column(
      children: [
        // Header con il nome del corso
        _buildHeader(course, ref),
        
        // Contenuto della dashboard
        Expanded(
          child: const DashboardScreen(), // Richiamo direttamente la DashboardScreen esistente
        ),
      ],
    );
  }
  
  // Header con il nome del corso (versione semplificata)
  Widget _buildHeader(CourseModel course, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
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
          const Spacer(),
          // Pulsante per accedere alle risorse complete
          TextButton.icon(
            onPressed: () {
              // Azione per vedere tutte le risorse
            },
            icon: Icon(Icons.folder_open, color: course.color),
            label: Text(
              'Risorse',
              style: TextStyle(color: course.color),
            ),
          ),
        ],
      ),
    );
  }
}