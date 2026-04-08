import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final recs = _getRecommendations(provider.goals);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recommended for You",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Curated plans and products to help you reach your ${provider.goals.length} active goals faster.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: recs.length,
                    itemBuilder: (context, index) => _RecommendationCard(rec: recs[index]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getRecommendations(List<Map<String, dynamic>> goals) {
    List<Map<String, dynamic>> allRecs = [];
    
    bool hasFitness = goals.any((g) => g['title'].toString().toLowerCase().contains('gym') || g['title'].toString().toLowerCase().contains('fitness'));
    bool hasLearning = goals.any((g) => g['title'].toString().toLowerCase().contains('learn') || g['title'].toString().toLowerCase().contains('study'));
    bool hasProject = goals.any((g) => g['title'].toString().toLowerCase().contains('build') || g['title'].toString().toLowerCase().contains('code'));

    if (hasFitness) {
      allRecs.add({
        'title': 'Optimum Nutrition Gold Standard',
        'category': 'SUPPLEMENTS',
        'price': '\$59.99',
        'icon': Icons.fitness_center,
        'color': Colors.greenAccent,
        'desc': 'The worlds best selling whey protein powder to support muscle recovery.',
      });
      allRecs.add({
        'title': 'High Intensity Interval Plan',
        'category': 'WORKOUT PLAN',
        'price': 'FREE',
        'icon': Icons.bolt,
        'color': Colors.orangeAccent,
        'desc': 'A 4-week program designed by experts to maximize fat loss and stamina.',
      });
    }

    if (hasLearning || hasProject) {
      allRecs.add({
        'title': 'Complete Python Masterclass',
        'category': 'COURSE',
        'price': '\$12.99',
        'icon': Icons.school,
        'color': Colors.blueAccent,
        'desc': 'Master Python by building 100 projects in 100 days. Best for your Jarvis goal.',
      });
      allRecs.add({
        'title': 'Keychron K2 Mechanical Keyboard',
        'category': 'HARDWARE',
        'price': '\$79.00',
        'icon': Icons.keyboard,
        'color': Colors.purpleAccent,
        'desc': 'Boost your coding speed and comfort with a tactile mechanical experience.',
      });
    }

    // Default recommendations if list is short
    if (allRecs.length < 3) {
      allRecs.add({
        'title': 'The Lean Startup',
        'category': 'READING',
        'price': '\$14.00',
        'icon': Icons.menu_book,
        'color': Colors.redAccent,
        'desc': 'How constant innovation creates radically successful businesses.',
      });
      allRecs.add({
        'title': 'Skillshare Annual Premium',
        'category': 'SUBSCRIPTION',
        'price': '\$99/yr',
        'icon': Icons.star,
        'color': Colors.amberAccent,
        'desc': 'Access thousands of creative classes to level up your skillsets.',
      });
    }

    return allRecs;
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> rec;
  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: rec['color'].withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: rec['color'].withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(rec['icon'], size: 48, color: rec['color']),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rec['category'], style: TextStyle(color: rec['color'], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text(rec['price'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(rec['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(rec['desc'], style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: rec['color'].withValues(alpha: 0.3)),
              ),
              child: const Text("View Details"),
            ),
          )
        ],
      ),
    );
  }
}
