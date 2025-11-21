import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Пайдаланушы';
      userEmail = prefs.getString('userEmail') ?? 'user@example.com';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isMobile ? 200 : 240,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E9B8E), Color(0xFF3D8FCC)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isMobile ? 50 : 60),
                    CircleAvatar(
                      radius: isMobile ? 45 : 55,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'П',
                        style: TextStyle(
                          fontSize: isMobile ? 36 : 44,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E9B8E),
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      userEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Профильді өңдеу',
                    onTap: () {},
                    isMobile: isMobile,
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Менің шағымдарым',
                    onTap: () {},
                    isMobile: isMobile,
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Хабарламалар',
                    onTap: () {},
                    isMobile: isMobile,
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Параметрлер',
                    onTap: () {},
                    isMobile: isMobile,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Анықтама',
                    onTap: () {},
                    isMobile: isMobile,
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Қосымша туралы',
                    onTap: () {},
                    isMobile: isMobile,
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Шығу',
                    onTap: _logout,
                    isMobile: isMobile,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isMobile,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF2E9B8E),
          size: isMobile ? 22 : 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.grey[800],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isMobile ? 16 : 18,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
