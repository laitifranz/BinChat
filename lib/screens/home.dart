import 'package:binchat/widgets/notifications.dart';
import 'package:flutter/material.dart';
import 'package:binchat/widgets/premium_plan_card.dart';
import 'package:binchat/widgets/chip_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double defaultVSpace = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(defaultVSpace),
          child: const Column(children: [
            SizedBox(height: defaultVSpace),
            PremiumPlanCard(),
            //SizedBox(height: defaultVSpace),
            Row(
              children: [
                ChipCard(
                    icon: Icons.radar,
                    text: "Nearest Facility",
                    choice: "facility"),
                ChipCard(
                    icon: Icons.local_shipping,
                    text: "Schedule Pickup",
                    choice: "pickup"),
              ],
            ),
            Row(
              children: [
                ChipCard(
                    text: "Saved Resources",
                    icon: Icons.link,
                    choice: "calendar"),
                ChipCard(
                    text: "Latest News", icon: Icons.newspaper, choice: "news"),
              ],
            ),
            //SizedBox(height: defaultVSpace),
          ]),
        ),
        const Expanded(child: NotificationScreen()
            //StatisticsPage()
            )
      ]),
    );
  }
}
