
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';





class RecipeChatbot extends StatefulWidget {
  const RecipeChatbot({super.key});

  @override
  State<RecipeChatbot> createState() => _RecipeChatbotState();
}

class _RecipeChatbotState extends State<RecipeChatbot> {
  String _apiKey = '';
  final List<Map<String, dynamic>> _chatHistory = [];
  String _userInput = '';
  String _botResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiKey = 'AIzaSyCrL8QGTHFECKQebWTLIhLpB-fLCLeFzgM'; // Replace with your actual API key
  }

  Future<void> _sendMessage() async {
    if (_userInput.isEmpty) return;
    print('User input: $_userInput');
    setState(() {
      _isLoading = true;
      _chatHistory.add({'user': _userInput});
      _userInput = '';
    });
    print('Chat history after user input: $_chatHistory');

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'text/plain',
        ),
        systemInstruction: Content.system('you are a recipe generator chatbot, when user says hi, '
            'ask them what ingredients or leftovers they have got, and suggest them recipes , '
            'later tell them how much waste you have reduced and the food can also last long,'
        'lastly give them suggestions on storing leftovers'),
      );

      final chat = model.startChat(history: _chatHistory.map((message) {
        return Content.text(message['user']);
      }).toList());

      final content = Content.text(_chatHistory.last['user']);
      final response = await chat.sendMessage(content);
      final botMessage = response.text ?? 'I couldn’t process your request. Please try again.';
      print('Bot response: $botMessage');

      print('Bot response: ${response.text}');

      setState(() {
        if (response.text != null) {
          _chatHistory.add({'bot': response.text!});
          _botResponse = response.text!;

        } else {
          _chatHistory.add({'bot': 'No response received.'});
          _botResponse = 'No response received.';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({'bot': 'Error: $e'});
        _botResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

// ... rest of the code ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Chatbot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final message = _chatHistory[index];
                  if (message.containsKey('user')) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(message['user']),
                      ),
                    );
                  } else {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(message['bot']),
                      ),
                    );
                  }
                },
              ),
            ),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => _userInput = value),
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
