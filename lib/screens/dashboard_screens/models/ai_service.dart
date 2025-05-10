import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class _QuestionDTO {
  final String question;
  final String answer;

  _QuestionDTO({
    required this.question,
    required this.answer,
  });

  Map<String, String> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}

class AIService {
  static final AIService _instance = AIService._internal();
  final Dio _dio = Dio();
  String? _apiKey;

  factory AIService() {
    return _instance;
  }

  AIService._internal() {
    _init();
  }

  void _init() {
    _apiKey = dotenv.env['ANTHROPIC_API_KEY'];
    _dio.options.baseUrl = 'https://api.anthropic.com/v1';
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'x-api-key': _apiKey,
      'anthropic-version': '2023-06-01',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  /// Genera domande di comprensione basate sul testo selezionato
  /// Restituisce una lista di Map con chiavi 'question' e 'answer'
  Future<List<Map<String, String>>> generateQuestions(String selectedText) async {
    try {
      // Verifica che l'API key sia stata caricata
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception('API key non trovata. Assicurati che il file .env contenga ANTHROPIC_API_KEY.');
      }

      // Costruisci il prompt per Claude
      final String promptText = '''
      Basandoti sul seguente testo estratto da un libro di studio:
      
      "$selectedText"
      
      Genera 3 domande di comprensione che aiuterebbero uno studente a testare la propria conoscenza dei concetti chiave. 
      Per ogni domanda, fornisci anche una risposta completa.
      
      Rispondi SOLO in formato JSON con un array di oggetti, dove ogni oggetto ha due proprietà: "question" e "answer".
      Non fornire spiegazioni aggiuntive, solo JSON valido.
      ''';
      
      // Costruisci il corpo della richiesta
      final Map<String, dynamic> requestBody = {
        'model': 'claude-3-5-sonnet-20241022',
        'max_tokens': 4000,
        'system': 'Rispondi solo in formato JSON valido senza spiegazioni aggiuntive.',
        'messages': [
          {
            'role': 'user',
            'content': promptText,
          }
        ],
      };


      
      // Stampa il corpo della richiesta per debug
      if (kDebugMode) {
        print('REQUEST BODY:');
        print(const JsonEncoder.withIndent('  ').convert(requestBody));
        print('HEADERS:');
        print(_dio.options.headers);
      }
      
      // Effettua la richiesta HTTP con Dio
      final response = await _dio.post(
        '/messages',
        data: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (kDebugMode) {
          print('💬 Claude response status: ${response.statusCode}');
          print('💬 Claude raw body:');
          if (response.data is String) {
            print(response.data);
          } else {
            print(const JsonEncoder.withIndent('  ').convert(response.data));
          }
        }

        
        // Estrai il contenuto dalla risposta
        String content = '';
        if (responseData['content'] != null && responseData['content'] is List && responseData['content'].isNotEmpty) {
          content = responseData['content'][0]['text'] ?? '';
        } else {
          throw Exception('Formato di risposta non valido o inaspettato');
        }
        
        // Estrai il JSON dalla risposta
        final String jsonString = _extractJsonFromText(content);
        if (jsonString.isEmpty) {
          throw Exception('Impossibile estrarre JSON dalla risposta');
        }
        
        final List<dynamic> jsonData = jsonDecode(jsonString);
        
        // Converti in lista di Map<String, String>
        return jsonData.map<Map<String, String>>((item) => {
          'question': item['question'] ?? 'Domanda non disponibile',
          'answer': item['answer'] ?? 'Risposta non disponibile',
        }).toList();
      } else {
        throw Exception('Errore nella chiamata API: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Dio error: ${e.message}');
        print('Dio error status code: ${e.response?.statusCode}');
        print('Dio error response data: ${const JsonEncoder.withIndent('  ').convert(e.response?.data ?? {})}');
        print('Dio error request: ${const JsonEncoder.withIndent('  ').convert(e.requestOptions.data ?? {})}');
        print('Dio error request headers: ${e.requestOptions.headers}');
        print('Dio error request path: ${e.requestOptions.path}');
      }
      
      String errorMessage = 'Errore di connessione durante la chiamata a Claude API';
      
      // Estrai un messaggio di errore più specifico se disponibile
      if (e.response?.data != null && e.response?.data['error'] != null) {
        final error = e.response?.data['error'];
        if (error['message'] != null) {
          errorMessage = 'Errore API Claude: ${error['message']}';
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('Errore nella generazione delle domande: $e');
      }
      throw Exception('Errore durante la generazione delle domande: $e');
    }
  }
  
  // Helper per estrarre JSON valido dal testo
  String _extractJsonFromText(String text) {
    try {
      // Prima verifica: se il testo è già un JSON valido, restituiscilo
      if (text.trim().startsWith('[') && text.trim().endsWith(']')) {
        // Tentiamo di analizzare direttamente
        jsonDecode(text.trim());
        return text.trim();
      }
      
      // Seconda verifica: cerca di trovare array JSON tra parentesi quadre
      final RegExp jsonRegex = RegExp(r'\[\s*\{.*?\}\s*\]', dotAll: true);
      final Match? match = jsonRegex.firstMatch(text);
      
      if (match != null) {
        final String potentialJson = match.group(0) ?? '[]';
        // Verifica che sia un JSON valido
        jsonDecode(potentialJson);
        return potentialJson;
      }
      
      // Terza verifica: cerca di trovare qualsiasi cosa che assomigli a JSON
      final RegExp anyJsonRegex = RegExp(r'(\{.*\}|\[.*\])', dotAll: true);
      final Match? anyMatch = anyJsonRegex.firstMatch(text);
      
      if (anyMatch != null) {
        final String potentialJson = anyMatch.group(0) ?? '[]';
        // Verifica che sia un JSON valido
        jsonDecode(potentialJson);
        return potentialJson;
      }
      
      // Fallback: restituisci stringa vuota
      if (kDebugMode) {
        print('Impossibile estrarre JSON da: $text');
      }
      return '';
    } catch (e) {
      if (kDebugMode) {
        print('Errore durante l\'estrazione del JSON: $e');
      }
      return '';
    }
  }
  
  // Metodo di test per verificare la connessione all'API
  Future<bool> testConnection() async {
    try {
      // Verifica che l'API key sia stata caricata
      if (_apiKey == null || _apiKey!.isEmpty) {
        if (kDebugMode) {
          print('API key non trovata per il test di connessione');
        }
        return false;
      }
      
      final Map<String, dynamic> requestBody = {
        'model': 'claude-3-5-sonnet-20241022',
        'max_tokens': 4000,
        'messages': [
          {
            'role': 'user',
            'content': 'Rispondi solo con la parola "ok"',
          }
        ],
      };
      
      // Stampa il corpo della richiesta di test per debug
      if (kDebugMode) {
        print('TEST CONNECTION REQUEST BODY:');
        print(const JsonEncoder.withIndent('  ').convert(requestBody));
        print('HEADERS:');
        print(_dio.options.headers);
      }
      
      final response = await _dio.post(
        '/messages',
        data: jsonEncode(requestBody),
      );
      
      if (kDebugMode && response.statusCode == 200) {
        print('Test connessione riuscito:');
        print(const JsonEncoder.withIndent('  ').convert(response.data));
      }
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Test connessione fallito - Dio error: ${e.message}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${const JsonEncoder.withIndent('  ').convert(e.response?.data ?? {})}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Test connessione fallito - Errore generico: $e');
      }
      return false;
    }
  }
}