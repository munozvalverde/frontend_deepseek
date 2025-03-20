import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, String>> chatMessages = [];
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // Inicializar el servicio de speech to text
  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      print("Reconocimiento de voz habilitado");
    } else {
      print("Reconocimiento de voz no disponible");
    }
  }

  // Iniciar la escucha
  void _startListening() async {
    // token de acceso de Google
    await _setAccessToken();

    // para comenzar a escuchar el audio
    _speech.listen(onResult: (result) {
      setState(() {
        controller.text =
            result.recognizedWords; // esto transcribe en el cuadro de pregunta
      });
    });
    setState(() {
      _isListening = true;
    });
  }

  // Detener la escucha
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // config del token de accesoooo
  Future<void> _setAccessToken() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.20:5000/get-credentials'));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String accessToken = jsonResponse['access_token'];
    } else {
      print('Failed to get access token');
    }
  }

  // enviar la consulta
  Future<void> _sendMessage() async {
    String message = controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      chatMessages.add({"role": "user", "text": message});
      controller.clear();
      controller.clear();
    });

    // construir el historial de conversación para no perder el contextoooo
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

  // Función para leer la respuesta en voz alta
  Future<void> _textToSpeech(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DeepSeek"),
        centerTitle: true,
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                    child: Stack(
                      children: [
                        Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            message["text"]!,
                            style: TextStyle(
                              fontSize: 16,
                              color: isUser ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        if (!isUser) // Solo mostrar el botón de voz para el bot
                          Positioned(
                            bottom: 3,
                            right: 3,
                            child: GestureDetector(
                              onTap: () => _textToSpeech(message["text"]!),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                child: Icon(
                                  Icons.volume_up,
                                  color: Colors.black,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                // Botón para activar/desactivar el Speech-to-Text
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.black,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                SizedBox(width: 8),
                // Botón para enviar el mensaje
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
