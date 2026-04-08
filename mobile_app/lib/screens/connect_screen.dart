import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("NEURAL NETWORK", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
            const Text("CONNECT", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              children: [
                _buildMiniStat("Active Clubs", "128", Icons.groups_rounded, Colors.cyanAccent),
                const SizedBox(width: 16),
                _buildMiniStat("Global Rank", "#42", Icons.emoji_events_rounded, Colors.orangeAccent),
              ],
            ),
            
            const SizedBox(height: 40),
            _SectionHeader(title: "FEATURED CLUBS", action: "View All"),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ClubCard(
                    name: "Code Architects", 
                    members: 1240, 
                    image: "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&auto=format&fit=crop&q=60",
                    tags: ["Flutter", "Clean Architecture"],
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 16),
                  _ClubCard(
                    name: "Biohackers Elite", 
                    members: 850, 
                    image: "https://images.unsplash.com/photo-1530210124550-912dc1381cb8?w=500&auto=format&fit=crop&q=60",
                    tags: ["Health", "Optimization"],
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 16),
                  _ClubCard(
                    name: "Zen Masters", 
                    members: 3200, 
                    image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500&auto=format&fit=crop&q=60",
                    tags: ["Mindfulness", "Flow"],
                    color: Colors.purpleAccent,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            _SectionHeader(title: "GLOBAL LEADERBOARD", action: "My Stats"),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  _LeaderboardItem(rank: 1, name: "NeuralMage", xp: 12500, avatar: "🧙", isMe: false),
                  _LeaderboardItem(rank: 2, name: "CryptoPulse", xp: 11200, avatar: "⚡", isMe: false),
                  _LeaderboardItem(rank: 3, name: "AIBuddy_User", xp: 10850, avatar: "🤖", isMe: true),
                  _LeaderboardItem(rank: 4, name: "DreamCatcher", xp: 9400, avatar: "🌙", isMe: false),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        glowColor: color.withValues(alpha: 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        Text(action, style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ClubCard extends StatelessWidget {
  final String name;
  final int members;
  final String image;
  final List<String> tags;
  final Color color;

  const _ClubCard({required this.name, required this.members, required this.image, required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("$members Members", style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: tags.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.4))),
                  child: Text(t, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final String avatar;
  final bool isMe;

  const _LeaderboardItem({required this.rank, required this.name, required this.xp, required this.avatar, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
        border: Border(bottom: const BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text("$rank", style: TextStyle(color: rank <= 3 ? Colors.orangeAccent : Colors.white24, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: Text(avatar, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: Colors.white, fontWeight: isMe ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                const SizedBox(height: 2),
                Container(
                  height: 4,
                  width: (xp / 15000) * 100,
                  decoration: BoxDecoration(color: isMe ? Colors.cyanAccent : Colors.white10, borderRadius: BorderRadius.circular(2)),
                ),
              ],
            ),
          ),
          Text("${(xp/1000).toStringAsFixed(1)}k XP", style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
