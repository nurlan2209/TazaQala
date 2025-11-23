import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'auth_screen.dart';
import 'director_admins_screen.dart';
import 'my_reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  void _showEditProfileBottomSheet(String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final mediaPadding = MediaQuery.of(context).viewInsets;
        final isMobile = MediaQuery.of(context).size.width < 600;
        return Padding(
          padding: EdgeInsets.only(
            left: isMobile ? 16 : 20,
            right: isMobile ? 16 : 20,
            top: isMobile ? 16 : 20,
            bottom: mediaPadding.bottom + (isMobile ? 16 : 20),
          ),
          child: StatefulBuilder(
            builder: (context, setStateSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Профильді өңдеу',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: nameController,
                    label: 'Аты-жөні',
                    icon: Icons.person_outline,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    isMobile: isMobile,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: passwordController,
                    label: 'Жаңа құпия сөз (қаласаңыз)',
                    icon: Icons.lock_outline,
                    isMobile: isMobile,
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: confirmController,
                    label: 'Қайта енгізіңіз',
                    icon: Icons.lock_outline,
                    isMobile: isMobile,
                    obscure: true,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final email = emailController.text.trim();
                              final pass = passwordController.text;
                              final confirm = confirmController.text;

                              if (name.isEmpty || email.isEmpty) {
                                _showSnack('Барлық негізгі өрістерді толтырыңыз',
                                    isError: true);
                                return;
                              }
                              if (!email.contains('@')) {
                                _showSnack('Email форматы дұрыс емес',
                                    isError: true);
                                return;
                              }
                              if (pass.isNotEmpty && pass != confirm) {
                                _showSnack('Құпия сөздер сәйкес келмейді',
                                    isError: true);
                                return;
                              }

                              setStateSheet(() => isProcessing = true);
                              final ok = await context
                                  .read<AuthProvider>()
                                  .updateProfile(
                                    name: name,
                                    email: email,
                                    password: pass.isEmpty ? null : pass,
                                  );
                              setStateSheet(() => isProcessing = false);
                              if (ok) {
                                _showSnack('Профиль жаңартылды');
                                if (mounted) Navigator.pop(context);
                              } else {
                                final msg = context
                                        .read<AuthProvider>()
                                        .errorMessage ??
                                    'Қате пайда болды';
                                _showSnack(msg, isError: true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E9B8E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Сақтау',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isMobile,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: isMobile ? 20 : 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 12 : 14,
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFF2E9B8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name ?? 'Пайдаланушы';
    final userEmail = authProvider.user?.email ?? 'user@example.com';
    final isAdmin = authProvider.isAdmin;
    final isDirector = authProvider.isDirector;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isMobile ? 230 : 270,
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
                background: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Профильді өңдеу',
                    onTap: () => _showEditProfileBottomSheet(userName, userEmail),
                    isMobile: isMobile,
                  ),
                  if (!isDirector)
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Менің шағымдарым',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyReportsScreen(),
                          ),
                        );
                      },
                      isMobile: isMobile,
                    ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Хабарламалар',
                    onTap: () {},
                    isMobile: isMobile,
                  ),
                  if (isAdmin)
                    _buildMenuItem(
                      icon: Icons.admin_panel_settings,
                      title: 'Админ панелі',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                      isMobile: isMobile,
                    ),
                  if (!isDirector)
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'Қосымша туралы',
                      onTap: () {},
                      isMobile: isMobile,
                    ),
                  SizedBox(height: isMobile ? 24 : 32),
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
