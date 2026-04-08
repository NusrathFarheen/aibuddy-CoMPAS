import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showJournalDialog(context),
            backgroundColor: const Color(0xFF00D9FF),
            child: const Icon(Icons.edit, color: Colors.black),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 32),
                
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("MIND", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
                        Text("PALACE", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Quick Entry Card
                _buildQuickEntryCard(context),
                
                const SizedBox(height: 32),
                
                const Text(
                  "Recent Reflections",
                  style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Journal Entries
                Expanded(
                  child: provider.journal.isEmpty
                    ? const Center(child: Text("Your palace is empty. Start a reflection.", style: TextStyle(color: Colors.white24)))
                    : ListView.builder(
                        itemCount: provider.journal.length,
                        itemBuilder: (context, index) {
                          final entry = provider.journal[index];
                          return _JournalCard(entry: entry);
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white38, size: 20),
                SizedBox(width: 12),
                Text("Search reflections...", style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildTopIcon(Icons.auto_awesome),
        const SizedBox(width: 16),
        const CircleAvatar(
          radius: 16, 
          backgroundColor: Colors.purpleAccent, 
          child: Icon(Icons.person, size: 18, color: Colors.white)
        ),
      ],
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }

  Widget _buildQuickEntryCard(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      glowColor: Colors.blueAccent.withValues(alpha: 0.2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology, color: Colors.blueAccent, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "How are you today?",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "A quick check-in helps AI Buddy synchronize with your state.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showJournalDialog(context),
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ),
        ],
      ),
    );
  }

  void _showJournalDialog(BuildContext context) {
    final contentCtrl = TextEditingController();
    int selectedMood = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1F3A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientText(
                "Reflect on your day",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text("How are you feeling?", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final mood = index + 1;
                  final isSelected = selectedMood == mood;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedMood = mood),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? JournalScreen._moodColor(mood).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? JournalScreen._moodColor(mood) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(JournalScreen._moodEmoji(mood), style: const TextStyle(fontSize: 28)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (contentCtrl.text.isNotEmpty) {
                      context.read<AppProvider>().addJournal(contentCtrl.text, selectedMood);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Reflection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  static String _moodEmoji(int mood) {
    switch (mood) {
      case 1: return '😢';
      case 2: return '😔';
      case 3: return '😐';
      case 4: return '😊';
      case 5: return '🤩';
      default: return '😐';
    }
  }

  static Color _moodColor(int mood) {
    switch (mood) {
      case 1: return const Color(0xFFFF6B6B);
      case 2: return const Color(0xFFFFAB40);
      case 3: return const Color(0xFFFFD740);
      case 4: return const Color(0xFF69F0AE);
      case 5: return const Color(0xFF00E676);
      default: return const Color(0xFF6C63FF);
    }
  }
}

class _JournalCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _JournalCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final mood = entry['mood_score'] ?? 3;
    final moodColor = JournalScreen._moodColor(mood);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      glowColor: moodColor.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    JournalScreen._moodEmoji(mood), 
                    style: const TextStyle(fontSize: 24)
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['create_date'] ?? 'JUST NOW',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        "MOOD STRENGTH: ${mood}/5",
                        style: TextStyle(
                          color: moodColor, 
                          fontSize: 9, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: 1
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 60,
                child: GlassProgressBar(
                  progress: mood / 5.0, 
                  color: moodColor, 
                  height: 4
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            entry['content'] ?? '',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag("REFLECTION", Colors.purpleAccent),
              const SizedBox(width: 8),
              if (entry['memories_recalled'] != null)
                _buildTag("SYNCED", Colors.cyanAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }
}
