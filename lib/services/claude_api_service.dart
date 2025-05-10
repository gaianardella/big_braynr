// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../core/theme/app_colors.dart';

// // 1. File per il servizio API Claude
// // Salvare come 'services/claude_api_service.dart'

// class ClaudeApiService {
//   // URL dell'API Claude
//   final String apiUrl = 'https://api.anthropic.com/v1/messages';
  
//   // Chiave API (in una vera app, utilizza variabili d'ambiente)
//   final String apiKey = 'YOUR_CLAUDE_API_KEY';
  
//   /// Genera domande basate sul testo fornito
//   Future<List<Question>> generateQuestions(String text) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'X-API-Key': apiKey,
//           'anthropic-version': '2023-06-01',
//         },
//         body: jsonEncode({
//           'model': 'claude-3-sonnet-20240229',
//           'max_tokens': 1000,
//           'messages': [
//             {
//               'role': 'user',
//               'content': 'Genera 3 domande di studio significative con relative risposte basate sul seguente testo. Formatta la risposta come JSON con un array di oggetti, ognuno con "question" e "answer". Il testo è: $text'
//             }
//           ]
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final content = data['content'][0]['text'];
        
//         // Estrai il JSON dalla risposta di Claude
//         final jsonRegExp = RegExp(r'\{[\s\S]*\}');
//         final match = jsonRegExp.firstMatch(content);
        
//         if (match != null) {
//           final jsonStr = match.group(0);
//           final jsonData = jsonDecode(jsonStr!);
          
//           // Converti il JSON in oggetti Question
//           List<Question> questions = [];
//           for (var item in jsonData) {
//             questions.add(Question(
//               question: item['question'],
//               answer: item['answer'],
//             ));
//           }
          
//           return questions;
//         }
//         throw Exception('Formato di risposta non valido');
//       } else {
//         throw Exception('Errore API: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Errore durante la chiamata API: $e');
//     }
//   }
// }

// // 2. Modifiche al provider di navigazione
// // Aggiungi questo al file con i provider o nel app_shell.dart

// // Provider per la sezione selezionata nella navigazione
// final selectedSectionProvider = StateProvider<String>((ref) => 'library');

// // Provider per il PDF viewer
// final pdfViewerPathProvider = StateProvider<String?>((ref) => null);

// // 3. Aggiungi questa classe al file corso_model.dart

// class Question {
//   final String question;
//   final String answer;

//   Question({
//     required this.question,
//     required this.answer,
//   });
// }

// // 4. Modifiche alla classe AppShell
// // Modifica il metodo _getScreenForSection per includere il PDF Viewer

// Widget _getScreenForSection(String section, String? selectedCourseId) {
//   switch (section) {
//     case 'library':
//       return const LibraryScreen();
//     case 'planner':
//       return const StudyPlannerScreen();
//     case 'pdf_viewer':
//       // Se il path del PDF è impostato, mostra il PDF viewer
//       final pdfPath = ref.watch(pdfViewerPathProvider);
//       if (pdfPath != null) {
//         return PDFViewerScreen(pdfPath: pdfPath);
//       } else {
//         // Fallback alla libreria se non c'è un PDF selezionato
//         return const LibraryScreen();
//       }
//     default:
//       return const LibraryScreen();
//   }
// }

// // 5. Aggiungi un nuovo tile nella LibraryScreen
// // Aggiungi questo widget nella LibraryScreen

// class PDFDocumentTile extends StatelessWidget {
//   final String title;
//   final String pdfPath;
//   final IconData icon;
//   final Color color;

//   const PDFDocumentTile({
//     Key? key,
//     required this.title,
//     required this.pdfPath,
//     required this.icon,
//     required this.color,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         return InkWell(
//           onTap: () {
//             // Imposta il percorso del PDF e naviga alla sezione PDF viewer
//             ref.read(pdfViewerPathProvider.notifier).state = pdfPath;
//             ref.read(selectedSectionProvider.notifier).state = 'pdf_viewer';
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.cardDark,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppColors.border,
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     icon,
//                     color: color,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textLight,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Documento PDF',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textMedium,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Esempio di utilizzo in LibraryScreen
// // Aggiungi questo grid nella LibraryScreen

// Widget _buildPDFDocumentsGrid() {
//   return GridView.count(
//     crossAxisCount: 2,
//     crossAxisSpacing: 16,
//     mainAxisSpacing: 16,
//     shrinkWrap: true,
//     physics: const NeverScrollableScrollPhysics(),
//     children: [
//       PDFDocumentTile(
//         title: 'Dispensa di Matematica',
//         pdfPath: 'assets/pdf/matematica.pdf',
//         icon: Icons.calculate,
//         color: Colors.blue,
//       ),
//       PDFDocumentTile(
//         title: 'Appunti di Storia',
//         pdfPath: 'assets/pdf/storia.pdf',
//         icon: Icons.history_edu,
//         color: Colors.green,
//       ),
//       PDFDocumentTile(
//         title: 'Esperimenti di Fisica',
//         pdfPath: 'assets/pdf/fisica.pdf',
//         icon: Icons.science,
//         color: Colors.purple,
//       ),
//     ],
//   );
// }