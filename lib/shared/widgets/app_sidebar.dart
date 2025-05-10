import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/courses/models/course_model.dart';

// Provider per la sezione selezionata - inizializzato con 'library'
final selectedSectionProvider = StateProvider<String>((ref) => 'library');

// Provider per il corso selezionato
final selectedCourseProvider = StateProvider<String?>((ref) => null);

// Provider per i corsi - assicurati che questo corrisponda alla definizione che hai
// nel tuo AppShell o in altre parti dell'app
final coursesProvider = Provider<List<CourseModel>>((ref) {
  return [
    CourseModel(
      id: 'math',
      name: 'Matematica',
      color: const Color(0xFF4DA9FF),
      icon: Icons.calculate,
    ),
    CourseModel(
      id: 'physics',
      name: 'Fisica',
      color: const Color(0xFFFF9500),
      icon: Icons.science,
    ),
    CourseModel(
      id: 'history',
      name: 'Storia',
      color: const Color(0xFF5E72EB),
      icon: Icons.history_edu,
    ),
    CourseModel(
      id: 'cs',
      name: 'Informatica',
      color: const Color(0xFF64C2DB),
      icon: Icons.computer,
    ),
  ];
});

/// Widget della sidebar con tre sezioni principali:
/// Libreria, Planner e Città
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSection = ref.watch(selectedSectionProvider);
    
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo dell'app
          _buildLogo(),
          
          const SizedBox(height: 24),
          
          // Sezioni principali
          _SectionItem(
            icon: Icons.book_outlined,
            label: 'Libreria',
            isSelected: selectedSection == 'library',
            onTap: () {
              // Quando si seleziona la libreria, deseleziona qualsiasi corso
              ref.read(selectedCourseProvider.notifier).state = null;
              ref.read(selectedSectionProvider.notifier).state = 'library';
              
              // Se siamo su mobile, chiudi il Drawer
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
            },
          ),
          
          _SectionItem(
            icon: Icons.calendar_today_outlined,
            label: 'Planner',
            isSelected: selectedSection == 'planner',
            onTap: () {
              ref.read(selectedSectionProvider.notifier).state = 'planner';
              
              // Se siamo su mobile, chiudi il Drawer
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
            },
          ),
          
          _SectionItem(
            icon: Icons.map_outlined,
            label: 'Città',
            isSelected: selectedSection == 'city',
            onTap: () {
              ref.read(selectedSectionProvider.notifier).state = 'city';
              
              // Se siamo su mobile, chiudi il Drawer
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
            },
          ),
          
          const Spacer(),
          
          // Impostazioni (nella parte inferiore)
          const Divider(color: AppColors.border),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: AppColors.textMedium,
            ),
            title: const Text(
              'Impostazioni',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
              ),
            ),
            onTap: () {
              // Implementare la navigazione alle impostazioni
              // e chiudere il drawer se necessario
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  // Logo dell'app nella parte superiore della sidebar
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        'assets/images/braynr_logo.png',
        height: 40,
      ),
    );
  }
}

/// Widget per visualizzare una sezione principale nella sidebar
class _SectionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _SectionItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Colore principale per le sezioni
    Color sectionColor;
    
    // Assegna un colore diverso in base alla sezione
    switch (label) {
      case 'Libreria':
        sectionColor = AppColors.primaryBlue;
        break;
      case 'Planner':
        sectionColor = AppColors.notes;
        break;
      case 'Città':
        sectionColor = AppColors.mindMaps;
        break;
      default:
        sectionColor = AppColors.primaryBlue;
    }
    
    return Material(
      color: isSelected ? AppColors.backgroundGrey : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            children: [
              // Icona della sezione
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? sectionColor.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? sectionColor : AppColors.textMedium,
                  size: 18,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Nome della sezione
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.textLight : AppColors.textMedium,
                ),
              ),
              
              // Indicatore se la sezione è selezionata
              if (isSelected) ...[
                const Spacer(),
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: sectionColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}