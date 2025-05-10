import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget per una card di contenuto riutilizzabile in tutta l'app.
/// Può essere utilizzato per visualizzare vari tipi di contenuto di studio
/// come flashcard, note, mappe mentali, ecc.
class ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final String? updatedTime;
  final String? duration;
  final bool isMobile;
  final Widget? customContent;
  
  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.onTap,
    this.updatedTime = 'Aggiornato 2h fa',
    this.duration,
    this.isMobile = false,
    this.customContent,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }
  
  // Layout per dispositivi mobili (orizzontale e compatto)
  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Icona e colore della categoria
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.getLightVersionOf(color),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Titolo e sottotitolo
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
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (updatedTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    updatedTime!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Freccia per navigazione
          const Icon(
            Icons.chevron_right,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }
  
  // Layout per desktop (verticale e più dettagliato)
  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icona e titolo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.getLightVersionOf(color),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contenuto personalizzato o subtitle
          customContent ?? Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Orario ultimo aggiornamento
              if (updatedTime != null)
                Text(
                  updatedTime!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              
              // Durata di studio (se disponibile)
              if (duration != null)
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
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
}

/// Widget per visualizzare una flashcard nella card di contenuto.
/// Può essere utilizzato come customContent nel ContentCard.
class FlashcardContent extends StatelessWidget {
  final String front;
  final String back;
  
  const FlashcardContent({
    super.key,
    required this.front,
    required this.back,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
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
            front,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Testo "Retro"
        const Text(
          'Retro:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Retro
        Text(
          back,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMedium,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Widget per visualizzare un estratto di una nota nella card di contenuto.
/// Può essere utilizzato come customContent nel ContentCard.
class NoteContent extends StatelessWidget {
  final String content;
  
  const NoteContent({
    super.key,
    required this.content,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getLightVersionOf(AppColors.notes),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textDark,
          height: 1.5,
        ),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Widget per visualizzare un quiz nella card di contenuto.
/// Può essere utilizzato come customContent nel ContentCard.
class QuizContent extends StatelessWidget {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  
  const QuizContent({
    super.key,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Domanda
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // Opzioni
        ...List.generate(
          options.length > 3 ? 3 : options.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == correctOptionIndex
                        ? AppColors.success
                        : AppColors.backgroundGrey,
                    border: Border.all(
                      color: index == correctOptionIndex
                          ? AppColors.success
                          : AppColors.border,
                    ),
                  ),
                  child: index == correctOptionIndex
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 13,
                      color: index == correctOptionIndex
                          ? AppColors.success
                          : AppColors.textMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Indicatore di più opzioni
        if (options.length > 3)
          const Text(
            '+ altre opzioni',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}