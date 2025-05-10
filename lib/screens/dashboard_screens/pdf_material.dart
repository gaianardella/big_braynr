import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modello per i materiali didattici (PDF)
class CourseMaterial {
  final String id;
  final String title;
  final String pdfPath;
  final bool isCompleted;
  final double progressPercentage;
  final String lastAccessed; // Data dell'ultimo accesso
  final int totalPages;
  final int lastReadPage;

  CourseMaterial({
    required this.id,
    required this.title,
    required this.pdfPath,
    required this.isCompleted,
    required this.progressPercentage,
    required this.lastAccessed,
    required this.totalPages,
    required this.lastReadPage,
  });
}

// Dati mock dei materiali per corso
Map<String, List<CourseMaterial>> courseMaterialsMap = {
  'course1': [
    CourseMaterial(
      id: 'pdf_1_1',
      title: 'Introduzione all\'Algebra',
      pdfPath: 'assets/pdfs/algebra_intro.pdf',
      isCompleted: true,
      progressPercentage: 1.0,
      lastAccessed: '08/05/2025',
      totalPages: 24,
      lastReadPage: 24,
    ),
    CourseMaterial(
      id: 'pdf_1_2',
      title: 'Equazioni di Primo Grado',
      pdfPath: 'assets/pdfs/linear_equations.pdf',
      isCompleted: true,
      progressPercentage: 1.0,
      lastAccessed: '06/05/2025',
      totalPages: 32,
      lastReadPage: 32,
    ),
    CourseMaterial(
      id: 'pdf_1_3',
      title: 'Equazioni di Secondo Grado',
      pdfPath: 'assets/pdfs/quadratic_equations.pdf',
      isCompleted: false,
      progressPercentage: 0.75,
      lastAccessed: '09/05/2025',
      totalPages: 40,
      lastReadPage: 30,
    ),
    CourseMaterial(
      id: 'pdf_1_4',
      title: 'Disequazioni',
      pdfPath: 'assets/pdfs/inequalities.pdf',
      isCompleted: false,
      progressPercentage: 0.25,
      lastAccessed: '09/05/2025',
      totalPages: 36,
      lastReadPage: 9,
    ),
    CourseMaterial(
      id: 'pdf_1_5',
      title: 'Sistemi Lineari',
      pdfPath: 'assets/pdfs/linear_systems.pdf',
      isCompleted: false,
      progressPercentage: 0.0,
      lastAccessed: 'Non ancora visualizzato',
      totalPages: 28,
      lastReadPage: 0,
    ),
  ],
  'course2': [
    CourseMaterial(
      id: 'pdf_2_1',
      title: 'Geometria Euclidea',
      pdfPath: 'assets/pdfs/euclidean_geometry.pdf',
      isCompleted: true,
      progressPercentage: 1.0,
      lastAccessed: '05/05/2025',
      totalPages: 30,
      lastReadPage: 30,
    ),
    CourseMaterial(
      id: 'pdf_2_2',
      title: 'Triangoli e Teoremi',
      pdfPath: 'assets/pdfs/triangles.pdf',
      isCompleted: false,
      progressPercentage: 0.6,
      lastAccessed: '08/05/2025',
      totalPages: 25,
      lastReadPage: 15,
    ),
    CourseMaterial(
      id: 'pdf_2_3',
      title: 'Figure Piane',
      pdfPath: 'assets/pdfs/plane_figures.pdf',
      isCompleted: false,
      progressPercentage: 0.0,
      lastAccessed: 'Non ancora visualizzato',
      totalPages: 28,
      lastReadPage: 0,
    ),
  ],
  'course3': [
    CourseMaterial(
      id: 'pdf_3_1',
      title: 'Fondamenti di Probabilità',
      pdfPath: 'assets/pdfs/probability.pdf',
      isCompleted: true,
      progressPercentage: 1.0,
      lastAccessed: '04/05/2025',
      totalPages: 22,
      lastReadPage: 22,
    ),
    CourseMaterial(
      id: 'pdf_3_2',
      title: 'Statistica Descrittiva',
      pdfPath: 'assets/pdfs/descriptive_statistics.pdf',
      isCompleted: true,
      progressPercentage: 1.0,
      lastAccessed: '07/05/2025',
      totalPages: 34,
      lastReadPage: 34,
    ),
    CourseMaterial(
      id: 'pdf_3_3',
      title: 'Distribuzioni di Probabilità',
      pdfPath: 'assets/pdfs/probability_distributions.pdf',
      isCompleted: false,
      progressPercentage: 0.8,
      lastAccessed: '09/05/2025',
      totalPages: 38,
      lastReadPage: 30,
    ),
  ],
};

// Provider per recuperare i materiali didattici di un corso specifico
final courseMaterialsProvider = Provider.family<List<CourseMaterial>, String>((ref, courseId) {
  return courseMaterialsMap[courseId] ?? [];
});

// Provider per ottenere il progresso complessivo dei materiali di un corso
final courseCompletionProvider = Provider.family<double, String>((ref, courseId) {
  final materials = ref.watch(courseMaterialsProvider(courseId));
  
  if (materials.isEmpty) {
    return 0.0;
  }
  
  // Calcola la media dei progressi di tutti i materiali
  double totalProgress = 0.0;
  for (final material in materials) {
    totalProgress += material.progressPercentage;
  }
  
  return totalProgress / materials.length;
});

// Provider per ottenere l'ultimo materiale consultato
final lastAccessedMaterialProvider = Provider.family<CourseMaterial?, String>((ref, courseId) {
  final materials = ref.watch(courseMaterialsProvider(courseId));
  
  if (materials.isEmpty) {
    return null;
  }
  
  // Ordina i materiali per data di ultimo accesso (esclude quelli non ancora visualizzati)
  final accessedMaterials = materials
      .where((material) => material.lastReadPage > 0)
      .toList()
    ..sort((a, b) {
      if (a.lastAccessed == 'Non ancora visualizzato') return 1;
      if (b.lastAccessed == 'Non ancora visualizzato') return -1;
      
      // Converti la data in un formato confrontabile (giorno/mese/anno)
      final aParts = a.lastAccessed.split('/');
      final bParts = b.lastAccessed.split('/');
      
      if (aParts.length != 3 || bParts.length != 3) {
        return 0;
      }
      
      final aDate = DateTime(int.parse(aParts[2]), int.parse(aParts[1]), int.parse(aParts[0]));
      final bDate = DateTime(int.parse(bParts[2]), int.parse(bParts[1]), int.parse(bParts[0]));
      
      return bDate.compareTo(aDate); // Ordine decrescente
    });
  
  return accessedMaterials.isNotEmpty ? accessedMaterials.first : null;
});