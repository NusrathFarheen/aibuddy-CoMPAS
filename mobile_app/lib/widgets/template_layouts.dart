import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
// import '../models/workspace_template.dart';

class KanbanView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const KanbanView({super.key, required this.goal});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final res = await ApiService.getTasks(widget.goal['id']);
      setState(() {
        _tasks = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    
    // Distribute real tasks into columns based on completion
    final toLearn = _tasks.where((t) => !(t['is_completed'] == 1 || t['is_completed'] == true)).toList();
    final mastered = _tasks.where((t) => t['is_completed'] == 1 || t['is_completed'] == true).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumn('To Learn', toLearn, Colors.blueAccent),
          _buildColumn('Mastered', mastered, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, List<Map<String, dynamic>> items, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const Spacer(),
                Text('${items.length}', style: const TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ...items.map((item) => _buildCard(item)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> task) {
    final done = task['is_completed'] == 1 || task['is_completed'] == true;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task['description'] ?? '', 
            style: TextStyle(color: done ? Colors.white38 : Colors.white, fontSize: 13, decoration: done ? TextDecoration.lineThrough : null)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _toggleTask(task),
                icon: Icon(done ? Icons.undo_rounded : Icons.check_circle_rounded, 
                  color: done ? Colors.white24 : Colors.greenAccent, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    final done = task['is_completed'] == 1 || task['is_completed'] == true;
    await ApiService.updateTask(task['id'], {'is_completed': !done});
    _loadTasks();
  }
}

class PipelineView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const PipelineView({super.key, required this.goal});

  @override
  State<PipelineView> createState() => _PipelineViewState();
}

class _PipelineViewState extends State<PipelineView> {
  final List<String> _stages = ['Idea', 'Research', 'Draft', 'Review', 'Final'];
  int _currentStageIndex = 1;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final res = await ApiService.getTasks(widget.goal['id']);
      setState(() {
        _tasks = res;
        _currentStageIndex = widget.goal['current_stage'] ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStage(int index) async {
    setState(() => _currentStageIndex = index);
    try {
      await ApiService.updateGoal(widget.goal['id'], {'current_stage': index});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RESEARCH PROGRESSION", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_stages.length, (index) => _buildStageNode(index)),
          ),
          const SizedBox(height: 40),
          _buildStageDetail(),
        ],
      ),
    );
  }

  Widget _buildStageNode(int index) {
    bool isCompleted = index < _currentStageIndex;
    bool isCurrent = index == _currentStageIndex;
    Color color = isCompleted ? Colors.greenAccent : (isCurrent ? Colors.orangeAccent : Colors.white10);

    return Expanded(
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _updateStage(index),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
              ),
              child: Center(
                child: isCompleted 
                  ? Icon(Icons.check, size: 20, color: color)
                  : Text("${index + 1}", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          if (index < _stages.length - 1)
            Expanded(child: Container(height: 2, color: color.withValues(alpha: 0.2))),
        ],
      ),
    );
  }

  Widget _buildStageDetail() {
    final stage = _stages[_currentStageIndex];
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(stage.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_currentStageIndex < _stages.length - 1)
                  ElevatedButton(
                    onPressed: () => _updateStage(_currentStageIndex + 1),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black),
                    child: const Text("PROCEED"),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("GOAL TASKS FOR THIS STAGE:", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isLoading) 
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) => _buildDeliverable(_tasks[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverable(Map<String, dynamic> task) {
    final done = task['is_completed'] == 1 || task['is_completed'] == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await ApiService.updateTask(task['id'], {'is_completed': !done});
              _loadTasks();
            },
            child: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? Colors.greenAccent : Colors.white24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(task['description'] ?? '', style: TextStyle(color: done ? Colors.white24 : Colors.white70, fontSize: 13, decoration: done ? TextDecoration.lineThrough : null))),
        ],
      ),
    );
  }
}

class AgileBoard extends StatefulWidget {
  final Map<String, dynamic> goal;
  const AgileBoard({super.key, required this.goal});

  @override
  State<AgileBoard> createState() => _AgileBoardState();
}

