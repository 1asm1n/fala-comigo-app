import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stacked/stacked.dart';

class ChatbotViewModel extends BaseViewModel {
  final String _apiToken = dotenv.env['HF_API_KEY']!;
  final String _apiUrl = dotenv.env['HF_MODEL_URL']!;

  List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  Future<void> sendMessage(String userMessage) async {
    _messages.add({
      'sender': 'user',
      'text': userMessage,
      'time': DateTime.now().toIso8601String(),
    });
    notifyListeners();

    // Placeholder "Escrevendo..."
    _messages.add({
      'sender': 'bot',
      'text': 'Escrevendo...',
      'time': DateTime.now().toIso8601String(),
    });
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        /* body: jsonEncode({
          'inputs': userMessage,
          'parameters': {
            'temperature': 0.7,
            'max_new_tokens': 300,
          }
        }),*/

        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": "What is the meaning of life?"}
          ]
        }),
      );
      if (response.statusCode >= 400) {
        log(response.body);
      }
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        final generatedText = decoded['generated_text'] ??
            (decoded is List && decoded.isNotEmpty
                ? decoded[0]['generated_text']
                : "Resposta não disponível.");

        // Remove o "Escrevendo..." antes
        if (_messages.isNotEmpty && _messages.last['text'] == 'Escrevendo...') {
          _messages.removeLast();
        }

        _messages.add({
          'sender': 'bot',
          'text': generatedText.trim(),
          'time': DateTime.now().toIso8601String(),
        });
      } else {
        if (_messages.isNotEmpty && _messages.last['text'] == 'Escrevendo...') {
          _messages.removeLast();
        }
        _messages.add({
          'sender': 'system',
          'text': 'Erro na API: ${response.statusCode}',
          'time': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (_messages.isNotEmpty && _messages.last['text'] == 'Escrevendo...') {
        _messages.removeLast();
      }
      _messages.add({
        'sender': 'system',
        'text': 'Erro de conexão: $e',
        'time': DateTime.now().toIso8601String(),
      });
    }

    notifyListeners();
  }
}
