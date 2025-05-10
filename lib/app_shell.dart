import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'screens/library_screen.dart';
import 'screens/planning_screen.dart';
import 'screens/dashboard_screen.dart';
// import 'features/map/screens/map_screen.dart';
import 'shared/widgets/app_sidebar.dart';
import 'shared/widgets/app_topbar.dart';
import 'screens/course_model.dart';

// Provider con lista mock di corsi
final coursesProvider = Provider<List<CourseModel>>((ref) {
  return [
    CourseModel(
      id: 'math',
      name: 'Matematica',
      icon: Icons.calculate,
      color: Colors.blue,
    ),
    CourseModel(
      id: 'history',
      name: 'Storia',
      icon: Icons.book,
      color: Colors.green,
    ),
    CourseModel(
      id: 'science',
      name: 'Scienze',
      icon: Icons.science,
      color: Colors.deepPurple,
    ),
  ];
});

// Provider per corso selezionato
final selectedCourseProvider = StateProvider<String?>((ref) => null);

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
    final selectedSection = ref.watch(selectedSectionProvider);
    final selectedCourseId = ref.watch(selectedCourseProvider);
    final isMobile = _isMobileDevice(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: isMobile
          ? _buildMobileLayout(context, selectedSection, selectedCourseId, ref)
          : _buildDesktopLayout(
              context, ref, selectedSection, selectedCourseId),
      // Barra di navigazione inferiore (solo per mobile)
      bottomNavigationBar:
          isMobile ? _buildBottomNavBar(context, selectedSection, ref) : null,
      // Floating Action Button
      floatingActionButton: _buildFloatingActionButton(
          context, selectedSection, selectedCourseId),
      // Drawer per mobile
      drawer: isMobile
          ? const Drawer(
              child: AppSidebar(),
            )
          : null,
    );
  }

  // Layout desktop con sidebar
  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref,
      String selectedSection, String? selectedCourseId) {
    return Row(
      children: [
        // Sidebar di navigazione
        const AppSidebar(),

        // Area contenuto principale
        Expanded(
          child: Column(
            children: [
              // Barra superiore
              const AppTopBar(),

              // Contenuto principale
              Expanded(
                child:
                    _buildMainContent(selectedSection, selectedCourseId, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Layout mobile senza sidebar
  Widget _buildMobileLayout(BuildContext context, String selectedSection,
      String? selectedCourseId, WidgetRef ref) {
    return Column(
      children: [
        // Barra superiore per mobile
        const AppTopBar(isMobile: true),

        // Contenuto principale
        Expanded(
          child: _buildMainContent(selectedSection, selectedCourseId, ref),
        ),
      ],
    );
  }

  // Contenuto principale dell'applicazione in base alla sezione selezionata
  Widget _buildMainContent(
      String selectedSection, String? selectedCourseId, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.darkBackground,
      child: _getScreenForSection(selectedSection, selectedCourseId),
    );
  }

  // Ritorna lo schermo corretto in base alla sezione selezionata
  Widget _getScreenForSection(String section, String? selectedCourseId) {
    switch (section) {
      case 'library':
        return const DashboardScreen();
      case 'planner':
        return const StudyPlannerScreen();
      // case 'map':
      //   return const MapScreen();
      default:
        return const LibraryScreen();
    }
  }

  // Barra di navigazione inferiore per mobile
  Widget _buildBottomNavBar(
      BuildContext context, String selectedSection, WidgetRef ref) {
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
            icon: Icons.book_outlined,
            label: 'Libreria',
            isSelected: selectedSection == 'library',
            onTap: () {
              // Deseleziona qualsiasi corso quando si torna alla libreria
              if (ref.read(selectedCourseProvider) != null) {
                ref.read(selectedCourseProvider.notifier).state = null;
              }
              ref.read(selectedSectionProvider.notifier).state = 'library';
            },
          ),
          _BottomNavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Planner',
            isSelected: selectedSection == 'planner',
            onTap: () =>
                ref.read(selectedSectionProvider.notifier).state = 'planner',
          ),
          _BottomNavItem(
            icon: Icons.map_outlined,
            label: 'Mappa',
            isSelected: selectedSection == 'map',
            onTap: () =>
                ref.read(selectedSectionProvider.notifier).state = 'map',
          ),
        ],
      ),
    );
  }

  // Floating Action Button personalizzato per ogni sezione
  Widget? _buildFloatingActionButton(
      BuildContext context, String selectedSection, String? selectedCourseId) {
    // Colore e azione in base alla sezione attuale
    IconData icon;
    String tooltip;
    VoidCallback onPressed;
    Color backgroundColor;

    switch (selectedSection) {
      case 'library':
        // Se siamo nella vista dei corsi e non c'è un corso selezionato
        if (selectedCourseId == null) {
          icon = Icons.add;
          tooltip = 'Aggiungi corso';
          backgroundColor = AppColors.primaryBlue;
          onPressed = () {
            // Dialog per aggiungere un nuovo corso
            _showAddCourseDialog(context);
          };
        }
        // Se siamo nei dettagli di un corso selezionato
        else {
          icon = Icons.add;
          tooltip = 'Aggiungi elemento';
          backgroundColor = AppColors.primaryBlue;
          onPressed = () {
            // Dialog per aggiungere un nuovo elemento al corso
            _showAddItemDialog(context, selectedCourseId);
          };
        }
        break;
      case 'planner':
        icon = Icons.add_task;
        tooltip = 'Nuovo evento';
        backgroundColor = AppColors.notes;
        onPressed = () {
          // Dialog per aggiungere un nuovo evento al planner
          _showAddEventDialog(context);
        };
        break;
      case 'map':
        // Per la mappa potrebbe non essere necessario un FAB
        return null;
      default:
        icon = Icons.add;
        tooltip = 'Aggiungi';
        backgroundColor = AppColors.primaryBlue;
        onPressed = () {};
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
      child: Icon(icon, color: Colors.white),
    );
  }

  // Dialog per aggiungere un nuovo corso
  void _showAddCourseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddCourseSheet(context),
    );
  }

  // Dialog per aggiungere un nuovo elemento a un corso
  void _showAddItemDialog(BuildContext context, String courseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddItemSheet(context, courseId),
    );
  }

  // Dialog per aggiungere un nuovo evento al planner
  void _showAddEventDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddEventSheet(context),
    );
  }

  // Sheet per aggiungere un nuovo corso
  Widget _buildAddCourseSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.4,
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
                  const Text(
                    'Aggiungi nuovo corso',
                    style: TextStyle(
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

              // Form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome del corso
                      const TextField(
                        style: TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          labelText: 'Nome del corso',
                          labelStyle: TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Descrizione
                      const TextField(
                        style: TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          labelText: 'Descrizione',
                          labelStyle: TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Selezione colore
                      const Text(
                        'Colore',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildColorSelector(),

                      const SizedBox(height: 16),

                      // Selezione icona
                      const Text(
                        'Icona',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIconSelector(),
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
                    // Logica per salvare il corso
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
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

  // Sheet per aggiungere un nuovo elemento (flashcard, nota, ecc.) a un corso
  Widget _buildAddItemSheet(BuildContext context, String courseId) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
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
                  const Text(
                    'Aggiungi nuovo elemento',
                    style: TextStyle(
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

              // Selezione del tipo di elemento
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTypeSelector('Flashcard', Icons.view_carousel_outlined,
                      AppColors.flashcards),
                  _buildTypeSelector(
                      'Nota', Icons.note_outlined, AppColors.notes),
                  _buildTypeSelector('Mappa mentale',
                      Icons.bubble_chart_outlined, AppColors.mindMaps),
                  _buildTypeSelector(
                      'Domanda', Icons.quiz_outlined, AppColors.questions),
                  _buildTypeSelector(
                      'Parola chiave', Icons.key_outlined, AppColors.keywords),
                ],
              ),

              const SizedBox(height: 24),

              // Form per flashcard (default)
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titolo
                      const TextField(
                        style: TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          labelText: 'Titolo',
                          labelStyle: TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.flashcards, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Fronte
                      const Text(
                        'Fronte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const TextField(
                        style: TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          hintText: 'Testo fronte della flashcard',
                          hintStyle: TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.flashcards, width: 2),
                          ),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Retro
                      const Text(
                        'Retro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const TextField(
                        style: TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          hintText: 'Testo retro della flashcard',
                          hintStyle: TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.flashcards, width: 2),
                          ),
                        ),
                        maxLines: 3,
                      ),
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
                    // Logica per salvare l'elemento
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.flashcards,
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

  // Widget per selezionare il tipo di elemento da aggiungere
  Widget _buildTypeSelector(String label, IconData icon, Color color) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: label == 'Flashcard', // Default selezionato
      selectedColor: color.withOpacity(0.2),
      backgroundColor: AppColors.backgroundGrey,
      labelStyle: TextStyle(
        color: label == 'Flashcard' ? color : AppColors.textMedium,
      ),
      onSelected: (selected) {
        // Cambia il tipo di elemento da aggiungere
      },
    );
  }

  // Sheet per aggiungere un nuovo evento al planner
  Widget _buildAddEventSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.4,
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
                  const Text(
                    'Aggiungi nuovo evento',
                    style: TextStyle(
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

              // Form
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titolo dell'evento
                      const TextField(
                        style: TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          labelText: 'Titolo',
                          labelStyle: TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.notes, width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Data e ora
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField('Data'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeField('Ora'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Descrizione
                      const TextField(
                        style: TextStyle(color: AppColors.textLight),
                        decoration: InputDecoration(
                          labelText: 'Descrizione',
                          labelStyle: TextStyle(color: AppColors.textMedium),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.notes, width: 2),
                          ),
                        ),
                        maxLines: 3,
                      ),
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
                    // Logica per salvare l'evento
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.notes,
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

  // Widget per selezionare il colore del corso
  Widget _buildColorSelector() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        return InkWell(
          onTap: () {
            // Seleziona questo colore
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget per selezionare l'icona del corso
  Widget _buildIconSelector() {
    final icons = [
      Icons.calculate,
      Icons.science,
      Icons.history_edu,
      Icons.computer,
      Icons.psychology,
      Icons.language,
      Icons.palette,
      Icons.sports_soccer,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: icons.map((icon) {
        return InkWell(
          onTap: () {
            // Seleziona questa icona
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Campo per selezionare una data
  Widget _buildDateField(String label) {
    return TextField(
      style: const TextStyle(color: AppColors.textLight),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMedium),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.notes, width: 2),
        ),
        suffixIcon:
            const Icon(Icons.calendar_today, color: AppColors.textMedium),
      ),
      readOnly: true,
      onTap: () {
        // Mostra selettore di data
      },
    );
  }

  // Campo per selezionare un'ora
  Widget _buildTimeField(String label) {
    return TextField(
      style: const TextStyle(color: AppColors.textLight),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMedium),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.notes, width: 2),
        ),
        suffixIcon: const Icon(Icons.access_time, color: AppColors.textMedium),
      ),
      readOnly: true,
      onTap: () {
        // Mostra selettore di ora
      },
    );
  }
}

// Item nella barra di navigazione inferiore
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colore basato sulla sezione
    final Color color =
        isSelected ? _getColorForLabel(label) : AppColors.textMedium;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Ottiene il colore appropriato per ciascuna sezione
  Color _getColorForLabel(String label) {
    switch (label) {
      case 'Libreria':
        return AppColors.primaryBlue;
      case 'Planner':
        return AppColors.notes;
      case 'Mappa':
        return AppColors.mindMaps;
      default:
        return AppColors.primaryBlue;
    }
  }
}
