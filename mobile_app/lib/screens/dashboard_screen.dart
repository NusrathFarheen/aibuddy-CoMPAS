import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/goal_wave_card.dart';
import 'workspace_screen.dart';
import '../widgets/zen_mode_dialog.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppProvider>().loadBriefing();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showGoalModal(context),
            backgroundColor: const Color(0xFF6C63FF),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search & Profile Bar
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        borderRadius: 30,
                        opacity: 0.1,
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.white38, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                style: TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Search your workspace...",
                                  hintStyle: TextStyle(color: Colors.white24),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GlassIconButton(
                      icon: Icons.spa_rounded, 
                      color: provider.isFocusMode ? Colors.cyanAccent : Colors.white38,
                      isActive: provider.isFocusMode,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const ZenModeDialog(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    GlassIconButton(icon: Icons.notifications_none, onTap: () {}),
                    const SizedBox(width: 16),
                    // Profile Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 12, 
                            backgroundColor: Color(0xFF6C63FF), 
                            child: Icon(Icons.person, size: 14, color: Colors.white)
                          ),
                          SizedBox(width: 8),
                          Text("John Doe", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Director's Briefing
                GlassCard(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero, // Padding handled by ExpansionTile
                  glowColor: Colors.cyanAccent.withValues(alpha: 0.1),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent, // Remove borders
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      iconColor: Colors.cyanAccent,
                      collapsedIconColor: Colors.white38,
                      title: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: Colors.cyanAccent.withValues(alpha: 0.05), shape: BoxShape.circle),
                              ),
                              const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
                            ],
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Director's Briefing", style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                              Text("INTELLIGENCE FEED", style: TextStyle(color: Colors.cyanAccent, fontSize: 9, letterSpacing: 1.5)),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: MarkdownBody(
                              data: provider.briefing?['briefing'] ?? "Scanning neural nodes... No current briefing available.",
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.6),
                                strong: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                                listBullet: TextStyle(color: Colors.cyanAccent.withValues(alpha: 0.8)),
                                h1: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                h2: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Goals",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {}, 
                      child: const Text("View All", style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold))
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: provider.goals.isEmpty 
                    ? const Center(child: Text("No active goals found.", style: TextStyle(color: Colors.white24)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 3;
                          if (constraints.maxWidth < 600) {
                            crossAxisCount = 1;
                          } else if (constraints.maxWidth < 900) {
                            crossAxisCount = 2;
                          }
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: crossAxisCount == 1 ? 1.5 : 0.88,
                            ),
                            itemCount: provider.goals.length,
                            itemBuilder: (context, index) {
                              final goal = provider.goals[index];
                              return GoalWaveCard(
                                goal: goal,
                                index: index,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => WorkspaceScreen(goal: goal)));
                                },
                                onEdit: (goal) => _showGoalModal(context, goal: goal),
                                onDelete: (id) => _showDeleteConfirm(context, id),
                                onArchive: (id) => context.read<AppProvider>().archiveGoal(id),
                              );
                            },
                          );
                        }
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGoalModal(BuildContext context, {Map<String, dynamic>? goal}) {
    final isEditing = goal != null;
    final titleCtrl = TextEditingController(text: goal?['title'] ?? '');
    final descCtrl = TextEditingController(text: goal?['description'] ?? '');
    final deadlineCtrl = TextEditingController(text: goal?['deadline'] ?? '');

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
            Text(
              isEditing ? "Modify Goal" : "New Initiative",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Goal Title (e.g., Master Flutter)",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Description or outcome...",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Deadline (YYYY-MM-DD)",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.white38, size: 18),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    final provider = context.read<AppProvider>();
                    if (isEditing) {
                      provider.updateGoal(
                        goal['id'], 
                        titleCtrl.text, 
                        descCtrl.text, 
                        deadlineCtrl.text.isEmpty ? null : deadlineCtrl.text
                      );
                    } else {
                      provider.addGoal(
                        titleCtrl.text, 
                        descCtrl.text, 
                        deadlineCtrl.text.isEmpty ? null : deadlineCtrl.text, 
                        'daily'
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(isEditing ? "Update Goal" : "Deploy Goal", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text("Delete Goal?", style: TextStyle(color: Colors.white)),
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().deleteGoal(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
