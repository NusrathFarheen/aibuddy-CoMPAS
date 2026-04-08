import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'glass_card.dart';

class ZenModeDialog extends StatelessWidget {
  const ZenModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1F).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ZEN MODE", style: TextStyle(color: Colors.cyanAccent, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.w900)),
                    Text("Focus Sanctuary", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Switch(
                  value: provider.isFocusMode, 
                  onChanged: (_) => provider.toggleFocusMode(),
                  thumbColor: WidgetStateProperty.all(Colors.cyanAccent),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text("SOUNDSCAPE", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _AmbienceTile(name: "Silence", icon: Icons.volume_off_rounded, color: Colors.blueGrey),
                  _AmbienceTile(name: "Rain", icon: Icons.umbrella_rounded, color: Colors.blueAccent),
                  _AmbienceTile(name: "Forest", icon: Icons.forest_rounded, color: Colors.greenAccent),
                  _AmbienceTile(name: "Lo-Fi", icon: Icons.headset_rounded, color: Colors.purpleAccent),
                  _AmbienceTile(name: "Waves", icon: Icons.waves_rounded, color: Colors.cyanAccent),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text("FOCUS SESSION", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GlassCard(
              margin: EdgeInsets.all(0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              glowColor: Colors.cyanAccent.withValues(alpha: 0.1),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        provider.isTimerRunning ? Icons.hourglass_top_rounded : Icons.timer_outlined, 
                        color: Colors.cyanAccent
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.isTimerRunning ? "Deep Work Progress" : "Set Your Interval", 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                            Text(
                              provider.isTimerRunning ? provider.timerString : "Focus for ${provider.initialFocusMinutes} minutes", 
                              style: TextStyle(color: provider.isTimerRunning ? Colors.cyanAccent : Colors.white38, fontSize: provider.isTimerRunning ? 20 : 12, fontWeight: provider.isTimerRunning ? FontWeight.w900 : FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      if (provider.isTimerRunning)
                        IconButton(
                          onPressed: () => provider.stopTimer(),
                          icon: const Icon(Icons.stop_rounded, color: Colors.redAccent),
                        )
                      else
                        IconButton(
                          onPressed: () => provider.startTimer(),
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.cyanAccent, size: 32),
                        ),
                    ],
                  ),
                  if (!provider.isTimerRunning) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [5, 10, 15, 30, 45, 60].map((m) {
                        bool isInit = provider.initialFocusMinutes == m;
                        return GestureDetector(
                          onTap: () => provider.setTimerMinutes(m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isInit ? Colors.cyanAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isInit ? Colors.cyanAccent : Colors.white10),
                            ),
                            child: Text(
                              "$m", 
                              style: TextStyle(color: isInit ? Colors.white : Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (provider.isTimerRunning) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: LinearProgressIndicator(
                  value: provider.focusSeconds == 0 ? 0 : 1 - (provider.focusSeconds / (provider.initialFocusMinutes * 60)),
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(Colors.cyanAccent),
                  minHeight: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmbienceTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const _AmbienceTile({required this.name, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isSelected = provider.selectedAmbience == name;
    
    return GestureDetector(
      onTap: () => provider.setAmbience(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color.withValues(alpha: 0.5) : Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white24, size: 28),
            const SizedBox(height: 8),
            Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
