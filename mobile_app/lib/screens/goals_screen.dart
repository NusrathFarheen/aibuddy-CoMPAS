import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import '../screens/workspace_screen.dart';
import '../models/workspace_template.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 80,
                floating: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: const FlexibleSpaceBar(
                  title: GradientText('My Goals',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                ),
              ),
              if (provider.goals.where((g) => g['is_archived'] != 1 && g['is_archived'] != true).isEmpty)
                const SliverFillRemaining(
                  child: Center(
                      child: Text('No active goals!',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 16))),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activeGoals = provider.goals.where((g) => g['is_archived'] != 1 && g['is_archived'] != true).toList();
                      final goal = activeGoals[index];
                      return _GoalWaveCard(goal: goal);
                    },
                    childCount: provider.goals.where((g) => g['is_archived'] != 1 && g['is_archived'] != true).length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddGoalDialog(context),
            backgroundColor: const Color(0xFF6C63FF),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Goal'),
          ),
        );
      },
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedTemplateId = 'daily';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1F3A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientText('Create New Goal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  setModalState(() {
                    selectedTemplateId = TemplateRegistry.inferTemplateId(val);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Goal title (e.g., Learn Flutter)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              
              const Text('Select Life Context (Template)', 
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: TemplateRegistry.templates.length,
                  itemBuilder: (context, index) {
                    final t = TemplateRegistry.templates[index];
                    final isSelected = t.id == selectedTemplateId;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedTemplateId = t.id),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? t.themeColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? t.themeColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(t.icon, color: isSelected ? t.themeColor : Colors.white38, size: 24),
                            const SizedBox(height: 4),
                            Text(t.name.split(' ').first, 
                              style: TextStyle(
                                fontSize: 10, 
                                color: isSelected ? Colors.white : Colors.white38,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty) {
                      ctx
                          .read<AppProvider>()
                          .addGoal(titleCtrl.text, descCtrl.text, null, selectedTemplateId);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Create Goal (AI will plan tasks)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalWaveCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  const _GoalWaveCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (goal['progress'] ?? 0) / 100.0;
    final deadline = goal['deadline'] ?? '';

    // Determine deadline status
    String statusLabel = 'Active';
    Color statusColor = const Color(0xFF6C63FF);
    if (deadline.isNotEmpty) {
      try {
        final dl = DateTime.parse(deadline);
        final diff = dl.difference(DateTime.now());
        final daysLeft = diff.inDays;
        
        if (daysLeft < 0) {
          statusLabel = 'Overdue';
          statusColor = const Color(0xFFFF6B6B);
        } else if (daysLeft == 0) {
          statusLabel = 'Due Today';
          statusColor = const Color(0xFFFFAB40);
        } else if (daysLeft < 7) {
          statusLabel = '$daysLeft Days Left';
          statusColor = const Color(0xFFFFAB40);
        } else if (daysLeft < 30) {
          final weeks = (daysLeft / 7).floor();
          statusLabel = '$weeks Weeks Left';
          statusColor = const Color(0xFF00E676);
        } else {
          final months = (daysLeft / 30).floor();
          statusLabel = '$months Months Left';
          statusColor = const Color(0xFF00E676);
        }
      } catch (_) {}
    }

    return GlassCard(
      glowColor: statusColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkspaceScreen(goal: goal),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['title'] ?? '',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          if (goal['description'] != null &&
                              goal['description'].toString().isNotEmpty)
                            Text(
                              goal['description'],
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.5)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // Status badge & Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(statusLabel,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white30, size: 18),
                          padding: EdgeInsets.zero,
                          color: const Color(0xFF1A1F3A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) {
                            if (val == 'archive') context.read<AppProvider>().archiveGoal(goal['id']);
                            if (val == 'delete') context.read<AppProvider>().deleteGoal(goal['id']);
                            if (val == 'edit') {
                              // Link to workspace or dedicated edit
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text("Edit", style: TextStyle(color: Colors.white, fontSize: 13))),
                            const PopupMenuItem(value: 'archive', child: Text("Archive", style: TextStyle(color: Colors.white, fontSize: 13))),
                            const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 13))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress bar with wave effect
                Stack(
                  children: [
                    GlassProgressBar(
                        progress: progress, color: statusColor, height: 10),
                  ],
                ),
                const SizedBox(height: 8),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal['progress'] ?? 0}% complete',
                      style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w500),
                    ),
                    if (deadline.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14, color: Colors.white.withValues(alpha: 0.4)),
                          const SizedBox(width: 4),
                          Text(deadline,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.4))),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Expand for tasks
          const SizedBox(height: 12),
          _TasksExpansion(goalId: goal['id']),
        ],
      ),
    );
  }
}

class _TasksExpansion extends StatefulWidget {
  final int goalId;
  const _TasksExpansion({required this.goalId});

  @override
  State<_TasksExpansion> createState() => _TasksExpansionState();
}

class _TasksExpansionState extends State<_TasksExpansion> {
  bool expanded = false;
  List<Map<String, dynamic>> tasks = [];
  bool loading = false;

  Future<void> _loadTasks() async {
    setState(() => loading = true);
    try {
      tasks = await ApiService.getTasks(widget.goalId);
    } catch (_) {}
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() => expanded = !expanded);
            if (expanded && tasks.isEmpty) _loadTasks();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  expanded ? 'Hide Tasks' : 'Show Tasks',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF6C63FF)),
            )
          else if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('No tasks generated yet',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            )
          else
            ...tasks.map((task) {
              final done =
                  task['is_completed'] == 1 || task['is_completed'] == true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        await ApiService.updateTask(
                            task['id'], {'is_completed': !done});
                        _loadTasks();
                        if (context.mounted)
                          context.read<AppProvider>().loadGoals();
                      },
                      child: Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: done ? const Color(0xFF00E676) : Colors.white30,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task['description'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: done ? Colors.white38 : Colors.white70,
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ],
    );
  }
}
