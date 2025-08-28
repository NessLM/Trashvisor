import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:trashvisor/core/colors.dart';

class TrashChatbotPage extends StatefulWidget {
  const TrashChatbotPage({super.key});

  @override
  State<TrashChatbotPage> createState() => _TrashChatbotPageState();
}

class _TrashChatbotPageState extends State<TrashChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final String systemPrompt =
      "Anda adalah Trash Chatbot, asisten AI yang fokus pada edukasi pengelolaan sampah. "
      "Anda harus memberikan informasi akurat dan relevan tentang daur ulang, pemilahan sampah, "
      "pengomposan, dan dampak lingkungan dari sampah. "
      "Jika pengguna mengajukan pertanyaan yang tidak relevan dengan topik sampah, "
      "jawablah dengan sopan bahwa Anda hanya dapat membantu dengan pertanyaan seputar sampah.";

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'content':
          'Halo! 👋 Saya adalah asisten AI yang siap membantu Anda mengenal lebih jauh tentang pengelolaan sampah, mulai dari cara memilah hingga tips daur ulang. Yuk, bersama kita jaga lingkungan demi masa depan yang lebih bersih dan sehat! 🌱',
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _messages.add({'role': 'ai', 'content': 'Menunggu jawaban...'});
    });
    _controller.clear();

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'role': 'ai',
          'content': 'Error: OPENAI_API_KEY tidak ditemukan di .env',
        });
      });
      debugPrint('Error: OPENAI_API_KEY is not set in .env file.');
      return;
    }

    const url = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessage},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = data['choices'][0]['message']['content'];

        setState(() {
          _messages.removeLast();
          _messages.add({'role': 'ai', 'content': aiMessage});
        });
      } else {
        setState(() {
          _messages.removeLast();
          _messages.add({
            'role': 'ai',
            'content': 'Maaf, terjadi kesalahan: ${response.statusCode}',
          });
        });
        debugPrint('Gagal: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'role': 'ai',
          'content': 'Maaf, terjadi error jaringan: $e',
        });
      });
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF678E35),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('assets/images/icon_chatbot.png'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trash Chatbot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  'Tanyakan pertanyaan seputar sampah',
                  style: TextStyle(
                    color: Colors.white.withAlpha((255 * 0.8).round()),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  final isUser = message['role'] == 'user';
                  final isFirstMessage = index == _messages.length - 1;

                  return Column(
                    children: [
                      _buildMessageBubble(message, isUser),
                      if (isFirstMessage) _buildQuestionSuggestions(),
                    ],
                  );
                },
              ),
            ),
            _buildInputWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset('assets/images/icon_chatbot.png'),
              ),
            ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFFA2C96C)
                    : const Color(0xFFC7DFA7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 15 : 0),
                  topRight: const Radius.circular(15),
                  bottomLeft: const Radius.circular(15),
                  bottomRight: Radius.circular(isUser ? 0 : 15),
                ),
                border: Border.all(color: const Color(0xFF678E35), width: 1.0),
              ),
              child: isUser
                  ? Text(
                      message['content']!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    )
                  : MarkdownBody(
                      data: message['content']!,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                            ),
                            strong: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
            ),
          ),
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white, // Warna border yang Anda inginkan
                    width: 2.0, // Ketebalan border
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.fernGreen,
                  child: Icon(Icons.person, color: AppColors.whiteSmoke),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ketik di sini...',
                filled: true,
                fillColor: const Color(0xFFC7DFA7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF678E35),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSuggestions() {
    final List<String> questions = [
      'Cara memilah sampah organik dan anorganik?',
      'Apa itu sampah B3?',
      'Jenis sampah daur ulang',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: questions.map((question) {
          return ElevatedButton(
            onPressed: () {
              _controller.text = question;
              _sendMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7DFA7),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF678E35)),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              question,
              style: const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
