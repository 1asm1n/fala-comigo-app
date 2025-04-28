import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

class ChatbotViewModel extends BaseViewModel {
  final String _apiToken = dotenv.env['HF_API_KEY']!;
  final List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;
//prompt inicial p todas as conversas
  static const String _welcomeMessage = '''
Sou o Taskito! Estou aqui para te ajudar a encontrar tarefas educativas para seus filhos.

Posso sugerir atividades por idade, tipo de desenvolvimento (motor, cognitivo, emocional) ou tema específico. Como posso te ajudar hoje?
''';

  static const String _systemPrompt = '''
Você é o Taskito, um assistente especializado em orientar pais com sugestões de tarefas educativas, criativas e responsáveis para seus filhos. 

REGRAS ABSOLUTAS:
1. Na PRIMEIRA MENSAGEM de cada conversa, comece com: "Sou o Taskito! Estou aqui para te ajudar a encontrar tarefas educativas para seus filhos."
2. Nas demais mensagens, responda diretamente com sugestões práticas.
3. NUNCA responda perguntas fora do contexto de educação infantil e parentalidade.
4. SEMPRE sugira atividades práticas, educativas e divertidas.
5. MANTENHA as respostas breves, claras e gentis, com exemplos práticos.

Se receber perguntas fora do contexto, responda educadamente: "Como especialista em tarefas para crianças, só posso ajudar com sugestões nessa área."
''';

  // começando conversa nova
  ChatbotViewModel() {
    _initializeConversation();
  }

  // inicializando quando recarrega a pagina
  void startNewConversation() {
    _messages.clear();
    _initializeConversation();
    notifyListeners();
  }

  // inicializando normal
  void _initializeConversation() {
    _messages.add({
      'sender': 'bot',
      'text': _welcomeMessage,
      'time': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendMessage(String userMessage) async {
    _messages.add({
      'sender': 'user',
      'text': userMessage,
      'time': DateTime.now().toIso8601String(),
    });
    notifyListeners();

    final placeholderIndex = _messages.length;
    _messages.add({
      'sender': 'bot',
      'text': 'Escrevendo...',
      'time': DateTime.now().toIso8601String(),
    });
    notifyListeners();

    try {
      final conversation = [
        {'role': 'system', 'content': _systemPrompt},
        ..._messages
            .sublist(0, _messages.length - 2)
            .map((message) => {
                  'role': message['sender'] == 'user' ? 'user' : 'assistant',
                  'content': message['text'] ?? '',
                })
            .toList(),
        {'role': 'user', 'content': userMessage},
      ];
//implementacao da api
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "messages": conversation,
          "temperature":
              0.3, //emburrecendo o chat pra ele nao ficar generalista
        }),
      );

      if (_messages.length > placeholderIndex &&
          _messages[placeholderIndex]['text'] == 'Escrevendo...') {
        _messages.removeAt(placeholderIndex);
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final generatedText =
            decoded['choices'][0]["message"]["content"].trim();

        _messages.add({
          'sender': 'bot',
          'text': generatedText,
          'time': DateTime.now().toIso8601String(),
        });
      } else {
        //tratamento de erro
        _messages.add({
          'sender': 'system',
          'text':
              'Desculpe, estou tendo dificuldades. Por favor, tente novamente.',
          'time': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (_messages.length > placeholderIndex &&
          _messages[placeholderIndex]['text'] == 'Escrevendo...') {
        _messages.removeAt(placeholderIndex);
      }
      _messages.add({
        'sender': 'system',
        'text': 'Erro de conexão. Por favor, verifique sua internet.',
        'time': DateTime.now().toIso8601String(),
      });
    }

    notifyListeners();
  }
}
