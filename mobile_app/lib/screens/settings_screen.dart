import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _keyController = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await AuthService.getGroqKey();
    if (key != null) setState(() => _keyController.text = key);
  }

  Future<void> _saveKey() async {
    await AuthService.saveGroqKey(_keyController.text);
    setState(() => _isSaved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSaved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Control Center",
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "Manage your cognitive connections and AI tokens.",
              style: GoogleFonts.inter(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amberAccent),
                        const SizedBox(width: 12),
                        Text(
                          "Groq API Configuration",
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Your personal API key is stored locally on this device. We use your key to process AI requests so you aren't limited by system-wide quotas.",
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _keyController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: "Groq API Key (gsk_...)",
                        labelStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        suffixIcon: IconButton(
                          icon: Icon(_isSaved ? Icons.check_circle : Icons.save, color: _isSaved ? Colors.greenAccent : Colors.blueAccent),
                          onPressed: _saveKey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isSaved)
                      const Text("✅ Key saved successfully!", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await AuthService.logout();
                  if (mounted) Navigator.pushReplacementNamed(context, '/auth');
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text("Logout of this session", style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
