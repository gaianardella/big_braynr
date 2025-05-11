import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/theme/app_colors.dart';
import 'models/ai_service.dart';


// Provider per le domande generate
final generatedQuestionsProvider =
    StateNotifierProvider<QuestionsNotifier, List<Question>>((ref) {
  return QuestionsNotifier();
});

// Notifier per gestire le domande generate
class QuestionsNotifier extends StateNotifier<List<Question>> {
  QuestionsNotifier() : super([]);

  void addQuestions(List<Question> questions) {
    state = [...state, ...questions];
  }

  void clearQuestions() {
    state = [];
  }
}

// Modello per una domanda generata
class Question {
  final String question;
  final String answer;

  Question({
    required this.question,
    required this.answer,
  });
}

class ChapterScreen extends ConsumerStatefulWidget {
  final String pdfPath;
  final String chapterTitle;

  const ChapterScreen({
    Key? key,
    required this.pdfPath,
    this.chapterTitle = "Capitolo", // Default title se non fornito
  }) : super(key: key);

  @override
  ConsumerState<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends ConsumerState<ChapterScreen> {
  final _aiService = AIService();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  String _selectedText = '';
  bool _isDrawerOpen = false;
  bool _isGeneratingQuestions = false;
  Offset? _tapPosition;

  // Helper method per determinare se siamo su un dispositivo mobile
  bool _isMobileDevice() {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;
    final isMobilePlatform = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
    return isSmallScreen || isMobilePlatform;
  }

  @override
  void initState() {
    super.initState();
    _pdfViewerController.addListener(() {
      // Listener per gli eventi del controller
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _showContextMenu(BuildContext context) {
    if (_selectedText.isEmpty) return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final size = MediaQuery.of(context).size;
    final relativePosition = RelativeRect.fromRect(
      Rect.fromLTWH(_tapPosition!.dx, _tapPosition!.dy, 0, 0),
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    showMenu(
      context: context,
      position: relativePosition,
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.highlight, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text('Evidenzia', style: TextStyle(color: AppColors.textLight)),
            ],
          ),
          onTap: () {
            _highlightSelectedText();
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.question_answer, color: AppColors.questions),
              SizedBox(width: 8),
              Text('Genera domande', style: TextStyle(color: AppColors.textLight)),
            ],
          ),
          onTap: () {
            _generateQuestions();
          },
        ),
      ],
      color: AppColors.cardDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _highlightSelectedText() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testo evidenziato'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _generateQuestions() async {
  if (_selectedText.isEmpty) return;

  setState(() {
    _isGeneratingQuestions = true;
    if (!_isDrawerOpen) {
      _isDrawerOpen = true;
    }
  });

  try {
    // Usa il servizio AI per generare le domande
    final questionsData = await _aiService.generateQuestions(_selectedText);
    
    // Converti i dati in oggetti Question definiti in questo file
    final List<Question> generatedQuestions = questionsData.map((data) => 
      Question(
        question: data['question']!,
        answer: data['answer']!,
      )
    ).toList();
    
    // Aggiungi le domande generate al provider
    ref.read(generatedQuestionsProvider.notifier).addQuestions(generatedQuestions);
    
  } catch (e) {
    debugPrint('Errore durante la generazione delle domande: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Errore: ${e.toString().replaceAll('Exception: ', '')}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  } finally {
    setState(() {
      _isGeneratingQuestions = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobileDevice();
    final questions = ref.watch(generatedQuestionsProvider);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(widget.chapterTitle, 
          style: TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.cardDark,
        iconTheme: IconThemeData(color: AppColors.textLight),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25;
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25;
            },
          ),
          IconButton(
            icon: Icon(Icons.question_answer),
            onPressed: () {
              setState(() {
                _isDrawerOpen = !_isDrawerOpen;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding attorno al contenuto
        child: Row(
          children: [
            // Contenitore del PDF con bordi arrotondati e dimensioni contenute
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(
                  right: _isDrawerOpen && !isMobile ? 16 : 0,
                ),
                // Clipping per mantenere i bordi arrotondati
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTapDown: _storePosition,
                    onLongPress: () => _showContextMenu(context),
                    child: SfPdfViewer.asset(
                      widget.pdfPath,
                      key: _pdfViewerKey,
                      controller: _pdfViewerController,
                      onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                        if (details.selectedText != null && details.selectedText!.isNotEmpty) {
                          setState(() {
                            _selectedText = details.selectedText!;
                          });
                        }
                      },
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      pageSpacing: 8,
                      enableDoubleTapZooming: true,
                      enableTextSelection: true,
                      onPageChanged: (PdfPageChangedDetails details) {
                        // Optional: Handle page change
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Drawer per le domande generate
            if (_isDrawerOpen && !isMobile)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 350,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(-3, 0),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(left: 0),
                child: _buildQuestionsDrawer(questions),
              ),
          ],
        ),
      ),
      
      // Drawer mobile (viene mostrato come overlay)
      endDrawer: isMobile && _isDrawerOpen
          ? Drawer(
              child: Container(
                color: AppColors.cardDark,
                child: _buildQuestionsDrawer(questions),
              ),
            )
          : null,
      
      // FAB per generare domande
      floatingActionButton: _selectedText.isNotEmpty
          ? FloatingActionButton(
              onPressed: _generateQuestions,
              backgroundColor: AppColors.questions,
              child: Icon(Icons.question_answer, color: Colors.white),
              tooltip: 'Genera domande dal testo selezionato',
            )
          : null,
    );
  }

  Widget _buildQuestionsDrawer(List<Question> questions) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.questions.withOpacity(0.2),
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Domande Generate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textMedium),
                  onPressed: () {
                    setState(() {
                      _isDrawerOpen = false;
                    });
                  },
                ),
              ],
            ),
          ),
          
          if (_isGeneratingQuestions)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.questions),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Generazione domande in corso...',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (questions.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.question_answer_outlined,
                      size: 64,
                      color: AppColors.textMedium,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Seleziona del testo e genera\ndomande per studiare meglio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return _buildQuestionCard(question, index);
                },
              ),
            ),
            
          // Pulsante per pulire le domande
          if (questions.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(generatedQuestionsProvider.notifier).clearQuestions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.questions,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Pulisci tutte le domande'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: AppColors.backgroundGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.questions.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          'Domanda ${index + 1}',
          style: TextStyle(
            color: AppColors.questions,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          question.question,
          style: TextStyle(
            color: AppColors.textLight,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        iconColor: AppColors.questions,
        collapsedIconColor: AppColors.textMedium,
        childrenPadding: EdgeInsets.all(16),
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risposta:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textMedium,
            ),
          ),
          SizedBox(height: 8),
          Text(
            question.answer,
            style: TextStyle(
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.copy,
                label: 'Copia',
                color: AppColors.textMedium,
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: 'D: ${question.question}\nR: ${question.answer}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copiato negli appunti'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.bookmark_border,
                label: 'Salva',
                color: AppColors.flashcards,
                onPressed: () {
                  // Logica per salvare la domanda come flashcard
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}