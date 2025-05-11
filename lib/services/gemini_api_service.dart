import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> transcribeAudioWithGemini(String filePath) async {
  String apiKey = "AIzaSyBSzOIsn6c6s55DU9-jPoXJM-0tkaE_wQ0";
  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$apiKey',
  );
  final bytes = await File(filePath).readAsBytes();
  final base64Audio = base64Encode(bytes);

  final body = {
    "contents": [
      {
        "parts": [
          {"text": "Transcribe the following audio:"},
          {
            "inlineData": {
              "mimeType": "audio/mpeg",
              "data": base64Audio,
            }
          }
        ]
      }
    ]
  };

  final response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
        "No transcription found.";
  } else {
    throw Exception(
        "Failed to transcribe: ${response.statusCode} - ${response.body}");
  }
}
