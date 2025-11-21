import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'profile_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Вход
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Регистрация
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  // ================= ВСПОМОГАТЕЛЬНЫЕ =================

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> _getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');

    if (usersJson == null || usersJson.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> users = json.decode(usersJson);
      return users;
    } catch (e) {
      debugPrint('Ошибка парсинга users: $e');
      return {};
    }
  }

  Future<bool> _saveUser(String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> users = await _getAllUsers();

      if (users.containsKey(email)) {
        // уже есть такой email
        return false;
      }

      users[email] = {
        'name': name,
        'email': email,
        'password': _hashPassword(password),
        'createdAt': DateTime.now().toIso8601String(),
      };

      final ok = await prefs.setString('users', json.encode(users));
      debugPrint('users saved: $ok, total: ${users.length}');
      return ok;
    } catch (e) {
      debugPrint('Ошибка _saveUser: $e');
      return false;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: const Color(0xFF2E9B8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ================== ЛОГИН ==================

  Future<void> _login() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Барлық өрістерді толтырыңыз');
      return;
    }

    if (!email.contains('@')) {
      _showError('Email форматы дұрыс емес');
      return;
    }

    final users = await _getAllUsers();
    debugPrint('Попытка входа для: $email');
    debugPrint('Найдено пользователей: ${users.length}');

    if (!users.containsKey(email)) {
      _showError('Пайдаланушы табылмады. Тіркелу қажет.');
      return;
    }

    final user = users[email] as Map<String, dynamic>;
    final hashed = _hashPassword(password);

    if (user['password'] != hashed) {
      _showError('Құпия сөз дұрыс емес');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUserEmail', email);
    await prefs.setString('userName', user['name'] as String);
    await prefs.setString('userEmail', email);

    if (!mounted) return;
    _showSuccess('Сәтті кірдіңіз!');
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  // ================== РЕГИСТРАЦИЯ ==================

  Future<void> _register() async {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;
    final confirm = _registerConfirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Барлық өрістерді толтырыңыз');
      return;
    }

    if (!email.contains('@')) {
      _showError('Email форматы дұрыс емес');
      return;
    }

    if (password.length < 6) {
      _showError('Құпия сөз кемінде 6 таңбадан тұруы керек');
      return;
    }

    if (password != confirm) {
      _showError('Құпия сөздер сәйкес келмейді');
      return;
    }

    final users = await _getAllUsers();
    if (users.containsKey(email)) {
      _showError('Бұл email тіркелген. Кіру бетіне өтіңіз.');
      _tabController.animateTo(0);
      return;
    }

    final ok = await _saveUser(name, email, password);
    if (!ok) {
      _showError('Қате пайда болды. Қайталап көріңіз.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUserEmail', email);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);

    if (!mounted) return;
    _showSuccess('Тіркелу сәтті өтті!');
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  // ================== UI ==================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Column(
              children: [
                SizedBox(height: isMobile ? 30 : 40),
                Container(
                  width: isMobile ? 70 : 80,
                  height: isMobile ? 70 : 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E9B8E), Color(0xFF3D8FCC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E9B8E).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.energy_savings_leaf,
                    color: Colors.white,
                    size: isMobile ? 40 : 45,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'TazaQala',
                  style: TextStyle(
                    fontSize: isMobile ? 26 : 30,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E9B8E),
                  ),
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  'Қалаңызды таза ұстаңыз',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 30),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E9B8E), Color(0xFF3D8FCC)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    labelStyle: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Кіру'),
                      Tab(text: 'Тіркелу'),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginForm(isMobile),
                      _buildRegisterForm(isMobile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isMobile) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 18 : 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            TextField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: isMobile ? 14 : 15),
              decoration: _inputDecoration(
                isMobile: isMobile,
                hint: 'example@mail.com',
                icon: Icons.email_outlined,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 18),
            Text(
              'Құпия сөз',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            TextField(
              controller: _loginPasswordController,
              obscureText: _obscureLoginPassword,
              style: TextStyle(fontSize: isMobile ? 14 : 15),
              decoration: _inputDecoration(
                isMobile: isMobile,
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscureLoginPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: isMobile ? 20 : 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureLoginPassword = !_obscureLoginPassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Құпия сөзді ұмыттыңыз ба?',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: const Color(0xFF3D8FCC),
                  ),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9B8E),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Кіру',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(bool isMobile) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 18 : 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Аты-жөні',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            TextField(
              controller: _registerNameController,
              style: TextStyle(fontSize: isMobile ? 14 : 15),
              decoration: _inputDecoration(
                isMobile: isMobile,
                hint: 'Айжан Смағұлова',
                icon: Icons.person_outline,
              ),
            ),
            SizedBox(height: isMobile ? 14 : 16),
            Text(
              'Email',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            TextField(
              controller: _registerEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: isMobile ? 14 : 15),
              decoration: _inputDecoration(
                isMobile: isMobile,
                hint: 'example@mail.com',
                icon: Icons.email_outlined,
              ),
            ),
            SizedBox(height: isMobile ? 14 : 16),
            Text(
              'Құпия сөз',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            TextField(
              controller: _registerPasswordController,
              obscureText: _obscureRegisterPassword,
              style: TextStyle(fontSize: isMobile ? 14 : 15),
              decoration: _inputDecoration(
                isMobile: isMobile,
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscureRegisterPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: isMobile ? 20 : 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureRegisterPassword = !_obscureRegisterPassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: isMobile ? 14 : 16),
            Text(
              'Құпия сөзді растау',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            TextField(
              controller: _registerConfirmPasswordController,
              obscureText: _obscureRegisterConfirmPassword,
              style: TextStyle(fontSize: isMobile ? 14 : 15),
              decoration: _inputDecoration(
                isMobile: isMobile,
                hint: '••••••••',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscureRegisterConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: isMobile ? 20 : 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureRegisterConfirmPassword =
                      !_obscureRegisterConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: isMobile ? 20 : 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D8FCC),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Тіркелу',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  InputDecoration _inputDecoration({
    required bool isMobile,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
      prefixIcon: Icon(icon, size: isMobile ? 20 : 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E9B8E), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 14,
        vertical: isMobile ? 14 : 16,
      ),
    );
  }

}
