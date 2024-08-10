import 'package:binchat/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> chatHistories = [];

  @override
  void initState() {
    super.initState();
    _loadAllChatHistories();
  }

  Future<void> _loadAllChatHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> chatHistoryKeys =
        prefs.getStringList('chatHistoryKeys') ?? [];
    final List<Map<String, dynamic>> loadedHistories = [];

    for (var key in chatHistoryKeys) {
      final chatData = prefs.getString(key);
      if (chatData != null) {
        final decodedData = jsonDecode(chatData) as Map<String, dynamic>;
        final title = decodedData['title'] as String;
        final history = decodedData['history'] as List<dynamic>;

        loadedHistories.add({
          'key': key,
          'title': title,
          'messages': history
              .map((message) => jsonDecode(message) as Map<String, dynamic>)
              .toList(),
        });
      }
    }

    setState(() {
      chatHistories = loadedHistories.reversed
          .toList(); // Reverse to show the latest chat first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chat History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: chatHistories.isEmpty
          ? const Center(
              child: Text(
                'No chat histories found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: chatHistories.length,
              itemBuilder: (context, index) {
                final chatHistory = chatHistories[index];
                return ListTile(
                  title: Text(chatHistory['title']),
                  leading: const Icon(Icons.chat),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    pushScreen(context,
                        screen: ChatScreen(
                          title: chatHistory['title'],
                          buildHistory: chatHistory,
                        ),
                        withNavBar: true);
                  },
                );
              },
            ),
    );
  }
}
