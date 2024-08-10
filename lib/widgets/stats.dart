import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  final RecyclingStats stats = RecyclingStats(
    totalRecycled: 1234, // Example total recycled amount
    totalAchievements: 8, // Example number of achievements
    totalRewards: 5, // Example number of rewards earned
    recentAchievements: [
      'Recycled 100kg of plastic',
      'Completed 10 recycling challenges',
      'Earned Silver Badge',
    ],
    rewards: [
      'Silver Badge',
      'Eco Warrior T-Shirt',
      'Recycling Kit',
    ],
  );

  StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Section
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0, // Height of the carousel
              child: PageView(
                scrollDirection: Axis.horizontal,
                children: [
                  StatisticCard(
                    title: 'Total Recycled',
                    value: '${stats.totalRecycled} kg',
                    icon: Icons.recycling,
                    color: Colors.teal,
                  ),
                  StatisticCard(
                    title: 'Achievements',
                    value: '${stats.totalAchievements}',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                  StatisticCard(
                    title: 'Rewards Earned',
                    value: '${stats.totalRewards}',
                    icon: Icons.card_giftcard,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            // Recent Achievements Section
            Text(
              'Recent Achievements',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
            const SizedBox(height: 8.0),
            for (var achievement in stats.recentAchievements)
              AchievementTile(achievement: achievement),
            const SizedBox(height: 24.0),
            // Rewards Section
            Text(
              'Rewards Earned',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
            const SizedBox(height: 8.0),
            for (var reward in stats.rewards) RewardTile(reward: reward),
          ],
        ),
      ),
    );
  }
}

class RecyclingStats {
  final int totalRecycled;
  final int totalAchievements;
  final int totalRewards;
  final List<String> recentAchievements;
  final List<String> rewards;

  RecyclingStats({
    required this.totalRecycled,
    required this.totalAchievements,
    required this.totalRewards,
    required this.recentAchievements,
    required this.rewards,
  });
}

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40.0,
              color: color,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementTile extends StatelessWidget {
  final String achievement;

  const AchievementTile({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text(achievement),
        contentPadding: const EdgeInsets.all(12.0),
      ),
    );
  }
}

class RewardTile extends StatelessWidget {
  final String reward;

  const RewardTile({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: Colors.green),
        title: Text(reward),
        contentPadding: const EdgeInsets.all(12.0),
      ),
    );
  }
}
