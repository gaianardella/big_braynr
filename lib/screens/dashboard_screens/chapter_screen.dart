import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';

// Provider per il paragrafo selezionato
final selectedParagraphProvider = StateProvider<String?>((ref) => null);

// Provider per le note associate ai paragrafi
final paragraphNotesProvider = StateProvider<Map<String, List<NoteModel>>>((ref) {
  return {
    'p1': [
      NoteModel(
        id: '1',
        content: 'Questi concetti sono fondamentali per capire il resto del capitolo.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        color: Colors.yellow.shade200,
      ),
      NoteModel(
        id: '2',
        content: 'Da collegare con il capitolo 3 quando si parla di applicazioni.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        color: Colors.green.shade100,
      ),
    ],
    'p3': [
      NoteModel(
        id: '3',
        content: 'Questa formula è molto importante per l\'esame!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        color: Colors.orange.shade100,
      ),
    ],
    'p5': [
      NoteModel(
        id: '4',
        content: 'Cercare approfondimenti su questo argomento.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        color: Colors.blue.shade100,
      ),
      NoteModel(
        id: '5',
        content: 'Chiedere al professore chiarimenti su questo punto durante la prossima lezione.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        color: Colors.purple.shade100,
      ),
    ],
  };
});

// Provider per la modalità corrente della toolbar
final toolbarModeProvider = StateProvider<ToolbarMode>((ref) => ToolbarMode.view);

// Classe per le note
class NoteModel {
  final String id;
  final String content;
  final DateTime timestamp;
  final Color color;

  NoteModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.color,
  });
}

// Enum per le modalità della toolbar
enum ToolbarMode {
  view,
  highlight,
  pen,
  note,
  bookmark,
}

class StudyWorkspaceScreen extends ConsumerWidget {
  final String courseId;
  final String chapterId;
  // final String lessonId;

