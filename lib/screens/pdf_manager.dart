import 'package:binchat/widgets/pdfviewer.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkItem {
  final String title;
  final String link;
  final bool isPdf;

  LinkItem({required this.title, required this.link, required this.isPdf});

  Map<String, String> toMap() {
    return {
      'title': title,
      'link': link,
      'isPdf': isPdf.toString(),
    };
  }

  static LinkItem fromMap(Map<String, String> map) {
    return LinkItem(
      title: map['title']!,
      link: map['link']!,
      isPdf: map['isPdf'] == 'true',
    );
  }
}

class PdfLinksManager extends StatefulWidget {
  const PdfLinksManager({super.key});

  @override
  _PdfLinksManagerState createState() => _PdfLinksManagerState();
}

class _PdfLinksManagerState extends State<PdfLinksManager> {
  List<LinkItem> _links = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  bool _isPdf = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> links = prefs.getStringList('links') ?? [];
    setState(() {
      _links = links
          .map((link) =>
              LinkItem.fromMap(Uri.splitQueryString(Uri.parse(link).query)))
          .toList();
    });
  }

  Future<void> _addLink() async {
    if (_titleController.text.isNotEmpty &&
        _linkController.text.isNotEmpty &&
        Uri.parse(_linkController.text).isAbsolute) {
      setState(() {
        _links.add(LinkItem(
          title: _titleController.text,
          link: _linkController.text,
          isPdf: _isPdf,
        ));
        _titleController.clear();
        _linkController.clear();
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'links',
          _links
              .map((link) => Uri(queryParameters: link.toMap()).toString())
              .toList());
    }
  }

  Future<void> _deleteLink(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: const Text('Are you sure you want to delete this link?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _links.removeAt(index);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'links',
          _links
              .map((link) => Uri(queryParameters: link.toMap()).toString())
              .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Saved Links'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Add new link',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Link Type:'),
                        const SizedBox(width: 10),
                        DropdownButton<bool>(
                          value: _isPdf,
                          items: const [
                            DropdownMenuItem(value: true, child: Text('PDF')),
                            DropdownMenuItem(
                                value: false, child: Text('Website')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _isPdf = value ?? true;
                            });
                          },
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _addLink,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Link'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _links.isEmpty
                  ? const Center(
                      child: Text('Add your waste calendars\nor other useful links',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,))
                  : ListView.builder(
                      itemCount: _links.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(_links[index].title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(_links[index].link),
                            leading: Icon(
                                _links[index].isPdf
                                    ? Icons.picture_as_pdf
                                    : Icons.link,
                                color: _links[index].isPdf
                                    ? Colors.red
                                    : Colors.blue),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteLink(index),
                            ),
                            onTap: () {
                              final url = _links[index].link.toString();
                              if (_links[index].isPdf) {
                                pushScreen(context,
                                    screen: PDFViewer(url: url),
                                    withNavBar: true);
                              } else {
                                _openUrl(url);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final url0 = Uri.parse(url);
    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }
}
