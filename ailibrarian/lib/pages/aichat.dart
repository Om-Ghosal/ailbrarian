import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class ChatbotApp extends StatefulWidget {
  const ChatbotApp({super.key});

  @override
  State<ChatbotApp> createState() => _ChatbotAppState();
}

class _ChatbotAppState extends State<ChatbotApp> {
  final ChatUser _currentUser =
      ChatUser(id: 'leor', firstName: 'Leor', lastName: 'Neo');
  final ChatUser _aiagent =
      ChatUser(id: 'wednesday', firstName: 'Wednesday', lastName: 'AI');

  final String url = 'http://192.168.0.157:8000/aiagent';

  int index = 0;
  List<ChatMessage> _messages = [];
  // Map<String, Map<String, String>> _chatHistory = {};
  Map<String, dynamic> _chatHistory = {};
  List _chatHistoryList = [];
  List<ChatUser> _typingUsers = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF909590),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: DashChat(
            messageOptions: const MessageOptions(
                currentUserContainerColor: Color(0xFF2C302E),
                currentUserTextColor: Color(0xFF9AE19D),
                containerColor: Color(0xFF537A5A),
                textColor: Colors.white,
                showTime: false),
            currentUser: _currentUser,
            typingUsers: _typingUsers,
            onSend: (ChatMessage m) {
              getChatResponse(m);
            },
            messages: _messages),
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_aiagent);
      _chatHistory['index'] = index.toString();
      _chatHistory['msg'] = {'name': (m.user.id), 'content': (m.text)};
      _chatHistoryList.add(Map.from(_chatHistory));
      index++;
    });

    final payload = jsonEncode(_chatHistoryList);
    print(payload);
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: payload); //payload);

    if (response.statusCode == 200) {
      if (response.body != null || response.body != '') {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                  user: _aiagent,
                  text: response.body,
                  createdAt: DateTime.now()));

          _chatHistory['index'] = index.toString();
          _chatHistory['msg'] = {'name': 'AI', 'content': (response.body)};
          _chatHistoryList.add(Map.from(_chatHistory));
          index++;

          _typingUsers.remove(_aiagent);
        });
      }
    }
  }
}
