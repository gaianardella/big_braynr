import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'features/flashcards/screens/flashcards_screen.dart';
// import 'features/notes/screens/notes_screen.dart';
// import 'features/mind_maps/screens/mind_maps_screen.dart';
// import 'features/quizzes/screens/quizzes_screen.dart';
// import 'features/keywords/screens/keywords_screen.dart';
import 'shared/widgets/app_sidebar.dart';
import 'shared/widgets/app_topbar.dart';

// Provider per gestire l'indice della tab selezionata
final selectedTabProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  // Helper method per determinare se siamo su un dispositivo mobile
  bool _isMobileDevice(BuildContext context) {
    // Controlla se la larghezza dello schermo è inferiore a 768 (breakpoint tablet)
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    
    // Controlla se siamo su una piattaforma mobile (iOS o Android)
    final isMobilePlatform = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
    
    // Ritorna true se una delle due condizioni è soddisfatta
    return isSmallScreen || isMobilePlatform;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(selectedTabProvider);
    final isMobile = _isMobileDevice(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: isMobile
          ? _buildMobileLayout(context, selectedTabIndex, ref)
          : _buildDesktopLayout(context, selectedTabIndex, ref),
      // Barra di navigazione inferiore (solo per mobile)
      bottomNavigationBar: isMobile ? _buildBottomNavBar(context, selectedTabIndex, ref) : null,
      // Floating Action Button con stile Braynr
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Azione per creare nuovo contenuto basato sulla tab attuale
          _showCreateContentDialog(context, selectedTabIndex);
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Layout desktop con sidebar
  Widget _buildDesktopLayout(BuildContext context, int selectedTabIndex, WidgetRef ref) {
    return Row(
      children: [
        // Sidebar di navigazione
        AppSidebar(
          selectedIndex: selectedTabIndex,
          onIndexChanged: (index) => ref.read(selectedTabProvider.notifier).state = index,
        ),
        
        // Area contenuto principale
        Expanded(
          child: Column(
            children: [
              // Barra superiore
              const AppTopBar(),
              
              // Contenuto principale
              Expanded(
                child: _buildMainContent(selectedTabIndex),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Layout mobile senza sidebar
  Widget _buildMobileLayout(BuildContext context, int selectedTabIndex, WidgetRef ref) {
    return Column(
      children: [
        // Barra superiore per mobile
        const AppTopBar(isMobile: true),
        
        // Contenuto principale
        Expanded(
          child: _buildMainContent(selectedTabIndex),
        ),
      ],
    );
  }

  // Contenuto principale dell'applicazione
  Widget _buildMainContent(int selectedTabIndex) {
    return Container(
      // Aggiunto un padding per migliorare l'aspetto visivo
      padding: const EdgeInsets.all(16),
      // Impostato il colore di sfondo principale per il contenuto
      color: AppColors.darkBackground,
      child: IndexedStack(
        index: selectedTabIndex,
        children: const [
          FlashcardsScreen(),
          // NotesScreen(),
          // MindMapsScreen(),
          // QuizzesScreen(),
          // KeywordsScreen(),
        ],
      ),
    );
  }

  // Barra di navigazione inferiore per mobile con tema scuro
  Widget _buildBottomNavBar(BuildContext context, int selectedIndex, WidgetRef ref) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.view_carousel_outlined,
            label: 'Flashcards',
            color: AppColors.flashcards,
            isSelected: selectedIndex == 0,
            onTap: () => ref.read(selectedTabProvider.notifier).state = 0,
          ),
          _BottomNavItem(
            icon: Icons.note_outlined,
            label: 'Note',
            color: AppColors.notes,
            isSelected: selectedIndex == 1,
            onTap: () => ref.read(selectedTabProvider.notifier).state = 1,
          ),
          _BottomNavItem(
            icon: Icons.bubble_chart_outlined,
            label: 'Mappe',
            color: AppColors.mindMaps,
            isSelected: selectedIndex == 2,
            onTap: () => ref.read(selectedTabProvider.notifier).state = 2,
          ),
          _BottomNavItem(
            icon: Icons.quiz_outlined,
            label: 'Domande',
            color: AppColors.questions,
            isSelected: selectedIndex == 3,
            onTap: () => ref.read(selectedTabProvider.notifier).state = 3,
          ),
          _BottomNavItem(
            icon: Icons.key_outlined,
            label: 'Parole',
            color: AppColors.keywords,
            isSelected: selectedIndex == 4,
            onTap: () => ref.read(selectedTabProvider.notifier).state = 4,
          ),
        ],
      ),
    );
  }

  // Mostra dialog per la creazione di nuovo contenuto
  void _showCreateContentDialog(BuildContext context, int selectedTabIndex) {
    final contentTypes = [
      'Flashcards',
      'Note',
      'Mappe mentali',
      'Domande',
      'Parole chiave',
    ];
    
    final contentType = contentTypes[selectedTabIndex];
    final contentColor = [
      AppColors.flashcards,
      AppColors.notes, 
      AppColors.mindMaps,
      AppColors.questions,
      AppColors.keywords,
    ][selectedTabIndex];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCreateContentSheet(context, contentType, contentColor),
    );
  }

  // Costruisce il bottom sheet per la creazione di nuovo contenuto
  Widget _buildCreateContentSheet(BuildContext context, String contentType, Color contentColor) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Crea nuovo $contentType',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMedium),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Form placeholder
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        style: const TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          labelText: 'Titolo',
                          labelStyle: const TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: contentColor, width: 2),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextField(
                        style: const TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          labelText: 'Descrizione',
                          labelStyle: const TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: contentColor, width: 2),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Campo specifico in base al tipo di contenuto
                      _buildContentTypeSpecificField(contentType, contentColor),
                    ],
                  ),
                ),
              ),
              
              // Pulsante di salvataggio
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Implementazione del salvataggio
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: contentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Salva',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Costruisce campi specifici per tipo di contenuto
  Widget _buildContentTypeSpecificField(String contentType, Color contentColor) {
    final TextStyle labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: contentColor,
    );
    
    final InputDecoration inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: contentColor, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textMedium),
    );
    
    switch (contentType) {
      case 'Flashcards':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frontalino', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Inserisci il testo del frontalino',
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            Text('Retro', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Inserisci il testo del retro',
              ),
              maxLines: 2,
            ),
          ],
        );
        
      case 'Note':
        return TextField(
          style: const TextStyle(color: AppColors.textLight),
          decoration: inputDecoration.copyWith(
            labelText: 'Contenuto',
            hintText: 'Scrivi il contenuto della nota qui...',
          ),
          maxLines: 10,
        );
        
      case 'Mappe mentali':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concetto centrale', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Inserisci il concetto centrale',
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text('Concetti correlati', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Separa i concetti con virgole',
              ),
              maxLines: 3,
            ),
          ],
        );
        
      case 'Domande':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Domanda', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Inserisci la domanda',
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Opzioni (una per riga, segna con * quella corretta)',
              style: labelStyle,
            ),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Esempio:\nParis\n*Londra\nBerlino\nMadrid',
              ),
              maxLines: 6,
            ),
          ],
        );
        
      case 'Parole chiave':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parola chiave', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Inserisci la parola chiave',
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text('Definizione', style: labelStyle),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: AppColors.textLight),
              decoration: inputDecoration.copyWith(
                hintText: 'Inserisci la definizione',
              ),
              maxLines: 4,
            ),
          ],
        );
        
      default:
        return const SizedBox.shrink();
    }
  }
}

// Item nella barra di navigazione inferiore
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : AppColors.textMedium,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? color : AppColors.textMedium,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}