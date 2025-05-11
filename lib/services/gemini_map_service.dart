import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ConceptualMapService {
  // Hardcoded API key
  static const String _apiKey = 'pippo';

  // List of asset PDF files
  static const List<String> _pdfAssets = [
    'assets/pdf/DS-5-consensus.pdf',
    'assets/pdf/paxos-simple.pdf',
    'assets/pdf/raft.pdf',
  ];

  Future<String> generateConceptualMap() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro-latest',
        apiKey: _apiKey,
      );

      if (_pdfAssets.isEmpty) {
        return 'No PDF assets defined.';
      }

      final extractedTexts = await Future.wait(
        _pdfAssets.map((assetPath) => _extractTextWithSyncfusion(assetPath)),
      );

      final combinedText = extractedTexts.join('\n\n---\n\n');
      return await _generateMapFromText(model, combinedText);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> _extractTextWithSyncfusion(String assetPath) async {
    try {
      final ByteData bytes = await rootBundle.load(assetPath);
      final PdfDocument document =
          PdfDocument(inputBytes: bytes.buffer.asUint8List());

      String text = '';
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        text += extractor.extractText(startPageIndex: i, endPageIndex: i);
        text += '\n\n';
      }

      document.dispose();
      return text;
    } catch (e) {
      print('PDF extraction error for $assetPath: ${e.toString()}');
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