class _AgileBoardState extends State<AgileBoard> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final res = await ApiService.getTasks(widget.goal['id']);
      setState(() {
        _tasks = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));

    final todo = _tasks.where((t) => !(t['is_completed'] == 1 || t['is_completed'] == true)).toList();
    final done = _tasks.where((t) => t['is_completed'] == 1 || t['is_completed'] == true).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumn('Backlog', todo, Colors.cyanAccent),
          _buildColumn('Completed', done, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildColumn(String title, List<Map<String, dynamic>> items, Color color) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.label, size: 14, color: color),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const Spacer(),
                Text('${items.length}', style: const TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ...items.map((item) => _buildTaskCard(item)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final done = task['is_completed'] == 1 || task['is_completed'] == true;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task['description'] ?? '', 
            style: TextStyle(color: done ? Colors.white38 : Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              await ApiService.updateTask(task['id'], {'is_completed': !done});
              _loadTasks();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: done ? Colors.white10 : Colors.cyanAccent.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: done ? Colors.transparent : Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(done ? "REOPEN" : "COMPLETE", 
                  style: TextStyle(color: done ? Colors.white24 : Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
          )
        ],
      ),
    );
  }
}

class MetricTracker extends StatefulWidget {
  final Map<String, dynamic> goal;
  const MetricTracker({super.key, required this.goal});

  @override
  State<MetricTracker> createState() => _MetricTrackerState();
}

class _MetricTrackerState extends State<MetricTracker> {
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _metricLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tasks = await ApiService.getTasks(widget.goal['id']);
      final logs = await ApiService.getFitnessLogs(widget.goal['id'], type: 'metric');
      setState(() {
        _tasks = tasks;
        _metricLogs = logs;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));

    final completedToday = _tasks.where((t) => t['is_completed'] == 1).length;
    final totalTasks = _tasks.length;
    final progressStr = totalTasks > 0 ? "$completedToday / $totalTasks" : "No Plan";
    
    // For MVP, we'll use a simple streak from the goal status or first metric log
    final streak = widget.goal['current_streak']?.toString() ?? "0";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMetricCard('STREAK', streak, 'DAYS 🔥', Colors.orangeAccent),
              const SizedBox(width: 16),
              _buildMetricCard('TODAY', progressStr, 'PROGRESS', Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 24),
          
          const Text("TODAY'S PLAN", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_tasks.isEmpty)
             const Text("No tasks scheduled.", style: TextStyle(color: Colors.white24, fontSize: 12))
          else
            ..._tasks.map((t) => _buildWorkoutItem(t['description'] ?? '', t['status'] ?? 'Active', t['is_completed'] == 1, t['id'])),
          
          const SizedBox(height: 24),

          const Text("WEIGHT PROGRESS", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildGraph(),
          
          const SizedBox(height: 24),
          _buildAddMetricButton(),
        ],
      ),
    );
  }

  Widget _buildGraph() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: SizedBox(
        height: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _metricLogs.isEmpty 
            ? List.generate(10, (i) => Container(width: 8, height: 10, color: Colors.white10))
            : _metricLogs.reversed.take(15).map((log) {
                final val = double.tryParse(log['category'] ?? '0') ?? 10.0; // Assuming category stores a simple weight val for now
                return Container(
                  width: 12,
                  height: (val % 100) + 20, // Scaled for view
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildAddMetricButton() {
    return ElevatedButton.icon(
      onPressed: () => _showAddMetricDialog(),
      icon: const Icon(Icons.add_chart_rounded),
      label: const Text("LOG WEIGHT"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
    );
  }

  void _showAddMetricDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Log Weight", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Enter weight in kg...", hintStyle: TextStyle(color: Colors.white24)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ApiService.createFitnessLog(
                  widget.goal['id'],
                  DateTime.now().toIso8601String().split('T')[0],
                  'metric',
                  controller.text, // Stores weight in category for simple graph
                  {'value': controller.text, 'unit': 'kg'}
                );
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(String title, String sub, bool done, int taskId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.white10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await ApiService.updateTask(taskId, {'is_completed': !done});
              _loadData();
            },
            child: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.greenAccent : Colors.white24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(color: done ? Colors.white38 : Colors.white, fontWeight: FontWeight.bold))),
          Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class WorkoutView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const WorkoutView({super.key, required this.goal});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final res = await ApiService.getFitnessLogs(widget.goal['id'], type: 'workout');
      setState(() {
        _logs = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("WORKOUT LOG", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () => _showAddDialog(),
              icon: const Icon(Icons.add_box_rounded, color: Colors.greenAccent),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_logs.isEmpty)
          const Expanded(child: Center(child: Text("No workouts logged.", style: TextStyle(color: Colors.white24))))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final data = json.decode(log['value']);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 10),
                          Text(data['exercise'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(log['date'], style: const TextStyle(color: Colors.white24, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("${data['sets']} sets x ${data['reps']} reps @ ${data['weight']}kg", 
                        style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddDialog() {
    final exerciseController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Log Workout", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: exerciseController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Exercise Name", hintStyle: TextStyle(color: Colors.white24))),
            Row(
              children: [
                Expanded(child: TextField(controller: setsController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Sets"))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: repsController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Reps"))),
              ],
            ),
            TextField(controller: weightController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Weight (kg)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.createFitnessLog(
                widget.goal['id'],
                DateTime.now().toIso8601String().split('T')[0],
                'workout',
                'strength',
                {
                  'exercise': exerciseController.text,
                  'sets': setsController.text,
                  'reps': repsController.text,
                  'weight': weightController.text,
                }
              );
              Navigator.pop(context);
              _loadLogs();
            },
            child: const Text("Log"),
          ),
        ],
      ),
    );
  }
}

class DietView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const DietView({super.key, required this.goal});

  @override
  State<DietView> createState() => _DietViewState();
}

