import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  String _response = "";

  Future<void> _getResponse() async {
    final response = await http.post(
      Uri.parse("http://192.168.0.20:5000/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": controller.text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _response = jsonDecode(response.body)["response"];
      });
    } else {
      setState(() {
        _response = "No se realizó ninguna consulta.";
      });
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Consultas a DeepSeek")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField para pregunta
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Pregunta",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),
            
            // Boton 
            ElevatedButton(
              onPressed: _getResponse,
              child: Text("Realizar consulta"),
            ),

            SizedBox(height: 30),
            
            // Respuestaaaa
            TextField(
              controller: TextEditingController(text: _response),
              maxLines: 15,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Respuesta",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}