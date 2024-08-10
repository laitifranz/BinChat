import 'package:binchat/utils/gemini_initializer.dart';
import 'package:binchat/screens/history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import 'package:binchat/utils/message_models.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

const String _apiKey = String.fromEnvironment('API_KEY_GEMINI');

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.title = "New EcoChat", this.buildHistory});

  final String title;
  final Map<String, dynamic>? buildHistory;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _newChat() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const ChatScreen()));
  }

  void _showHistory() {
    pushScreen(context, screen: const HistoryScreen(), withNavBar: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _showHistory, icon: const Icon(Icons.history)),
          IconButton(onPressed: _newChat, icon: const Icon(Icons.edit_note)),
        ],
      ),
      body: ChatWidget(apiKey: _apiKey, buildHistory: widget.buildHistory),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    required this.apiKey,
    this.buildHistory,
    super.key,
  });

  final String apiKey;
  final Map<String, dynamic>? buildHistory;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];
  bool _loading = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
    _loadModel();
    _restoreHistory();
  }

  void _restoreHistory() {
    Map<String, dynamic>? chatHistory = widget.buildHistory;
    if (chatHistory == null) {
      _generatedContent.add((
        image: null,
        text:
            '## Hello!\nAnother day for great ideas and to save the planet! 🌍💡\n\nHow can I assist you today? 🤔✨',
        fromUser: false
      ));
    } else {
      for (var index = 0; index < chatHistory['messages'].length; index++) {
        final message = chatHistory['messages'][index];
        _generatedContent.add((
          image: null,
          text: message['text'],
          fromUser: message['fromUser']
        ));
      }
    }
  }

  List<Content> buildHistoryFromMap(Map<String, dynamic>? chatHistory) {
    List<Content> history = [];
    if (chatHistory == null) return history;

    for (var index = 0; index < chatHistory['messages'].length; index++) {
      final message = chatHistory['messages'][index];
      if (message['fromUser'] == true) {
        history.add(Content.text(message['text']));
      } else {
        history.add(Content.model([TextPart(message['text'])]));
      }
    }

    return history;
  }

  void _loadModel() async {
    final prefs = await SharedPreferences.getInstance();
    final style = prefs.getString('conversationStyle') ?? 'Balanced';
    double styleValue;

    switch (style) {
      case 'Creative':
        styleValue = 2.0;
      case 'Precise':
        styleValue = 0.0;
      case 'Balanced':
      default:
        styleValue = 1.0;
    }

    final configModel = GenerativeModelInitializer(temperature: styleValue);
    final historyReady = buildHistoryFromMap(widget.buildHistory);

    _model = configModel.createModelWithInstructionKey('General');
    _chat = _model.startChat(
      history: historyReady,
    );
  }

  void _generateSuggestions() async {
    final GenerativeModel model;
    final configModel = GenerativeModelInitializer();
    model =
        configModel.createModelWithInstructionKey('Suggestions', json: true);

    try {
      final response = await model.generateContent([Content.text("")]);
      final List<dynamic> parsedList = jsonDecode(response.text!);
      setState(() {
        _suggestions = List<String>.from(parsedList);
      });
    } catch (e) {
      // Handle any errors here
      // print("Error generating suggestions: $e");
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldDecoration = InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Message Gemini',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );

    return SafeArea(
      minimum: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _apiKey.isNotEmpty
                ? ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, idx) {
                      final content = _generatedContent[idx];
                      return GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(
                              text: content.text ?? 'Error while copying'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message copied to clipboard!'),
                            ),
                          );
                        },
                        child: MessageWidget(
                          text: content.text,
                          image: content.image,
                          isFromUser: content.fromUser,
                        ),
                      );
                    },
                    itemCount: _generatedContent.length,
                  )
                : ListView(
                    children: const [
                      Text(
                        'No API key found. Please provide an API Key using '
                        "'--dart-define' to set the 'API_KEY_GEMINI' declaration.",
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 5,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _suggestions.map((suggestion) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SuggestionChip(
                            text: suggestion,
                            onPressed: () {
                              _textController.text = suggestion;
                              _sendChatMessage(_textController.text);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: !_loading
                          ? () async {
                              _sendImagePrompt(_textController.text,
                                  fromCamera: true);
                            }
                          : null,
                      icon: Icon(
                        Icons.photo_camera,
                        color: _loading
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: !_loading
                          ? () async {
                              _sendImagePrompt(_textController.text);
                            }
                          : null,
                      icon: Icon(
                        Icons.image,
                        color: _loading
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox.square(dimension: 15),
                    Expanded(
                      child: TextField(
                        autofocus: false,
                        focusNode: _textFieldFocus,
                        decoration: textFieldDecoration,
                        controller: _textController,
                        onSubmitted: _sendChatMessage,
                      ),
                    ),
                    const SizedBox.square(dimension: 15),
                    if (!_loading)
                      IconButton(
                        onPressed: () async {
                          _sendChatMessage(_textController.text);
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendImagePrompt(String message,
      {bool fromCamera = false}) async {
    final ImagePicker picker = ImagePicker();
    late final XFile? image;

    setState(() {
      _loading = true;
    });

    try {
      if (fromCamera) {
        image = await picker.pickImage(source: ImageSource.camera);
      } else {
        image = await picker.pickImage(source: ImageSource.gallery);
      }

      if (image == null) {
        _showError('No image taken or chosen.');
        setState(() {
          _loading = false;
        });
        return;
      }

      ByteData photoBytes = await image
          .readAsBytes()
          .then((value) => ByteData.sublistView(Uint8List.fromList(value)));

      final content = Content.multi([
        TextPart(message),
        DataPart(
            image.mimeType ?? 'image/jpeg', photoBytes.buffer.asUint8List()),
      ]);
      _generatedContent.add((
        image: Image.memory(photoBytes.buffer.asUint8List()),
        text: message,
        fromUser: true
      ));
      final responseStream = _chat.sendMessageStream(content);
      await _handleStreamedResponse(responseStream);
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _generatedContent.add((image: null, text: message, fromUser: true));
      final responseStream = _chat.sendMessageStream(
        Content.text(message),
      );

      await _handleStreamedResponse(responseStream);
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  Future<void> _handleStreamedResponse(
      Stream<GenerateContentResponse> responseStream) async {
    String fullResponse = '';

    final int responseIndex = _generatedContent.length;

    _generatedContent.add((image: null, text: '', fromUser: false));

    await for (final response in responseStream) {
      if (response.text != null) {
        fullResponse += response.text!;

        setState(() {
          _generatedContent[responseIndex] =
              (image: null, text: fullResponse, fromUser: false);
        });
        _scrollDown();
      }
    }
  }

  @override
  void dispose() {
    _saveChatHistory();
    super.dispose();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final chatHistory = _generatedContent
        .map((message) => jsonEncode({
              'image': message.image?.toString(),
              'text': message.text,
              'fromUser': message.fromUser,
              'dateCreation': DateTime.now().toIso8601String()
            }))
        .toList();

    // Generate the chat title
    final GenerativeModel tmpModel;
    final conversationText =
        _generatedContent.map((msg) => msg.text).join("\n");
    final configModel = GenerativeModelInitializer();
    tmpModel = configModel.createModelNoSystemInstruction();
    final titleChatResponse = await tmpModel.generateContent([
      Content.text(
          "Abstract from this conversation a title of 4 words or fewer: Be as concise as possible without losing the context of the conversation. Your goal is to extract the key point of the conversation. Example: \"You have to write a proposal research\" is abstracted to \"Write research proposal\", which captures the main action required. \nThe conversation: \"$conversationText\"")
    ]);
    final titleChat = titleChatResponse.text ?? "Untitled Conversation";

    final chatData = jsonEncode({
      'title': titleChat.replaceAll(RegExp(r'\r?\n|\.'), ''),
      'history': chatHistory
    });

    final chatHistoryKey = 'chat_${DateTime.now().toIso8601String()}';

    prefs.setString(chatHistoryKey, chatData);

    final List<String> chatHistoryKeys =
        prefs.getStringList('chatHistoryKeys') ?? [];
    chatHistoryKeys.add(chatHistoryKey);
    prefs.setStringList('chatHistoryKeys', chatHistoryKeys);
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  final Image? image;
  final String? text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(
                  color: isFromUser
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: isFromUser ? userBorderRadius : botBorderRadius,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(children: [
                  if (text case final text?) MarkdownBody(data: text),
                  if (image case final image?) image,
                ]))),
      ],
    );
  }
}

class SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SuggestionChip(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      onPressed: onPressed,
    );
  }
}
