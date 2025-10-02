import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CowChatbot extends StatefulWidget {
  @override
  _CowChatbotState createState() => _CowChatbotState();
}

class _CowChatbotState extends State<CowChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // 🔑 NVIDIA DeepSeek API Key
  final String apiKey =
      "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"; // Replace with your real key
  final String baseUrl = "https://integrate.api.nvidia.com/v1";

  // Offline cow knowledge
  final List<Map<String, String>> cowData = [
    {
      "question": "What are Indian cow breeds?",
      "answer": "Gir, Sahiwal, Red Sindhi, Holstein, Jersey..."
    },
    {
      "question": "Common cow diseases?",
      "answer": "Mastitis, Foot-and-mouth disease, Anthrax, Brucellosis..."
    },
    {
      "question": "How to care for cows?",
      "answer": "Provide clean water, nutritious feed, regular vet checkups..."
    },
  ];

  String? _getLocalAnswer(String message) {
    for (var item in cowData) {
      if (message.toLowerCase().contains(item["question"]!.toLowerCase())) {
        return item["answer"];
      }
    }
    return null;
  }

  Future<String> _fetchBotReply(String message) async {
    String? localAnswer = _getLocalAnswer(message);
    if (localAnswer != null) return localAnswer;

    try {
      final url = Uri.parse("$baseUrl/chat/completions");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "deepseek-ai/deepseek-v3.1",
          "messages": [
            {"role": "system", "content": "You are a helpful cow assistant."},
            {"role": "user", "content": message}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ??
            "No reply from DeepSeek.";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openChatbot() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 400,
                height: 500,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      "Cow Chatbot",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg["role"] == "user";
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                              const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                isUser ? Colors.green[200] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(msg["content"] ?? ""),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LinearProgressIndicator(
                          color: Colors.green,
                          minHeight: 4,
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                                hintText: "Ask about cows..."),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.green),
                          onPressed: () async {
                            final text = _controller.text.trim();
                            if (text.isEmpty) return;

                            setStateDialog(() {
                              _messages.add({"role": "user", "content": text});
                              _controller.clear();
                              _isLoading = true;
                            });

                            _scrollToBottom();

                            final reply = await _fetchBotReply(text);

                            setStateDialog(() {
                              _messages.add({"role": "bot", "content": reply});
                              _isLoading = false;
                            });

                            _scrollToBottom();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _openChatbot,
      child: const Icon(Icons.chat),
      backgroundColor: Colors.green,
    );
  }
}