class _DietViewState extends State<DietView> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final res = await ApiService.getFitnessLogs(widget.goal['id'], type: 'diet');
      setState(() {
        _logs = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCals = 0;
    for (var log in _logs) {
      if (log['date'] == DateTime.now().toIso8601String().split('T')[0]) {
        try {
          final data = json.decode(log['value']);
          totalCals += int.tryParse(data['calories'].toString()) ?? 0;
        } catch (_) {}
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.greenAccent.withValues(alpha: 0.1), Colors.transparent]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("DAILY CALORIES", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text("$totalCals kcal", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showAddDialog(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                child: const Text("LOG MEAL"),
              )
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text("RECENT MEALS", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_logs.isEmpty)
          const Expanded(child: Center(child: Text("No meals logged yet.", style: TextStyle(color: Colors.white24))))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final data = json.decode(log['value']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restaurant_rounded, color: Colors.greenAccent, size: 20),
                  title: Text(data['name'] ?? 'Meal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['calories']} kcal", style: const TextStyle(color: Colors.white38)),
                  trailing: Text(log['date'], style: const TextStyle(color: Colors.white24, fontSize: 10)),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Log Meal", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Meal/Food Name", hintStyle: TextStyle(color: Colors.white24))),
            TextField(controller: calController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Calories", hintStyle: TextStyle(color: Colors.white24))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.createFitnessLog(
                widget.goal['id'],
                DateTime.now().toIso8601String().split('T')[0],
                'diet',
                'meal',
                {'name': nameController.text, 'calories': calController.text}
              );
              Navigator.pop(context);
              _loadLogs();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class PhotosView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const PhotosView({super.key, required this.goal});

  @override
  State<PhotosView> createState() => _PhotosViewState();
}

class _PhotosViewState extends State<PhotosView> {
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final res = await ApiService.getFitnessPhotos(widget.goal['id']);
      setState(() {
        _photos = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("PROGRESS PHOTOS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _showAddDialog(), icon: const Icon(Icons.add_a_photo_rounded, color: Colors.greenAccent)),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_photos.isEmpty)
          const Expanded(child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 48, color: Colors.white10),
              SizedBox(height: 16),
              Text("No photos yet.", style: TextStyle(color: Colors.white24)),
            ],
          )))
        else
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final imageUrl = photo['image_path'].startsWith('http') 
                  ? photo['image_path'] 
                  : "${ApiService.baseUrl}${photo['image_path']}";

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.white10)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(photo['caption'] ?? 'Progress', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(photo['date'], style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddDialog() {
    final captionController = TextEditingController();
    XFile? pickedFile;
    Uint8List? previewBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text("Add Progress Photo", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85, // Compression
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      pickedFile = image;
                      previewBytes = bytes;
                    });
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10, style: BorderStyle.solid),
                  ),
                  child: previewBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(previewBytes!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: Colors.white24, size: 32),
                            SizedBox(height: 8),
                            Text("Click to select photo", style: TextStyle(color: Colors.white24, fontSize: 12)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Caption (e.g. Day 30)",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: (pickedFile == null) ? null : () async {
                try {
                  final bytes = await pickedFile!.readAsBytes();
                  final serverUrl = await ApiService.uploadFile(bytes, pickedFile!.name);
                  
                  await ApiService.createFitnessPhoto(
                    widget.goal['id'],
                    DateTime.now().toIso8601String().split('T')[0],
                    serverUrl,
                    captionController.text
                  );
                  Navigator.pop(context);
                  _loadPhotos();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}

class FunnelView extends StatelessWidget {
  final Map<String, dynamic> goal;
  const FunnelView({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderLayout(title: 'Application Funnel', goal: goal, icon: Icons.filter_list);
  }
}

class DashboardView extends StatelessWidget {
  final Map<String, dynamic> goal;
  const DashboardView({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderLayout(title: 'Analytics Dashboard', goal: goal, icon: Icons.dashboard);
  }
}

class RoadmapView extends StatelessWidget {
  final Map<String, dynamic> goal;
  const RoadmapView({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderLayout(title: 'Product Roadmap', goal: goal, icon: Icons.map);
  }
}

class FreeFlowView extends StatelessWidget {
  final Map<String, dynamic> goal;
  const FreeFlowView({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderLayout(title: 'Creative Free Flow', goal: goal, icon: Icons.auto_awesome);
  }
}

class RoutineView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const RoutineView({super.key, required this.goal});

  @override
  State<RoutineView> createState() => _RoutineViewState();
}

class _RoutineViewState extends State<RoutineView> {
  final Map<String, List<Map<String, dynamic>>> _routines = {
    'MORNING ☀️': [
      {'step': 'Cleanser', 'done': true},
      {'step': 'Vitamin C', 'done': true},
      {'step': 'Moisturizer', 'done': false},
      {'step': 'Sunscreen', 'done': false},
    ],
    'NIGHT 🌙': [
      {'step': 'Oil Cleanser', 'done': false},
      {'step': 'Retinol', 'done': false},
      {'step': 'Eye Cream', 'done': false},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: _routines.entries.map((e) => _buildRoutineGroup(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _buildRoutineGroup(String title, List<Map<String, dynamic>> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...steps.map((s) => _buildStep(s)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStep(Map<String, dynamic> step) {
    bool done = step['done'];
    return GestureDetector(
      onTap: () => setState(() => step['done'] = !done),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done ? Colors.greenAccent.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.greenAccent : Colors.white24, size: 20),
            const SizedBox(width: 16),
            Text(step['step'], style: TextStyle(color: done ? Colors.white38 : Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class ReflectionView extends StatelessWidget {
  final Map<String, dynamic> goal;
  const ReflectionView({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderLayout(title: 'Reflection & Mood', goal: goal, icon: Icons.self_improvement);
  }
}

class ChecklistView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const ChecklistView({super.key, required this.goal});

  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final res = await ApiService.getTasks(widget.goal['id']);
      setState(() {
        _tasks = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.amberAccent));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("WORKSPACE TASKS", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_tasks.isEmpty)
          const Center(child: Text("No tasks found.", style: TextStyle(color: Colors.white24)))
        else
          ..._tasks.map((task) => _buildItem(task)),
      ],
    );
  }

  Widget _buildItem(Map<String, dynamic> task) {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final lastCompleted = task['last_completed']?.toString();
    final isDoneToday = lastCompleted == todayStr;
    
    return GestureDetector(
      onTap: () async {
        final newLastCompleted = isDoneToday ? null : todayStr;
        await ApiService.updateTask(task['id'], {
          'is_completed': isDoneToday ? 0 : 1,
          'last_completed': newLastCompleted,
        });
        _loadTasks();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDoneToday ? Colors.greenAccent.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDoneToday ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.white10),
          boxShadow: [
            if (isDoneToday) BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: -2)
          ]
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                isDoneToday ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, 
                key: ValueKey(isDoneToday),
                color: isDoneToday ? const Color(0xFF00E676) : Colors.white24, 
                size: 22
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['description'] ?? '', 
                    style: TextStyle(
                      color: isDoneToday ? Colors.white38 : Colors.white, 
                      fontSize: 14, 
                      fontWeight: isDoneToday ? FontWeight.normal : FontWeight.w500,
                      decoration: isDoneToday ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (isDoneToday)
                    const Text("Completed for today", style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthorView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const AuthorView({super.key, required this.goal});

  @override
  State<AuthorView> createState() => _AuthorViewState();
}

class _AuthorViewState extends State<AuthorView> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _orcidController;
  late TextEditingController _affiliationController;
  late TextEditingController _coiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal['author_name'] ?? 'John Doe');
    _orcidController = TextEditingController(text: widget.goal['author_orcid'] ?? '0000-0002-1825-0097');
    _affiliationController = TextEditingController(text: widget.goal['author_affiliation'] ?? 'AI Buddy Labs');
    _coiController = TextEditingController(text: 'None declared');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orcidController.dispose();
    _affiliationController.dispose();
    _coiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await ApiService.updateGoal(widget.goal['id'], {
        'author_name': _nameController.text,
        'author_orcid': _orcidController.text,
        'author_affiliation': _affiliationController.text,
      });
      setState(() => _isEditing = false);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("AUTHOR PROFILE", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {
                  if (_isEditing) _save();
                  else setState(() => _isEditing = true);
                },
                icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded, size: 16, color: Colors.orangeAccent),
                label: Text(_isEditing ? "SAVE" : "EDIT", style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const CircleAvatar(radius: 40, backgroundColor: Colors.orangeAccent, child: Icon(Icons.person, size: 40, color: Colors.white)),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing)
                      TextField(controller: _nameController, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                    else
                      Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Lead Researcher - ${widget.goal['title']}", style: const TextStyle(color: Colors.white38, fontSize: 14)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 40),
          _buildInfoRow("Affiliation", _affiliationController),
          _buildInfoRow("ORCID", _orcidController),
          _buildInfoRow("Conflict of Interest", _coiController),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          if (_isEditing)
            TextField(controller: controller, style: const TextStyle(color: Colors.white70, fontSize: 14))
          else
            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(controller.text, style: const TextStyle(color: Colors.white70, fontSize: 14)))
        ],
      ),
    );
  }
}

class FinalizationView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const FinalizationView({super.key, required this.goal});

  @override
  State<FinalizationView> createState() => _FinalizationViewState();
}

class _FinalizationViewState extends State<FinalizationView> {
  bool _isFinalizing = false;
  String? _message;

  Future<void> _finalize() async {
    setState(() => _isFinalizing = true);
    try {
      final res = await ApiService.finalizeGoal(widget.goal['id']);
      setState(() => _message = res['message']);
    } catch (e) {
      setState(() => _message = "Error: $e");
    }
    setState(() => _isFinalizing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 80, color: Colors.orangeAccent),
          const SizedBox(height: 24),
          const Text("READY FOR SUBMISSION?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("All checks passed. Your paper is formatted and ready.", style: TextStyle(color: Colors.white38, fontSize: 14)),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(_message!, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isFinalizing ? null : _finalize,
            icon: _isFinalizing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.publish_rounded),
            label: Text(_isFinalizing ? "FINALIZING..." : "GENERATE FINAL PDF"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          )
        ],
      ),
    );
  }
}

class ReferencesView extends StatefulWidget {
  final Map<String, dynamic> goal;
  const ReferencesView({super.key, required this.goal});

  @override
  State<ReferencesView> createState() => _ReferencesViewState();
}

class _ReferencesViewState extends State<ReferencesView> {
  List<Map<String, dynamic>> _references = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    try {
      final res = await ApiService.getReferences(widget.goal['id']);
      setState(() {
        _references = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Add Reference", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Title", hintStyle: TextStyle(color: Colors.white24))),
            TextField(controller: urlController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "URL", hintStyle: TextStyle(color: Colors.white24))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                await ApiService.createReference(widget.goal['id'], titleController.text, urlController.text);
                Navigator.pop(context);
                _loadReferences();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("REFERENCES & CITATIONS", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
            IconButton(onPressed: _showAddDialog, icon: const Icon(Icons.add_link_rounded, color: Colors.orangeAccent)),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_references.isEmpty)
          const Center(child: Text("No references yet.", style: TextStyle(color: Colors.white24)))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _references.length,
              itemBuilder: (context, index) {
                final ref = _references[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: Colors.orangeAccent, size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ref['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(ref['url'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await ApiService.deleteReference(ref['id']);
                          _loadReferences();
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 18),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}


class _PlaceholderLayout extends StatelessWidget {
  final String title;
  final Map<String, dynamic> goal;
  final IconData icon;
  
  const _PlaceholderLayout({required this.title, required this.goal, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white60)),
          const SizedBox(height: 8),
          Text('Interactive system coming soon...', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 12)),
        ],
      ),
    );
  }
}
