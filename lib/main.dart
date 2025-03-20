import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, String>> chatMessages = [];

  Future<void> _sendMessage() async {
    String message = controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      chatMessages.add({"role": "user", "text": message});
      controller.clear();
    });

    // Construir el historial de conversación
    List<Map<String, String>> messagesToSend = chatMessages.map((msg) {
      return {
        "role": msg["role"] == "user" ? "user" : "assistant",
        "content": msg["text"]!
      };
    }).toList();

    final response = await http.post(
      Uri.parse("http://192.168.0.20:5000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"messages": messagesToSend}),
    );

    if (response.statusCode == 200) {
      String botResponse =
          jsonDecode(response.body)["response"].replaceAll(RegExp(r'\*+'), "");
      setState(() {
        chatMessages.add({"role": "bot", "text": botResponse});
      });
    } else {
      setState(() {
        chatMessages
            .add({"role": "bot", "text": "No se realizó ninguna consulta."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DeepSeek"),
        centerTitle: true,
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                bool isUser = message["role"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.grey[300] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Escribe tu pregunta...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send, color: Colors.black,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}
