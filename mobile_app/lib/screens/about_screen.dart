import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildWhatCanDo(),
                          const SizedBox(height: 24),
                          _buildMadeWithLove(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right Column
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoSection(
                            "🤖 What is AI Buddy?",
                            "AI Buddy is your personal productivity companion — a smart assistant that listens, guides, and grows with you. Whether you're writing a research paper, training for your dream body, or just trying to make it through a busy day — AI Buddy is always there to help you stay focused, stay kind to yourself, and reach your goals with confidence.",
                          ),
                          const SizedBox(height: 24),
                          _buildInfoSection(
                            "💡 Why We Created It?",
                            "Like many students, I often felt overwhelmed — so many dreams, but not enough direction. I needed something that didn't just track my goals, but understood me. AI Buddy was born from that feeling. It's not just a tool — it's a friendly companion that helps you make progress, one step at a time.",
                          ),
                          const SizedBox(height: 24),
                          _buildInfoSection(
                            "🌍 Our Vision",
                            "To create a world where everyone has a kind, intelligent companion supporting them — not just with tasks, but with life. As we evolve, AI Buddy will become more than just a productivity tool. It will be your motivator, your planner, your assistant, and above all, your friend ❤️",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Mascot at the bottom right
          Positioned(
            bottom: 20,
            right: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Text(
                    "NOW DON'T FORGET TO TAKE CARE OF URSELF ❤️",
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/images/robot_3d.png',
                  height: 100,
                  width: 100,
                  errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 80),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset(
          'assets/images/robot_3d.png',
          height: 50,
          width: 50,
          errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 40),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "About AI Buddy",
              style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "#Alcompanion",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhatCanDo() {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
      opacity: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gps_fixed, color: Colors.redAccent, size: 24),
              const SizedBox(width: 12),
              const Text(
                "What AI Buddy Can Do",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBullet("Reminds you gently of your goals"),
          _buildBullet("Gives you a custom workspace for each dream"),
          _buildBullet("Helps you plan tasks and routines"),
          _buildBullet("Recommends tools, resources, and products"),
          _buildBullet("Keeps you motivated with kind words and intelligent advice"),
          const SizedBox(height: 8),
          const Text(
            "And yes, it even celebrates your wins! 🏆",
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, color: Colors.white, size: 6),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildMadeWithLove() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🙇‍♀️ ", style: TextStyle(fontSize: 24)),
              const Text(
                "Made with Love By",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Nusrath Farheen", style: TextStyle(color: Colors.white, fontSize: 16)),
          const Text("Founder, Dreamer, and Builder of AI Buddy", style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.mail_outline, color: Colors.white38, size: 16),
              SizedBox(width: 8),
              Text("nusrathfarheen33@gmail.com", style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
