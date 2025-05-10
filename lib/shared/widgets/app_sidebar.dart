import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget della sidebar per la navigazione principale dell'app.
/// Questo widget viene mostrato solo nel layout desktop.
/// Stile ispirato a Braynr.
class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Sezione strumenti di studio
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'STRUMENTI DI STUDIO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          _SidebarItem(
            icon: Icons.view_carousel_outlined,
            label: 'Flashcards',
            color: AppColors.flashcards,
            isSelected: selectedIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          
          _SidebarItem(
            icon: Icons.note_outlined,
            label: 'Note',
            color: AppColors.notes,
            isSelected: selectedIndex == 1,
            onTap: () => onIndexChanged(1),
          ),
          
          _SidebarItem(
            icon: Icons.bubble_chart_outlined,
            label: 'Mappe mentali',
            color: AppColors.mindMaps,
            isSelected: selectedIndex == 2,
            onTap: () => onIndexChanged(2),
          ),
          
          _SidebarItem(
            icon: Icons.quiz_outlined,
            label: 'Domande',
            color: AppColors.questions,
            isSelected: selectedIndex == 3,
            onTap: () => onIndexChanged(3),
          ),
          
          _SidebarItem(
            icon: Icons.key_outlined,
            label: 'Parole chiave',
            color: AppColors.keywords,
            isSelected: selectedIndex == 4,
            onTap: () => onIndexChanged(4),
          ),
          
          const Divider(height: 32, indent: 16, endIndent: 16, color: AppColors.border),
          
          // Sezione libreria
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'LIBRERIA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          _SidebarItem(
            icon: Icons.book_outlined,
            label: 'I miei corsi',
            color: AppColors.textLight,
            isSelected: false,
            onTap: () {},
          ),
          
          _SidebarItem(
            icon: Icons.folder_outlined,
            label: 'Argomenti',
            color: AppColors.textLight,
            isSelected: false,
            onTap: () {},
          ),
          
          _SidebarItem(
            icon: Icons.star_outline,
            label: 'Preferiti',
            color: AppColors.textLight,
            isSelected: false,
            onTap: () {},
          ),
          
          const Spacer(),
          
          // Sezione inferiore
          const Divider(indent: 16, endIndent: 16, color: AppColors.border),
          const SizedBox(height: 16),
          
          _SidebarItem(
            icon: Icons.help_outline,
            label: 'Aiuto',
            color: AppColors.textLight,
            isSelected: false,
            onTap: () {},
          ),
          
          const SizedBox(height: 8),
          
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Impostazioni',
            color: AppColors.textLight,
            isSelected: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Widget per un singolo elemento della sidebar.
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Per lo stile Braynr, ogni elemento ha un design specifico
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
              // Icona della funzionalità
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.getLightVersionOf(color) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : AppColors.textMedium,
                  size: 18,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Etichetta
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.textLight : AppColors.textMedium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Indicatore se l'elemento è selezionato
              if (isSelected)
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}