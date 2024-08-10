import 'package:binchat/screens/news.dart';
import 'package:binchat/screens/pdf_manager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class ChipCard extends StatelessWidget {
  const ChipCard(
      {super.key,
      required this.text,
      required this.icon,
      required this.choice});

  final String text;
  final IconData icon;
  final String choice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Map actions to choices
    final Map<String, VoidCallback> actions = {
      "pickup": () => _showPickupDialog(context),
      "facility": () => _redirectToGoogleMaps(),
      "calendar": () => pushScreen(context,
          screen: const PdfLinksManager(), withNavBar: true),
      "news": () => pushScreen(context, screen: const News(), withNavBar: true),
    };

    return Expanded(
      child: SizedBox(
        child: Card.filled(
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: actions[choice] ?? () => _showNoActionDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: theme.primaryColor.withOpacity(0.5),
                    child: Icon(icon, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _redirectToGoogleMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/recycling+centre+near+me/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showPickupDialog(BuildContext context) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    TextEditingController commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Pickup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  selectedDate = pickedDate;
                }
              },
              child: Text(
                selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null && pickedTime != selectedTime) {
                  selectedTime = pickedTime;
                }
              },
              child: Text(
                selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${selectedTime!.format(context)}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments',
                hintText: 'Any special instructions?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Handle the pickup scheduling logic here
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showNoActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No action found!'),
        content:
            const Text('Double-check your code or report if you are a user.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
