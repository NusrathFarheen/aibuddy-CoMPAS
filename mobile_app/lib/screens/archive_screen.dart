import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final archivedGoals = provider.goals.where((g) => g['is_archived'] == 1 || g['is_archived'] == true).toList();
        final archivedCreations = provider.creations.where((c) => c['is_archived'] == 1 || c['is_archived'] == true).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("RESTRICTED ACCESS", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
                const Text("ARCHIVE", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                
                Expanded(
                  child: ListView(
                    children: [
                      if (archivedGoals.isNotEmpty) ...[
                        const _SectionHeader(title: "ARCHIVED GOALS"),
                        const SizedBox(height: 16),
                        ...archivedGoals.map((g) => _ArchiveItem(
                          title: g['title'] ?? 'Untitled', 
                          subtitle: "Goal • ${g['deadline']}",
                          icon: Icons.flag_rounded,
                          color: const Color(0xFF6C63FF),
                        )),
                        const SizedBox(height: 32),
                      ],
                      
                      if (archivedCreations.isNotEmpty) ...[
                        const _SectionHeader(title: "ARCHIVED VAULT ITEMS"),
                        const SizedBox(height: 16),
                        ...archivedCreations.map((c) => _ArchiveItem(
                          title: c['title'] ?? 'Untitled', 
                          subtitle: "${c['type']?.toString().toUpperCase()} • ${c['created_at']?.toString().substring(0, 10)}",
                          icon: Icons.layers_rounded,
                          color: const Color(0xFFFFAB40),
                        )),
                      ],
                      
                      if (archivedGoals.isEmpty && archivedCreations.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(60.0),
                            child: Column(
                              children: [
                                Icon(Icons.archive_outlined, size: 48, color: Colors.white10),
                                SizedBox(height: 16),
                                Text("Archive is empty.", style: TextStyle(color: Colors.white24)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(width: 16),
        Expanded(child: Container(height: 1, color: Colors.white10)),
      ],
    );
  }
}

class _ArchiveItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  
  const _ArchiveItem({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        glowColor: color.withValues(alpha: 0.1),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {}, // TODO: Implement Unarchive
              icon: const Icon(Icons.unarchive_rounded, color: Colors.white24, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
