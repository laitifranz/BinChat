import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

const String apiKey = String.fromEnvironment('API_KEY_NEWS');

class News extends StatefulWidget {
  const News({super.key});

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  List _articles = [];
  List<String> _selectedKeywords = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedKeywords().then((_) => _fetchNews());
  }

  Future<void> _loadSelectedKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedKeywords = prefs.getStringList('selectedKeywords') ??
          ['climate change', 'recycling'];
    });
  }

  Future<void> _fetchNews() async {
    if (apiKey.isEmpty) {
      _showError(
          'API key is not available. Please set the API_KEY_NEWS environment variable.');
      return;
    }
    final String keywords = _selectedKeywords.join(' OR ');
    final String url =
        'https://newsapi.org/v2/everything?q=$keywords&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _articles = data['articles'];
      });
    } else {
      throw Exception('Failed to load news');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoNews'),
        backgroundColor: Colors.green,
      ),
      body: _articles.isEmpty
          ? _buildLoadingShimmer()
          : ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return _buildArticleCard(article);
              },
            ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Container(width: 100, height: 100, color: Colors.white),
              title: Container(
                  width: double.infinity, height: 20, color: Colors.white),
              subtitle: Container(
                  width: double.infinity, height: 20, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleCard(article) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _openArticle(article['url']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['urlToImage'] != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  article['urlToImage'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article['description'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        article['source']['name'] ?? 'Unknown source',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        article['publishedAt'] != null
                            ? DateTime.parse(article['publishedAt'])
                                .toLocal()
                                .toString()
                            : 'Unknown date',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
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

  Future<void> _openArticle(String url) async {
    final url0 = Uri.parse(url);
    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }
}
