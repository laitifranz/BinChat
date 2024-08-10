import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumPlanCard extends StatelessWidget {
  const PremiumPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.filled(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Premium Plan",
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Be inspired by the most-capable model!",
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
                  //const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            ElevatedButton.icon(
              onPressed: _launchURL,
              label: const Text("Upgrade now"),
              icon: const Icon(Icons.bolt),
            ),
          ],
        ),
      ),
    );
  }
}

_launchURL() async {
  final Uri url = Uri.parse('https://deepmind.google/technologies/gemini/');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
