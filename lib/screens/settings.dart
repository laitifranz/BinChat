import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _conversationStyle = 'Balanced';

  final List<String> _keywords = [
    'climate change',
    'recycling',
    'environment',
    'pollution',
    'ecology',
    'renewable energy'
  ];
  List<String> _selectedKeywords = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _onKeywordSelected(bool selected, String keyword) {
    setState(() {
      if (selected) {
        _selectedKeywords.add(keyword);
      } else {
        _selectedKeywords.remove(keyword);
      }
    });
    _savePreferences();
  }

  void _showKeywordsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select News Keywords'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _keywords.map((keyword) {
                return CheckboxListTile(
                  title: Text(keyword),
                  value: _selectedKeywords.contains(keyword),
                  onChanged: (bool? selected) {
                    _onKeywordSelected(selected ?? false, keyword);
                    Navigator.of(context).pop();
                    _showKeywordsDialog();
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      _conversationStyle = prefs.getString('conversationStyle') ?? 'Balanced';
      _selectedKeywords = prefs.getStringList('selectedKeywords') ?? [];
    });
    _savePreferences();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('selectedLanguage', _selectedLanguage);
    await prefs.setString('conversationStyle', _conversationStyle);
    await prefs.setStringList('selectedKeywords', _selectedKeywords);
  }

  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text(
              'Are you sure you want to reset the app data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetApp(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetApp(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App data has been reset.')),
    );
  }

  Future<void> _showUserProfileDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(height: 16),
                const Text('Name: John'),
                const Text('Surname: Doe'),
                const Text('Username: johndoe123'),
                const Text('Email: johndoe@example.com'),
                const SizedBox(height: 16),
                const Text('Status: Premium'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Implement logout functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Logout'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement change password functionality here
                  },
                  child: const Text('Change Password'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement change password functionality here
                  },
                  child: const Text('Manage subscription'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ExpansionTile(
                initiallyExpanded: true,
                title: Text('General Settings',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _savePreferences();
                    },
                    secondary: const Icon(Icons.notifications_active),
                  ),
                  ListTile(
                    title: const Text('Conversation Style'),
                    subtitle: Text(_conversationStyle),
                    leading: const Icon(Icons.message),
                    onTap: _selectConversationStyle,
                  ),
                ]),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text('Account Settings',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: const Text('User Profile'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    _showUserProfileDialog(context);
                  },
                ),
                ListTile(
                    title: const Text('Erase Data'),
                    leading: const Icon(Icons.delete_forever),
                    onTap: () {
                      _showResetConfirmationDialog(context);
                    }),
                ListTile(
                    title: const Text(
                      'News Keywords',
                    ),
                    leading: const Icon(Icons.newspaper),
                    onTap: _showKeywordsDialog),
              ],
            ),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text('App Information',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: const Text('Tell a friend'),
                  leading: const Icon(Icons.share),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Tell a friend',
                      'Share this app... [Detailed content here]',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Terms of Use'),
                  leading: const Icon(Icons.description),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Terms of Use',
                      'Here are the terms of use... [Detailed content here]',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Credits'),
                  leading: const Icon(Icons.copyright),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Credits',
                      'App icon adapted from an asset by Freepik',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(Icons.privacy_tip),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Privacy Policy',
                      'Here are the privacy policy... [Detailed content here]',
                    );
                  },
                ),
                const ListTile(
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                  leading: Icon(Icons.info),
                ),
                ListTile(
                  title: const Text('Help Center'),
                  leading: const Icon(Icons.help),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      'Help Center',
                      'Here are the resources for helping you... [Detailed content here]',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectConversationStyle() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Conversation Style'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Creative');
              },
              child: const Text('Creative'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Balanced');
              },
              child: const Text('Balanced'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Precise');
              },
              child: const Text('Precise'),
            ),
          ],
        );
      },
    );

    if (selected != null && selected != _conversationStyle) {
      setState(() {
        _conversationStyle = selected;
      });
      _savePreferences();
    }
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InfoDialog(
          title: title,
          content: content,
        );
      },
    );
  }
}

class InfoDialog extends StatelessWidget {
  final String title;
  final String content;

  const InfoDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(content),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
