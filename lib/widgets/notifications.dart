import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<NotificationItem> dummyNotifications = [
      NotificationItem(
        title: 'Pickup Reminder',
        message: 'Your recycling pickup is scheduled for tomorrow morning.',
        isNew: true,
      ),
      NotificationItem(
        title: 'New Tip',
        message: 'Tap on Learn tab and start exploring!',
        isNew: true,
      ),
      NotificationItem(
        title: 'From the community',
        message:
            'Explore the feed and be inspired by amazing people trying to reuse products.',
        isNew: false,
      ),
      NotificationItem(
        title: 'Event Reminder',
        message:
            'Join us for the community clean-up event this Saturday on Discord.',
        isNew: false,
      ),
      NotificationItem(
        title: 'Welcome!',
        message: 'Thanks for joining us.',
        isNew: false,
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: NotificationSection(notifications: dummyNotifications),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSection extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationSection({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return NotificationCard(notifications: notifications);
  }
}

class NotificationCard extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationCard({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: notifications.isEmpty
            ? Center(
                child: Text(
                  'No Notifications',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: notification.isNew ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isNew
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(notification.message),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    trailing: notification.isNew
                        ? const Icon(Icons.fiber_new, color: Colors.green)
                        : null,
                  );
                },
              ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final bool isNew;

  NotificationItem(
      {required this.title, required this.message, required this.isNew});
}
