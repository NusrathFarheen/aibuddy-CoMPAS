import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../services/auth_service.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 260,
      borderRadius: 0,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      glowColor: Colors.purple.withValues(alpha: 0.1),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C0F35),
          border: Border(right: BorderSide(color: Colors.white10)),
        ),
        child: Column(
          children: [
            // 3D Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/robot_3d.png',
                    height: 40,
                    width: 40,
                    errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, color: Colors.cyanAccent, size: 40),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "AI Buddy",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavItem(0, "Dashboard", Icons.speed),
                    _buildNavItem(1, "Goals", Icons.analytics_outlined),
                    _buildNavItem(2, "Habits", Icons.checklist_rtl),
                    _buildNavItem(3, "Journal", Icons.book_outlined),
                    _buildNavItem(4, "Creations", Icons.layers_outlined),
                    _buildNavItem(5, "AI Chat", Icons.chat_bubble_outline),
                    _buildNavItem(6, "Connect", Icons.people_outline),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Divider(color: Colors.white12),
                    ),
                    
                    _buildNavItem(7, "History", Icons.history),
                    _buildNavItem(8, "Notifications", Icons.notifications_none),
                    _buildNavItem(9, "Archive", Icons.archive_outlined),
                    _buildNavItem(11, "Control Center", Icons.settings_outlined),

                    const SizedBox(height: 20),
                    // Recommended Products Section
                    GestureDetector(
                      onTap: () => onItemSelected(10), // Store
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, color: Colors.white70),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Recommended", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text("Products", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  FutureBuilder<String?>(
                    future: AuthService.getUsername(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            "Signed in as: ${snapshot.data}",
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  _buildFooterItem("Logout", Icons.logout, () async {
                    await AuthService.logout();
                    if (context.mounted) Navigator.pushReplacementNamed(context, '/auth');
                  }),
                  _buildFooterItem("Help", Icons.help_outline, () {}),
                  _buildFooterItem("About", Icons.info_outline, () => onItemSelected(12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: isSelected ? BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B3B3B), Color(0xFF1E1E1E)], 
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          if (isSelected) BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
        ]
      ) : null,
      child: ListTile(
        onTap: () {
          onItemSelected(index);
        },
        leading: Icon(
          icon,
          color: isSelected ? Colors.cyanAccent : Colors.white70,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        horizontalTitleGap: 0,
        visualDensity: const VisualDensity(vertical: -2),
      ),
    );
  }

  Widget _buildFooterItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
