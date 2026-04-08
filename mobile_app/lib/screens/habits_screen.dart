import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Group routines by category or just split into 3 columns for the visual match
        final routines = provider.routines;
        
        // Split into 3 columns for pic-2 match
        List<List<Map<String, dynamic>>> columns = [[], [], []];
        for (int i = 0; i < routines.length; i++) {
          columns[i % 3].add(routines[i]);
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Daily Tasks",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.assignment_turned_in_outlined, color: Colors.white, size: 32),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildColumn(context, columns[0]),
                          const SizedBox(width: 20),
                          _buildColumn(context, columns[1]),
                          const SizedBox(width: 20),
                          _buildColumn(context, columns[2]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Mascot at the bottom
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Text(
                        "YOU'RE DOING GREAT",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/images/robot_3d.png',
                      height: 80,
                      width: 80,
                      errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 60),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddHabitDialog(context),
            backgroundColor: const Color(0xFF6C63FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildColumn(BuildContext context, List<Map<String, dynamic>> items) {
    if (items.isEmpty) return Expanded(child: Container());
    
    return Expanded(
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        color: Colors.grey.withValues(alpha: 0.2),
        opacity: 0.3,
        child: SingleChildScrollView(
          child: Column(
            children: items.map((habit) => _HabitPill(habit: habit)).toList(),
          ),
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'General');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F3A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Daily Task",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "What's the habit?",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Category (e.g. Health, Study)",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    context.read<AppProvider>().addRoutine(titleCtrl.text, categoryCtrl.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Initialize", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitPill extends StatelessWidget {
  final Map<String, dynamic> habit;
  const _HabitPill({required this.habit});

  @override
  Widget build(BuildContext context) {
    final isDone = habit['is_completed'] == 1;
    // Light green for done: Color(0xFFC4E8C2)
    // Light pink for todo: Color(0xFFF9D6D6)
    final bgColor = isDone ? const Color(0xFFC1EAC5) : const Color(0xFFF9DADA);

    return GestureDetector(
      onTap: () {
        context.read<AppProvider>().completeRoutine(habit['id']);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    habit['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: isDone ? Colors.green.shade700 : Colors.black38,
                  size: 22,
                ),
              ],
            ),
            if (habit['badge'] != null && habit['badge'] != "🌱 Beginner")
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(
                      habit['badge'],
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