  const StudyWorkspaceScreen({
    super.key,
    required this.courseId,
    required this.chapterId,
    // required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParagraph = ref.watch(selectedParagraphProvider);
    final toolbarMode = ref.watch(toolbarModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Capitolo 2: Concetti di Base',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppColors.textLight),
            onPressed: () {
              // Implementare la logica dei segnalibri
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textLight),
            onPressed: () {
              // Implementare la logica di condivisione
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textLight),
            onPressed: () {
              // Mostrare menu opzioni
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar personalizzata per la manipolazione del PDF
          _buildToolbar(context, toolbarMode, ref),
          
          // Area di lavoro principale
          Expanded(
            child: Row(
              children: [
                // Visualizzazione PDF
                Expanded(
                  flex: 3,
                  child: _buildPdfView(context, ref),
                ),
                
                // Separatore verticale
                Container(
                  width: 1,
                  color: AppColors.border,
                ),
                
                // Pannello delle note (visibile solo quando un paragrafo è selezionato)
                if (selectedParagraph != null)
                  Expanded(
                    flex: 2,
                    child: _buildNotesPanel(context, selectedParagraph, ref),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          // Aggiungi nuova nota al paragrafo selezionato
          if (selectedParagraph != null) {
            _showAddNoteDialog(context, selectedParagraph, ref);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seleziona prima un paragrafo per aggiungere una nota'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildToolbar(BuildContext context, ToolbarMode currentMode, WidgetRef ref) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          
          // Modalità visualizzazione
          _buildToolbarButton(
            icon: Icons.visibility_outlined,
            label: 'Visualizza',
            isSelected: currentMode == ToolbarMode.view,
            onPressed: () => ref.read(toolbarModeProvider.notifier).state = ToolbarMode.view,
          ),
          
          const VerticalDivider(
            width: 24,
            thickness: 1,
            indent: 12,
            endIndent: 12,
            color: AppColors.border,
          ),
          
          // Modalità evidenziazione
          _buildToolbarButton(
            icon: Icons.highlight_alt,
            label: 'Evidenzia',
            isSelected: currentMode == ToolbarMode.highlight,
            onPressed: () => ref.read(toolbarModeProvider.notifier).state = ToolbarMode.highlight,
          ),
          
          // Modalità penna
          _buildToolbarButton(
            icon: Icons.edit_outlined,
            label: 'Scrivi',
            isSelected: currentMode == ToolbarMode.pen,
            onPressed: () => ref.read(toolbarModeProvider.notifier).state = ToolbarMode.pen,
          ),
          
          // Modalità note
          _buildToolbarButton(
            icon: Icons.note_add_outlined,
            label: 'Note',
            isSelected: currentMode == ToolbarMode.note,
            onPressed: () => ref.read(toolbarModeProvider.notifier).state = ToolbarMode.note,
          ),
          
          // Modalità segnalibro
          _buildToolbarButton(
            icon: Icons.bookmark_border_outlined,
            label: 'Segnalibro',
            isSelected: currentMode == ToolbarMode.bookmark,
            onPressed: () => ref.read(toolbarModeProvider.notifier).state = ToolbarMode.bookmark,
          ),
          
          const Spacer(),
          
          // Controlli di navigazione
          IconButton(
            icon: const Icon(Icons.navigate_before, color: AppColors.textMedium),
            tooltip: 'Pagina precedente',
            onPressed: () {
              // Navigare alla pagina precedente
            },
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text(
              'Pag. 4 di 28',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 14,
              ),
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.navigate_next, color: AppColors.textMedium),
            tooltip: 'Pagina successiva',
            onPressed: () {
              // Navigare alla pagina successiva
            },
          ),
          
          const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    final color = isSelected ? AppColors.primaryBlue : AppColors.textMedium;
    
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPdfView(BuildContext context, WidgetRef ref) {
    // Simulare il contenuto di un PDF con paragrafi interattivi
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo del capitolo
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Concetti di Base',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Immagine introduttiva
            Container(
              width: double.infinity,
              height: 220,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
            
            // Paragrafi del documento
            _buildSelectableParagraph(
              'p1',
              'In questa sezione introduciamo i concetti fondamentali che costituiscono la base della materia. Questi elementi forniscono il framework concettuale necessario per comprendere i capitoli successivi e le applicazioni pratiche. È importante familiarizzare con le definizioni e i principi qui esposti prima di procedere.',
              isHighlighted: true,
              highlightColor: Colors.yellow.withOpacity(0.3),
              ref: ref,
            ),
            
            const SizedBox(height: 16),
            
            _buildSelectableParagraph(
              'p2',
              'La struttura logica della disciplina si articola in diversi livelli di astrazione, partendo dagli assiomi fondamentali fino ad arrivare alle derivazioni più complesse. Questo approccio permette di costruire un sistema coerente in cui ogni elemento è giustificato da quelli precedenti.',
              ref: ref,
            ),
            
            const SizedBox(height: 16),
            
            // Paragrafo con formula
            _buildSelectableParagraph(
              'p3',
              'Di particolare importanza è la relazione fondamentale espressa dalla formula:',
              ref: ref,
            ),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Center(
                child: Text(
                  'E = mc²',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            
            _buildSelectableParagraph(
              'p4',
              'Questa equazione stabilisce una corrispondenza diretta tra massa ed energia, ed è alla base di numerose applicazioni tecnologiche contemporanee, nonché fondamento teorico per sviluppi successivi.',
              ref: ref,
            ),
            
            const SizedBox(height: 16),
            
            _buildSelectableParagraph(
              'p5',
              'Le implicazioni di questi principi si estendono a numerosi campi, dalla fisica teorica alle applicazioni ingegneristiche, passando per la chimica e la biologia molecolare. La versatilità di questi concetti ne dimostra la centralità nel panorama scientifico contemporaneo.',
              isHighlighted: true,
              highlightColor: Colors.green.withOpacity(0.2),
              ref: ref,
            ),
            
            const SizedBox(height: 16),
            
            // Elenco puntato
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Principali applicazioni:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            _buildBulletPoint('Generazione di energia', ref),
            _buildBulletPoint('Sviluppo di nuovi materiali', ref),
            _buildBulletPoint('Analisi strutturale', ref),
            _buildBulletPoint('Modellazione predittiva', ref),
            
            const SizedBox(height: 24),
            
            _buildSelectableParagraph(
              'p6',
              'Nelle prossime sezioni approfondiremo ciascuna di queste aree, fornendo esempi concreti e casi di studio che illustrano l\'applicazione pratica dei principi qui esposti. È consigliabile consolidare la comprensione di questi concetti prima di procedere oltre.',
              ref: ref,
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBulletPoint(String text, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectableParagraph(
    String id,
    String text, {
    bool isHighlighted = false,
    Color highlightColor = Colors.transparent,
    required WidgetRef ref,
  }) {
    final selectedParagraph = ref.watch(selectedParagraphProvider);
    final isSelected = selectedParagraph == id;
    
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // Deseleziona se già selezionato
          ref.read(selectedParagraphProvider.notifier).state = null;
        } else {
          // Seleziona questo paragrafo
          ref.read(selectedParagraphProvider.notifier).state = id;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isHighlighted ? highlightColor : (isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent),
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(color: Colors.blue.shade300) : null,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotesPanel(BuildContext context, String paragraphId, WidgetRef ref) {
    final notesMap = ref.watch(paragraphNotesProvider);
    final notes = notesMap[paragraphId] ?? [];
    
    return Container(
      color: AppColors.backgroundGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Intestazione del pannello delle note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Note del paragrafo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textLight),
                  onPressed: () {
                    ref.read(selectedParagraphProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          
          // Lista delle note
          Expanded(
            child: notes.isEmpty
                ? const Center(
                    child: Text(
                      'Nessuna nota per questo paragrafo',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return _buildNoteCard(context, note, ref, paragraphId);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoteCard(
    BuildContext context,
    NoteModel note,
    WidgetRef ref,
    String paragraphId,
  ) {
    // Formatta la data/ora della nota
    final timestamp = note.timestamp;
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    String formattedTime;
    if (difference.inDays > 0) {
      formattedTime = '${difference.inDays} giorni fa';
    } else if (difference.inHours > 0) {
      formattedTime = '${difference.inHours} ore fa';
    } else if (difference.inMinutes > 0) {
      formattedTime = '${difference.inMinutes} minuti fa';
    } else {
      formattedTime = 'Poco fa';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: note.color,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.edit, color: Colors.black54),
                      onPressed: () {
                        _showEditNoteDialog(context, note, paragraphId, ref);
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.delete, color: Colors.black54),
                      onPressed: () {
                        _showDeleteNoteDialog(context, note, paragraphId, ref);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddNoteDialog(BuildContext context, String paragraphId, WidgetRef ref) {
    final textController = TextEditingController();
    Color selectedColor = Colors.yellow.shade100;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Aggiungi Nota'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Scrivi la tua nota...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                const Text('Colore:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColorOption(Colors.yellow.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.green.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.blue.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.orange.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.purple.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Annulla'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('Salva'),
                onPressed: () {
                  final noteText = textController.text.trim();
                  if (noteText.isNotEmpty) {
                    // Aggiungi la nota
                    final notesMap = ref.read(paragraphNotesProvider);
                    final notes = List<NoteModel>.from(notesMap[paragraphId] ?? []);
                    
                    notes.add(NoteModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      content: noteText,
                      timestamp: DateTime.now(),
                      color: selectedColor,
                    ));
                    
                    // Aggiorna il provider
                    ref.read(paragraphNotesProvider.notifier).state = {
                      ...notesMap,
                      paragraphId: notes,
                    };
                    
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildColorOption(Color color, Color selectedColor, Function(Color) onSelect) {
    final isSelected = color == selectedColor;
    
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }
  
  void _showEditNoteDialog(
    BuildContext context,
    NoteModel note,
    String paragraphId,
    WidgetRef ref,
  ) {
    final textController = TextEditingController(text: note.content);
    Color selectedColor = note.color;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Modifica Nota'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Scrivi la tua nota...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                const Text('Colore:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColorOption(Colors.yellow.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.green.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.blue.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.orange.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                    _buildColorOption(Colors.purple.shade100, selectedColor, (color) {
                      setState(() => selectedColor = color);
                    }),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Annulla'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('Salva'),
                onPressed: () {
                  final noteText = textController.text.trim();
                  if (noteText.isNotEmpty) {
                    // Modifica la nota
                    final notesMap = ref.read(paragraphNotesProvider);
                    final notes = List<NoteModel>.from(notesMap[paragraphId] ?? []);
                    
                    final index = notes.indexWhere((n) => n.id == note.id);
                    if (index != -1) {
                      notes[index] = NoteModel(
                        id: note.id,
                        content: noteText,
                        timestamp: DateTime.now(),
                        color: selectedColor,
                      );
                      
                      // Aggiorna il provider
                      ref.read(paragraphNotesProvider.notifier).state = {
                        ...notesMap,
                        paragraphId: notes,
                      };
                    }
                    
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showDeleteNoteDialog(
    BuildContext context,
    NoteModel note,
    String paragraphId,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminare la nota?'),
        content: const Text('Sei sicuro di voler eliminare questa nota? L\'azione è irreversibile.'),
        actions: [
          TextButton(
            child: const Text('Annulla'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
            onPressed: () {
              // Elimina la nota
              final notesMap = ref.read(paragraphNotesProvider);
              final notes = List<NoteModel>.from(notesMap[paragraphId] ?? []);
              
              notes.removeWhere((n) => n.id == note.id);
              
              // Aggiorna il provider
              ref.read(paragraphNotesProvider.notifier).state = {
                ...notesMap,
                paragraphId: notes,
              };
              
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
  
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.download_outlined),
              title: Text('Scarica PDF'),
            ),
            const ListTile(
              leading: Icon(Icons.print_outlined),
              title: Text('Stampa'),
            ),
            const ListTile(
              leading: Icon(Icons.fullscreen_outlined),
              title: Text('Vista a schermo intero'),
            ),
            const ListTile(
              leading: Icon(Icons.font_download_outlined),
              title: Text('Impostazioni font'),
            ),
            const ListTile(
              leading: Icon(Icons.search),
              title: Text('Cerca nel documento'),
            ),
            const ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Aiuto'),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfViewerScreen extends ConsumerWidget {
  final String courseId;
  final String chapterId;
  final String lessonId;

  const PdfViewerScreen({
    super.key,
    required this.courseId,
    required this.chapterId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudyWorkspaceScreen(
      courseId: courseId,
      chapterId: chapterId,
      // lessonId: lessonId,
    );
  }
}