import 'package:binchat/screens/chat.dart';
import 'package:binchat/screens/explore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:binchat/utils/gemini_initializer.dart';

class Learn extends StatefulWidget {
  const Learn({super.key});

  @override
  _LearnState createState() => _LearnState();
}

class _LearnState extends State<Learn> with SingleTickerProviderStateMixin {
  late final GenerativeModel _model;
  final List<String> tips = [
    '... recycling one aluminum can saves enough energy to listen to a full album on your iPod.',
    '... recycling 100 cans could light your bedroom for two whole weeks.',
    '... recycling paper produces 73% less air pollution than if it was made from raw materials.',
    '... glass is 100% recyclable and can be recycled endlessly without loss in quality or purity.',
    '... plastic bags are recyclable but should not be put in the recycling bin. Take them to a grocery store with a bag collection bin.',
  ];

  List<String> bookmarkedTips = [];
  late String currentTip;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    currentTip = (tips..shuffle()).first;
    super.initState();
    _loadBookmarkedTips();
    final configModel = GenerativeModelInitializer();
    _model = configModel.createModelWithInstructionKey('Tips');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarkedTips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarkedTips = prefs.getStringList('bookmarkedTips') ?? [];
    });
  }

  Future<void> _saveBookmarkedTips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('bookmarkedTips', bookmarkedTips);
  }

  void _getNextTip() async {
    setState(() {
      _isLoading = true;
    });

    final response =
        await _model.generateContent([Content.text("Do you know that")]);
    setState(() {
      currentTip = response.text!;
      _isLoading = false;
    });
  }

  void _bookmarkTip() {
    if (!bookmarkedTips.contains(currentTip)) {
      setState(() {
        bookmarkedTips.add(currentTip);
      });
      _saveBookmarkedTips();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tip bookmarked!'),
        ),
      );
    }
  }

  void _share(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: const AddPostWidget(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bookmarked Tips (1/4 of the screen)
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bookmarked Tips:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: bookmarkedTips.isEmpty
                        ? const Center(
                            child: Text(
                              'No bookmarks saved',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: bookmarkedTips.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.bookmark,
                                    color: Colors.blueAccent),
                                title: Text(
                                  bookmarkedTips[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            //const SizedBox(height: 20),
            const Divider(
              // Separator line
              thickness: 1,
              color: Colors.black,
              height: 20,
            ),

            // "Did you know that" and Tip Section (3/4 of the screen)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const Text(
                    'Did you know that',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        key: ValueKey<String>(currentTip),
                        height: (screenHeight * 3 / 4 - 100) *
                            0.4, // 40% of the remaining 3/4 screen height
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            // For handling overflow content
                            child: Text(
                              currentTip,
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //const Spacer(),
                  // Buttons
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _bookmarkTip,
                            icon: const Icon(Icons.bookmark),
                            label: const Text('Bookmark'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _getNextTip,
                            icon: _isLoading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Icon(Icons.refresh),
                            label: const Text('Next Tip'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              final Map<String, dynamic> chatHistory = {
                                'messages': [
                                  {
                                    'text': 'Did you know that $currentTip',
                                    'fromUser': false
                                  }
                                ]
                              };
                              pushScreen(context,
                                  screen: ChatScreen(
                                    title: 'Tips Q&A',
                                    buildHistory: chatHistory,
                                  ),
                                  withNavBar: true);
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Ask More To Gemini'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _share(context),
                            icon: const Icon(Icons.share),
                            label: const Text('Share as Post'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
