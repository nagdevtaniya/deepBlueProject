import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class CompostingChatbot extends StatefulWidget {
  const CompostingChatbot({super.key});

  @override
  State<CompostingChatbot> createState() => _CompostingChatbotState();
}

class _CompostingChatbotState extends State<CompostingChatbot> {
  String _apiKey = '';
  final List<Map<String, dynamic>> _chatHistory = [];
  String _userInput = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiKey = 'AIzaSyAvMR4zdJLyTG_Yyb94YlCuqT9GDcld1nc'; // Replace with your actual API key
  }

  Future<void> _sendMessage() async {
    if (_userInput.isEmpty) return;

    setState(() {
      _isLoading = true;
      _chatHistory.add({'role': 'user', 'text': _userInput});
      _userInput = '';
    });

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
        systemInstruction: Content.system(
          'You are a composting chatbot. When the user says hi, ask them what food stuff has gone bad, and suggest steps to convert it to compost. '
              'Later, tell them how much waste you have reduced and how they can use the compost. '
              'Lastly, tell them the amount of positive impact they have on environment.'
               'Also use cute emojis at appropriate places',
        ),
      );

      final chat = model.startChat(
        history: _chatHistory.map((message) {
          return Content.text(message['text']);
        }).toList(),
      );

      final response = await chat.sendMessage(Content.text(_chatHistory.last['text']));
      final botMessage = response.text ?? 'I couldn’t process your request. Please try again.';

      setState(() {
        _chatHistory.add({'role': 'bot', 'text': botMessage});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({'role': 'bot', 'text': 'Error: $e'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReGenie🌿🍃'),
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
                  final isUser = message['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, // Fixed alignment
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[200], // Fixed colors
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(message['text']),
                    ),
                  );
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