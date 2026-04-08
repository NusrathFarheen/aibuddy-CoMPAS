import 'package:flutter/material.dart';
import 'glass_card.dart';
import 'dart:math' as math;

class GoalWaveCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  final VoidCallback onTap;
  final int index;

  final Function(Map<String, dynamic>)? onEdit;
  final Function(int)? onDelete;
  final Function(int)? onArchive;

  const GoalWaveCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.index,
    this.onEdit,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    // Premium Vibrant Palettes
    final palettes = [
      [const Color(0xFF6C63FF), const Color(0xFF32D7FF), const Color(0xFF21E1E1)], // Neo Blue
      [const Color(0xFFFF5F6D), const Color(0xFFFFC371), const Color(0xFFFFD194)], // Sunset Flare
      [const Color(0xFF11998E), const Color(0xFF38EF7D), const Color(0xFF88FFB4)], // Emerald Pulse
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0), const Color(0xFF7B61FF)], // Cosmic Purple
    ];
    
    final palette = palettes[index % palettes.length];
    final primaryColor = palette[0];
    final accentColor = palette[1];
    final glowColor = palette[2];

    final double progressPct = double.tryParse(goal['progress']?.toString() ?? '0') ?? 0;
    final double progress = (progressPct / 100).clamp(0.0, 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          blur: 20,
          opacity: 0.08,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 1. Dynamic Wave Background
                Positioned.fill(
                  child: AnimatedWaveBackground(
                    progress: progress,
                    color1: primaryColor,
                    color2: accentColor,
                    color3: glowColor,
                  ),
                ),
                
                // 2. Center Content (Floating)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Percentage Text
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withValues(alpha: 0.7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          "${progressPct.toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Text(
                          goal['title'] ?? 'Untitled',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action Button
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.7), size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 3. Deadline Label (Bottom Right)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildDeadlineLabel(goal['deadline']),
                ),

                // 4. Options Menu
                Positioned(
                  top: 12,
                  right: 8,
                  child: _buildOptionsMenu(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white54, size: 22),
      padding: EdgeInsets.zero,
      color: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 40),
      onSelected: (value) {
        final id = goal['id'] as int?;
        if (id == null) return;
        switch (value) {
          case 'edit': if (onEdit != null) onEdit!(goal); break;
          case 'delete': if (onDelete != null) onDelete!(id); break;
          case 'archive': if (onArchive != null) onArchive!(id); break;
        }
      },
      itemBuilder: (context) => [
        _buildPopupItem('edit', Icons.edit_rounded, 'Modify'),
        _buildPopupItem('archive', Icons.archive_rounded, 'Archive'),
        const PopupMenuDivider(height: 1),
        _buildPopupItem('delete', Icons.delete_rounded, 'Discard', color: Colors.redAccent),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, {Color? color}) {
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white70, size: 18),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: color ?? Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDeadlineLabel(dynamic deadlineString) {
    final now = DateTime.now();
    String label = "DAILY FOCUS";
    Color color = Colors.white60;

    if (deadlineString != null && deadlineString.toString().isNotEmpty) {
      try {
        final deadline = DateTime.parse(deadlineString.toString());
        final diff = deadline.difference(now).inDays;
        if (diff < 0) {
          label = "OVERDUE"; color = Colors.redAccent;
        } else if (diff == 0) {
          label = "DUE TODAY"; color = Colors.orangeAccent;
        } else {
          label = "$diff DAYS LEFT"; color = Colors.white70;
        }
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}

class AnimatedWaveBackground extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Color color1;
  final Color color2;
  final Color color3;

  const AnimatedWaveBackground({
    super.key,
    required this.progress,
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MultiWavePainter(
            animationValue: _controller.value,
            progress: widget.progress,
            color1: widget.color1,
            color2: widget.color2,
            color3: widget.color3,
          ),
        );
      },
    );
  }
}

class MultiWavePainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color color1;
  final Color color2;
  final Color color3;

  MultiWavePainter({
    required this.animationValue,
    required this.progress,
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The "Water Line" - 1.0 is bottom, 0.0 is top.
    final double baseHeight = size.height * (1.0 - progress);

    // Wave 1: Deep Background
    _drawWave(canvas, size, baseHeight, animationValue, 1.2, 15, color1.withValues(alpha: 0.3));
    
    // Wave 2: Middle
    _drawWave(canvas, size, baseHeight + 5, animationValue + 0.3, 0.8, 20, color2.withValues(alpha: 0.4));
    
    // Wave 3: Top/Glow
    _drawWave(canvas, size, baseHeight + 10, animationValue + 0.7, 1.0, 10, color3.withValues(alpha: 0.6));
  }

  void _drawWave(Canvas canvas, Size size, double baseHeight, double offset, double frequency, double amplitude, Color color) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withValues(alpha: 0.1)],
      ).createShader(Rect.fromLTWH(0, baseHeight - amplitude, size.width, size.height - baseHeight + amplitude));

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, baseHeight);

    for (double i = 0; i <= size.width; i++) {
       // y = amplitude * sin(2 * pi * f * x + offset)
       double y = baseHeight + amplitude * math.sin((i / size.width * 2 * math.pi * frequency) + (offset * 2 * math.pi));
       path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MultiWavePainter oldDelegate) => true;
}
