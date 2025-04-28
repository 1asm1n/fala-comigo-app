import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stacked/stacked.dart';

class ChatbotViewModel extends BaseViewModel {
  final String _apiToken = dotenv.env['HF_API_KEY']!;
  final String _apiUrl = dotenv.env['HF_MODEL_URL']!;

  final List<Map<String, String>> _messages = [];
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

//todo: na requisicao, colocar o historico da conversa ao inves de só a ultiam mensagem, para implementar o modelo
//em TODAS as requisições o primeiro prompt deve ser a implementação do modelo (finja que você é o taskito blablabla)
//todo: criar modelo taskito (que da sugestoes de tarefas para os pais)
    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": userMessage}
          ]
        }),
      );
      if (response.statusCode >= 400) {
        log(response.body);
      }
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
//content = response["choices"][0]["message"]["content"]
        final generatedText = decoded['choices'][0]["message"]["content"];

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
