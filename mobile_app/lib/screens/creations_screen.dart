import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import 'package:flutter/services.dart';

class CreationsScreen extends StatelessWidget {
  const CreationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCaptureDialog(context),
            backgroundColor: const Color(0xFFFFAB40),
            child: const Icon(Icons.add, color: Colors.black),
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
                        Text("SYNAPTIC", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
                        Text("VAULT", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("ALL", true, Colors.white),
                      _buildFilterChip("IDEAS", false, const Color(0xFFFFAB40)),
                      _buildFilterChip("SNIPPETS", false, const Color(0xFF00E676)),
                      _buildFilterChip("RESEARCH", false, const Color(0xFF00D9FF)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Expanded(
                  child: provider.creations.where((c) => c['is_archived'] != 1 && c['is_archived'] != true).isEmpty
                    ? const _EmptyVault()
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: provider.creations.where((c) => c['is_archived'] != 1 && c['is_archived'] != true).length,
                        itemBuilder: (context, index) {
                          final filtered = provider.creations.where((c) => c['is_archived'] != 1 && c['is_archived'] != true).toList();
                          final item = filtered[index];
                          return _CreationCard(
                            item: item, 
                            onEdit: () => _showCaptureDialog(context, item: item)
                          );
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
                Text("Search vault...", style: TextStyle(color: Colors.white38, fontSize: 13)),
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

  Widget _buildFilterChip(String label, bool isSelected, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? color.withValues(alpha: 0.3) : Colors.white10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? color : Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showCaptureDialog(BuildContext context, {Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final titleCtrl = TextEditingController(text: item?['title'] ?? '');
    final contentCtrl = TextEditingController(text: item?['content'] ?? '');
    String selectedType = item?['type'] ?? 'idea';

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
              Text(
                isEdit ? "Modify Capture" : "Capture to Vault",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   _buildTypeOption(setModalState, 'idea', 'IDEA', const Color(0xFFFFAB40), selectedType == 'idea', (val) => setModalState(() => selectedType = val)),
                   _buildTypeOption(setModalState, 'snippet', 'SNIPPET', const Color(0xFF00E676), selectedType == 'snippet', (val) => setModalState(() => selectedType = val)),
                   _buildTypeOption(setModalState, 'research', 'RESEARCH', const Color(0xFF00D9FF), selectedType == 'research', (val) => setModalState(() => selectedType = val)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Title...",
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Concept or content...",
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
                      if (isEdit) {
                        context.read<AppProvider>().updateCreation(item['id'], {
                          'title': titleCtrl.text,
                          'content': contentCtrl.text,
                          'type': selectedType,
                        });
                      } else {
                        context.read<AppProvider>().addCreation(titleCtrl.text, contentCtrl.text, selectedType);
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit ? const Color(0xFF00E676) : const Color(0xFFFFAB40),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(isEdit ? "Save Changes" : "Commit to Vault", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(StateSetter setModalState, String type, String label, Color color, bool isSelected, Function(String) onSelect) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSelected ? color : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  const _CreationCard({required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final type = item['type'] ?? 'note';
    final typeColor = _typeColor(type);

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      glowColor: typeColor.withValues(alpha: 0.2),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(_typeIcon(type), color: typeColor, size: 18),
                  Text(
                    type.toUpperCase(),
                    style: TextStyle(color: typeColor.withValues(alpha: 0.5), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item['title'] ?? '',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  item['content'] ?? '',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['created_at']?.toString().substring(0, 10) ?? 'RECENT',
                    style: const TextStyle(color: Colors.white12, fontSize: 9),
                  ),
                  const Icon(Icons.open_in_new_rounded, color: Colors.white24, size: 12),
                ],
              ),
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white24, size: 18),
              padding: EdgeInsets.zero,
              color: const Color(0xFF1A1F3A),
              onSelected: (val) {
                if (val == 'delete') context.read<AppProvider>().deleteCreation(item['id']);
                if (val == 'archive') context.read<AppProvider>().archiveCreation(item['id']);
                if (val == 'edit') onEdit();
                if (val == 'copy') {
                  Clipboard.setData(ClipboardData(text: "${item['title']}\n\n${item['content']}"));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 14), SizedBox(width: 8), Text("Edit", style: TextStyle(fontSize: 12))])),
                const PopupMenuItem(value: 'archive', child: Row(children: [Icon(Icons.archive, size: 14), SizedBox(width: 8), Text("Archive", style: TextStyle(fontSize: 12))])),
                const PopupMenuItem(value: 'copy', child: Row(children: [Icon(Icons.copy, size: 14), SizedBox(width: 8), Text("Copy", style: TextStyle(fontSize: 12))])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 14, color: Colors.redAccent), SizedBox(width: 8), Text("Delete", style: TextStyle(fontSize: 12, color: Colors.redAccent))])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'idea': return const Color(0xFFFFAB40);
      case 'snippet': return const Color(0xFF00E676);
      case 'research': return const Color(0xFF00D9FF);
      default: return const Color(0xFF6C63FF);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'idea': return Icons.lightbulb_outline_rounded;
      case 'snippet': return Icons.code_rounded;
      case 'research': return Icons.science_rounded;
      default: return Icons.note_alt_outlined;
    }
  }
}

class _EmptyVault extends StatelessWidget {
  const _EmptyVault();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_clear_outlined, size: 64, color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          const Text("VAULT EMPTY", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const Text("Capture your next big idea with AI Buddy.", style: TextStyle(color: Colors.white10, fontSize: 11)),
        ],
      ),
    );
  }
}
