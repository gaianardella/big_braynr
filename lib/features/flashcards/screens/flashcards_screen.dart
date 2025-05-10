import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header della sezione
          _buildHeader(context, isMobile),
          
          const SizedBox(height: 24),
          
          // Griglia di flashcards di esempio
          Expanded(
            child: isMobile ? _buildMobileList() : _buildDesktopGrid(),
          ),
        ],
      ),
    );
  }
  
  // Costruisce l'header della schermata
  Widget _buildHeader(BuildContext context, bool isMobile) {
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
                color: AppColors.getLightVersionOf(AppColors.flashcards),
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
                Text(
                  'Flashcards',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${isMobile ? "4" : "6"} flashcards disponibili',
                  style: Theme.of(context).textTheme.bodySmall,
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
            icon: const Icon(Icons.add, color: AppColors.flashcards),
            label: const Text(
              'Nuova flashcard',
              style: TextStyle(color: AppColors.flashcards),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.flashcards),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
      ],
    );
  }
  
  // Layout per mobile (lista)
  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFlashcardItem(index, true),
        );
      },
    );
  }
  
  // Layout per desktop (griglia)
  Widget _buildDesktopGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildFlashcardItem(index, false);
      },
    );
  }
  
  // Costruisce una singola flashcard
  Widget _buildFlashcardItem(int index, bool isMobile) {
    final titles = [
      'Capitale d\'Italia',
      'Formula dell\'acqua',
      'Primo elemento',
      'Anno scoperta America',
      'Definizione di fotosintesi',
      'Legge di Ohm',
    ];
    
    final questions = [
      'Qual è la capitale d\'Italia?',
      'Qual è la formula chimica dell\'acqua?',
      'Qual è il primo elemento della tavola periodica?',
      'In quale anno Cristoforo Colombo scoprì l\'America?',
      'Cos\'è la fotosintesi?',
      'Come si esprime la legge di Ohm?',
    ];
    
    final title = titles[index % titles.length];
    final question = questions[index % questions.length];
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Azione quando si tocca la flashcard
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? _buildMobileItemContent(title, question)
              : _buildDesktopItemContent(title, question),
        ),
      ),
    );
  }
  
  // Contenuto della flashcard per layout mobile
  Widget _buildMobileItemContent(String title, String question) {
    return Row(
      children: [
        // Icona
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.getLightVersionOf(AppColors.flashcards),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.view_carousel_outlined,
            color: AppColors.flashcards,
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
                  color: AppColors.textDark,
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
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        
        // Freccia per navigazione
        const Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
        ),
      ],
    );
  }
  
  // Contenuto della flashcard per layout desktop
  Widget _buildDesktopItemContent(String title, String question) {
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
                color: AppColors.getLightVersionOf(AppColors.flashcards),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.view_carousel_outlined,
                color: AppColors.flashcards,
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
                color: AppColors.textLight,
              ),
            ),
            
            // Durata di studio
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                const Text(
                  '5 min',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
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