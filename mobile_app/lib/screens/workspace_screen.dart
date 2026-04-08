import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import '../models/workspace_template.dart';
import '../widgets/template_layouts.dart';

class WorkspaceScreen extends StatefulWidget {
  final Map<String, dynamic> goal;
  const WorkspaceScreen({super.key, required this.goal});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late WorkspaceTemplate _template;
  late List<WorkspaceSectionType> _tabSections;
  int _selectedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    String templateId = widget.goal['template_id'] ?? 'daily';
    // If it's a generic 'daily' template, try to re-infer to see if we have a better specialized one now
    if (templateId == 'daily') {
      final inferred = TemplateRegistry.inferTemplateId(widget.goal['title'] ?? '');
      if (inferred != 'daily') templateId = inferred;
    }
    _template = TemplateRegistry.getTemplate(templateId);

    _tabSections = _template.sections
        .where((s) => s != WorkspaceSectionType.chat)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.goal['progress'] ?? 0) / 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Column(
        children: [
          // ── TOP BAR (Progress & Title) ──
          _buildTopBar(progress),
          
          Expanded(
            child: Row(
              children: [
                // ── LEFT NAV (Vertical Tabs) ──
                _buildLeftNav(),
                
                // ── CENTER CONTENT ──
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: _buildSectionWidget(_tabSections[_selectedSectionIndex]),
                  ),
                ),
                
                // ── RIGHT CHAT (Persistent) ──
                _buildRightChat(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nav Back + Title Row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                "WORKSPACE",
                style: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text(
                widget.goal['title']?.toUpperCase() ?? 'UNTITLED GOAL',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              // Profile Pill (Compact)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 10, backgroundColor: Colors.purpleAccent, child: Icon(Icons.person, size: 12, color: Colors.white)),
                    SizedBox(width: 8),
                    Text("John Doe", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(_template.themeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftNav() {
    return Container(
      width: 120,
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: ListView.builder(
        itemCount: _tabSections.length,
        itemBuilder: (context, index) {
          final section = _tabSections[index];
          final isSelected = _selectedSectionIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedSectionIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                border: isSelected ? Border(right: BorderSide(color: _template.themeColor, width: 3)) : null,
                gradient: isSelected ? LinearGradient(
                  colors: [_template.themeColor.withValues(alpha: 0.1), Colors.transparent],
                ) : null,
              ),
              child: Column(
                children: [
                  Icon(
                    _getSectionIcon(section),
                    color: isSelected ? _template.themeColor : Colors.white38,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightChat() {
    return Container(
      width: 350,
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        border: Border(left: BorderSide(color: Colors.white10)),
      ),
      child: _WorkspaceChatPanel(goalId: widget.goal['id'], aiRole: _template.aiRole),
    );
  }

  Widget _buildSectionWidget(WorkspaceSectionType type) {
    // Priority: Map the primary action sections to their specialized layouts
    if (type == WorkspaceSectionType.kanban || (_template.interactionStyle == InteractionStyle.kanban && type == WorkspaceSectionType.tasks)) {
      return KanbanView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.agile || (_template.interactionStyle == InteractionStyle.agile && type == WorkspaceSectionType.tasks)) {
      return AgileBoard(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.pipeline || (_template.interactionStyle == InteractionStyle.pipeline && type == WorkspaceSectionType.tasks)) {
      return PipelineView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.metrics || (_template.interactionStyle == InteractionStyle.tracker && type == WorkspaceSectionType.tasks)) {
      return MetricTracker(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.routine || (_template.interactionStyle == InteractionStyle.routine && type == WorkspaceSectionType.tasks)) {
      return RoutineView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.habit || (_template.interactionStyle == InteractionStyle.checklist && type == WorkspaceSectionType.tasks)) {
      return ChecklistView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.author) {
      return AuthorView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.finalization) {
      return FinalizationView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.workout) {
      return WorkoutView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.diet) {
      return DietView(goal: widget.goal);
    }
    if (type == WorkspaceSectionType.photos) {
      return PhotosView(goal: widget.goal);
    }

    // Secondary sections
    switch (type) {
      case WorkspaceSectionType.draft:
      case WorkspaceSectionType.notes:
        return _DraftEditor(goalId: widget.goal['id'], type: type.name);
      case WorkspaceSectionType.references:
        return ReferencesView(goal: widget.goal);
      default:
        return _buildPlaceholder(type);
    }
  }

  Widget _buildPlaceholder(WorkspaceSectionType type) {
    return Center(
      child: GlassCard(
        glowColor: _template.themeColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, color: _template.themeColor, size: 48),
            const SizedBox(height: 16),
            Text("${type.name.toUpperCase()} View Coming Soon",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("AI Buddy is preparing this workspace section...",
                style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }


  IconData _getSectionIcon(WorkspaceSectionType type) {
    switch (type) {
      case WorkspaceSectionType.tasks: return Icons.checklist_rtl;
      case WorkspaceSectionType.draft: return Icons.edit_note;
      case WorkspaceSectionType.notes: return Icons.notes;
      case WorkspaceSectionType.references: return Icons.link;
      case WorkspaceSectionType.routine: return Icons.psychology;
      case WorkspaceSectionType.metrics: return Icons.analytics;
      case WorkspaceSectionType.kanban: return Icons.view_kanban;
      case WorkspaceSectionType.agile: return Icons.reorder;
      case WorkspaceSectionType.pipeline: return Icons.auto_mode;
      case WorkspaceSectionType.habit: return Icons.today;
      case WorkspaceSectionType.author: return Icons.person_outline_rounded;
      case WorkspaceSectionType.finalization: return Icons.verified_rounded;
      default: return Icons.category;
    }
  }
}

class _DraftEditor extends StatefulWidget {
  final int goalId;
  final String type;
  const _DraftEditor({required this.goalId, required this.type});

  @override
  _DraftEditorState createState() => _DraftEditorState();
}

class _DraftEditorState extends State<_DraftEditor> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Map<String, dynamic>> _savedItems = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final res = await ApiService.getNotes(widget.goalId);
      setState(() {
        _savedItems = res; // Filter by type if needed
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_contentController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.createNote(
        widget.goalId,
        _titleController.text.isEmpty ? widget.type.toUpperCase() : _titleController.text,
        _contentController.text
      );
      _titleController.clear();
      _contentController.clear();
      await _loadItems();
    } catch (_) {}
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: 'Title...', border: InputBorder.none),
              ),
              const Divider(color: Colors.white12),
              TextField(
                controller: _contentController,
                maxLines: 6,
                style: const TextStyle(color: Colors.white70),
                decoration: const InputDecoration(hintText: 'Start writing...', border: InputBorder.none),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Saving...' : 'Save & Store'),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _savedItems.length,
            itemBuilder: (context, index) {
              final item = _savedItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(item['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(item['content'] ?? '', style: const TextStyle(color: Colors.white54), maxLines: 2),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class _WorkspaceChatPanel extends StatefulWidget {
  final int goalId;
  final String? aiRole;
  const _WorkspaceChatPanel({required this.goalId, this.aiRole});

  @override
  State<_WorkspaceChatPanel> createState() => _WorkspaceChatPanelState();
}

class _WorkspaceChatPanelState extends State<_WorkspaceChatPanel> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final res = await ApiService.getChatHistory(goalId: widget.goalId);
      setState(() {
        _messages.clear();
        for (var m in res) {
          _messages.add({
            'isUser': m['role'] == 'user',
            'text': m['content'],
          });
        }
      });
    } catch (_) {}
  }

  Future<void> _send() async {
    if (_msgController.text.isEmpty) return;
    final text = _msgController.text;
    _msgController.clear();
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _isLoading = true;
    });

    try {
      final reply = await ApiService.sendChat(text, goalId: widget.goalId, role: widget.aiRole);
      setState(() {
        _messages.add({
          'isUser': false,
          'text': reply['response'],
          'memories': reply['memories_used']
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({'isUser': false, 'text': 'Error: $e'});
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black.withValues(alpha: 0.2),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
              SizedBox(width: 12),
              Text("AI BUDDY CHAT", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return _ChatBubble(text: msg['text'], isUser: msg['isUser'], memoriesUsed: msg['memories']);
            },
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.cyanAccent),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _send, icon: const Icon(Icons.send_rounded, color: Colors.cyanAccent)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final int? memoriesUsed;
  const _ChatBubble({required this.text, required this.isUser, this.memoriesUsed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.purpleAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : null,
            bottomLeft: !isUser ? Radius.zero : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
            if (memoriesUsed != null && memoriesUsed! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.memory, size: 10, color: Colors.cyanAccent),
                    const SizedBox(width: 4),
                    Text("Recalled $memoriesUsed memories", style: const TextStyle(color: Colors.cyanAccent, fontSize: 9)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
