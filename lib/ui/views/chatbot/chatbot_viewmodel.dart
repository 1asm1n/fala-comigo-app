import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

class ChatbotViewModel extends BaseViewModel {
  final String _apiToken = dotenv.env['HF_API_KEY']!;
  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  static const String _welcomeMessage = '''
Olá, sou o Taskito! Serei seu assistente no Taskplay.
Estou aqui para ajudar com qualquer dúvida sobre o app ou educação positiva, e te dar sugestões personalizadas de tarefas, consequências, etc. Tem dúvidas ou precisa de ideias? Pergunte! Vamos tornar a aprendizagem do seu filho mais divertida e positiva juntos!
''';

  static const String _systemPrompt = '''
Você é o Taskito, um assistente especializado em orientar pais com sugestões de tarefas educativas, criativas e responsáveis para seus filhos. 

REGRAS ABSOLUTAS:
1. Quando o usuário pedir uma rotina ou múltiplas tarefas, SEMPRE retorne uma lista de tarefas
2. Para cada tarefa, inclua um JSON no formato: {"title": "Nome da tarefa", "coins": valor}
Exemplo para uma tarefa: [ {"title": "Lavar a louça", "coins": 50}] 
4. Exemplo para múltiplas tarefas:
   [{"title": "Arrumar a cama", "coins": 30}, {"title": "Lavar a louça", "coins": 50}]

VALORES DE MOEDAS:
- Tarefas simples: 20-50 moedas
- Tarefas moderadas: 50-100 moedas
- Tarefas complexas: 100-150 moedas
- Tarefas desafiadoras: 150-200 moedas
''';

  ChatbotViewModel() {
    _initializeConversation();
  }

  void startNewConversation() {
    _messages.clear();
    _initializeConversation();
    notifyListeners();
  }

  void _initializeConversation() {
    _messages.add({
      'sender': 'bot',
      'text': _welcomeMessage,
      'time': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>>? _extractTasksInfo(String text) {
    try {
      // Captura TODOS os objetos JSON do tipo { ... }, inclusive numerados
      final jsonPattern = RegExp(
          r'\{\s*"title"\s*:\s*".+?",\s*"coins"\s*:\s*\d+\s*\}',
          dotAll: true);
      final matches = jsonPattern.allMatches(text);

      if (matches.isNotEmpty) {
        final tasksList = matches.map((match) {
          final jsonString = match.group(0)!;
          final task = jsonDecode(jsonString);

          final coins = int.tryParse(task['coins'].toString()) ?? 100;
          final adjustedCoins = coins.clamp(20, 200);

          return {
            'title': task['title'].toString(),
            'coins': adjustedCoins,
            'isEditing': false,
            'tempTitle': task['title'].toString(),
            'tempCoins': adjustedCoins.toString(),
          };
        }).toList();

        return tasksList;
      }

      return null;
    } catch (e) {
      print('Erro ao extrair tarefas: $e');
      return null;
    }
  }

  void editTask(int messageIndex, int taskIndex) {
    final tasks =
        _messages[messageIndex]['tasks'] as List<Map<String, dynamic>>;
    tasks[taskIndex]['isEditing'] = true;
    notifyListeners();
  }

  void updateTask(
      int messageIndex, int taskIndex, String newTitle, String newCoins) {
    final tasks =
        _messages[messageIndex]['tasks'] as List<Map<String, dynamic>>;
    final coins = int.tryParse(newCoins) ?? 100;
    final adjustedCoins = coins.clamp(20, 200);

    tasks[taskIndex]['title'] = newTitle;
    tasks[taskIndex]['coins'] = adjustedCoins;
    tasks[taskIndex]['isEditing'] = false;
    notifyListeners();
  }

  void deleteTask(int messageIndex, int taskIndex) {
    final tasks =
        _messages[messageIndex]['tasks'] as List<Map<String, dynamic>>;
    tasks.removeAt(taskIndex);
    if (tasks.isEmpty) {
      _messages.removeAt(messageIndex);
    }
    notifyListeners();
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

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
            .where((msg) =>
                msg['sender'] != 'bot' || msg['text'] != 'Escrevendo...')
            .map((message) => {
                  'role': message['sender'] == 'user' ? 'user' : 'assistant',
                  'content': message['text'] ?? '',
                }),
      ];

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-3.5-turbo",
          "messages": conversation,
          "temperature": 0.3,
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
        log(generatedText);

        final tasks = _extractTasksInfo(generatedText);
        String formattedText = generatedText;

        if (tasks != null) {
          final jsonPattern = RegExp(
            r'\{\s*"title"\s*:\s*".+?",\s*"coins"\s*:\s*\d+\s*\}',
            dotAll: true,
          );

          // Remove os blocos JSON da string original
          formattedText = formattedText.replaceAll(jsonPattern, '');

          // Remove os números da lista como "1.", "2.", etc.
          final numberListPattern = RegExp(r'^\s*\d+\.\s*', multiLine: true);
          formattedText = formattedText.replaceAll(numberListPattern, '');

          formattedText = formattedText.trim();
          if (formattedText.isEmpty) {
            formattedText = 'Aqui estão algumas sugestões de tarefas:';
          }
        }

        _messages.add({
          'sender': 'bot',
          'text': formattedText,
          if (tasks != null) 'tasks': tasks,
          'time': DateTime.now().toIso8601String(),
        });
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _handleNetworkError();
    }

    notifyListeners();
  }

  void _handleErrorResponse(http.Response response) {
    final errorIndex =
        _messages.indexWhere((msg) => msg['text'] == 'Escrevendo...');
    if (errorIndex != -1) {
      _messages.removeAt(errorIndex);
    }

    _messages.add({
      'sender': 'system',
      'text': 'Erro: ${response.statusCode} - ${response.reasonPhrase}',
      'time': DateTime.now().toIso8601String(),
    });
  }

  void _handleNetworkError() {
    final errorIndex =
        _messages.indexWhere((msg) => msg['text'] == 'Escrevendo...');
    if (errorIndex != -1) {
      _messages.removeAt(errorIndex);
    }

    _messages.add({
      'sender': 'system',
      'text': 'Erro de conexão. Verifique sua internet.',
      'time': DateTime.now().toIso8601String(),
    });
  }
}
