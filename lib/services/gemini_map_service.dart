import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ConceptualMapService {
  // Hardcoded values as requested
  static const String _apiKey = 'pippo';
  static const String _pdfDirectory =
      r'C:\Users\Rick\Desktop\big_braynr\assets\pdf';

  Future<String> generateConceptualMap() async {
    try {
      // Initialize model with hardcoded API key
      final model = GenerativeModel(
        model: 'gemini-1.5-pro-latest',
        apiKey: _apiKey,
      );

      // Get PDF files from hardcoded directory
      final pdfFiles = await _getPdfFiles();
      if (pdfFiles.isEmpty) {
        return 'No PDF files found in the directory.';
      }

      // Process PDFs with Syncfusion text extraction
      final extractedTexts = await Future.wait(
        pdfFiles.map((file) => _extractTextWithSyncfusion(file)),
      );

      // Generate map
      final combinedText = extractedTexts.join('\n\n---\n\n');
      return await _generateMapFromText(model, combinedText);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<List<File>> _getPdfFiles() async {
    final directory = Directory(_pdfDirectory);
    if (!await directory.exists()) {
      return [];
    }

    return directory
        .list()
        .where((entity) => entity.path.toLowerCase().endsWith('.pdf'))
        .map((entity) => File(entity.path))
        .toList();
  }

  Future<String> _extractTextWithSyncfusion(File file) async {
    try {
      // Load the PDF document
      final PdfDocument document =
          PdfDocument(inputBytes: await file.readAsBytes());

      // Extract text from all pages
      String text = '';
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        text += extractor.extractText(startPageIndex: i, endPageIndex: i);
        text += '\n\n'; // Add spacing between pages
      }

      // Dispose the document
      document.dispose();
      return text;
    } catch (e) {
      print('PDF extraction error for ${file.path}: ${e.toString()}');
      return 'PDF extraction failed: ${e.toString()}';
    }
  }

  Future<String> _generateMapFromText(
      GenerativeModel model, String text) async {
    try {
      final prompt = '''
      Create a comprehensive conceptual map in markdown format from this content:

      Requirements:
      - Use hierarchical structure with H2 headings for main concepts
      - Include H3 subheadings for key points
      - Show relationships between concepts with arrows (→)
      - Use bullet points for details
      - Keep the output well-organized and readable

      Content to analyze:
      ${text.length > 30000 ? text.substring(0, 30000) + '... [truncated]' : text}
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No content generated';
    } catch (e) {
      throw Exception('Generation failed: ${e.toString()}');
    }
  }
}
