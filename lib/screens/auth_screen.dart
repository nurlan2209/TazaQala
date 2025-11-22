import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/user.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/utils/constans.dart';
import 'admin_dashboard_screen.dart';
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
  String? _selectedDistrict;

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

  Future<void> _showForgotPasswordDialog() async {
    final emailController =
        TextEditingController(text: _loginEmailController.text.trim());
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Құпия сөзді қалпына келтіру'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Болдырмау'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Дұрыс email енгізіңіз'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final provider = context.read<AuthProvider>();
                final success = await provider.requestPasswordReset(email);
                if (!mounted) return;
                Navigator.pop(dialogContext);
                if (success) {
                  _showSuccess('Поштаға қалпына келтіру сілтемесі жіберілді');
                } else {
                  _showError(provider.errorMessage ?? 'Қате пайда болды');
                }
              },
              child: const Text('Жіберу'),
            ),
          ],
        );
      },
    );
    emailController.dispose();
  }

  Future<void> _showResendVerificationDialog() async {
    final emailController =
        TextEditingController(text: _registerEmailController.text.trim());
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Растау сілтемесін қайта жіберу'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Болдырмау'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  _showError('Дұрыс email енгізіңіз');
                  return;
                }
                final provider = context.read<AuthProvider>();
                final success = await provider.resendVerification(email);
                if (!mounted) return;
                Navigator.pop(dialogContext);
                if (success) {
                  _showSuccess('Сілтеме email-ге жіберілді');
                } else {
                  _showError(provider.errorMessage ?? 'Қате пайда болды');
                }
              },
              child: const Text('Жіберу'),
            ),
          ],
        );
      },
    );
    emailController.dispose();
  }

  Future<void> _showVerifyEmailDialog() async {
    final tokenController = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Token арқылы растау'),
          content: TextField(
            controller: tokenController,
            decoration: const InputDecoration(
              labelText: 'Token',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Болдырмау'),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = tokenController.text.trim();
                if (token.isEmpty) {
                  _showError('Token енгізіңіз');
                  return;
                }
                final provider = context.read<AuthProvider>();
                final success = await provider.verifyEmailToken(token);
                if (!mounted) return;
                Navigator.pop(dialogContext);
                if (success) {
                  _showSuccess('Email сәтті расталды!');
                } else {
                  _showError(provider.errorMessage ?? 'Қате пайда болды');
                }
              },
              child: const Text('Растау'),
            ),
          ],
        );
      },
    );
    tokenController.dispose();
  }

  Future<void> _showResetPasswordDialog() async {
    final tokenController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Құпия сөзді жаңарту'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Token',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Жаңа құпия сөз',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Қайта енгізіңіз',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Болдырмау'),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = tokenController.text.trim();
                final password = passwordController.text;
                final confirm = confirmController.text;
                if (token.isEmpty || password.isEmpty || confirm.isEmpty) {
                  _showError('Барлық өрістерді толтырыңыз');
                  return;
                }
                if (password != confirm) {
                  _showError('Құпия сөздер сәйкес келмейді');
                  return;
                }
                final provider = context.read<AuthProvider>();
                final success = await provider.resetPassword(
                  token: token,
                  password: password,
                );
                if (!mounted) return;
                Navigator.pop(dialogContext);
                if (success) {
                  _showSuccess('Құпия сөз жаңартылды');
                } else {
                  _showError(provider.errorMessage ?? 'Қате пайда болды');
                }
              },
              child: const Text('Жаңарту'),
            ),
          ],
        );
      },
    );

    tokenController.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }

  void _navigateAfterAuth(UserModel user) {
    if (!mounted) return;
    if (user.role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
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

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email: email, password: password);

    if (!success) {
      _showError(authProvider.errorMessage ?? 'Қате пайда болды');
      return;
    }

    final user = authProvider.user;
    if (user == null) return;

    _showSuccess('Сәтті кірдіңіз!');
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateAfterAuth(user);
  }

  // ================== РЕГИСТРАЦИЯ ==================

  Future<void> _register() async {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;
    final confirm = _registerConfirmPasswordController.text;
    final district = _selectedDistrict;

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

    if (district == null) {
      _showError('Ауданды таңдаңыз');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: name,
      email: email,
      password: password,
      district: district,
    );

    if (!success) {
      _showError(authProvider.errorMessage ?? 'Қате пайда болды');
      return;
    }

    _showSuccess('Тіркелу сәтті өтті! Email растау сілтемесін тексеріңіз.');
    await Future.delayed(const Duration(milliseconds: 500));
    _tabController.animateTo(0);
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
                SizedBox(
                  height: isMobile ? 52 : 56,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
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
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

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
                onPressed: _showForgotPasswordDialog,
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
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 12,
              runSpacing: 4,
              children: [
                TextButton(
                  onPressed: () => _showResendVerificationDialog(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Растауды қайта жіберу',
                    style: TextStyle(color: Color(0xFF3D8FCC)),
                  ),
                ),
                TextButton(
                  onPressed: () => _showVerifyEmailDialog(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Token арқылы растау',
                    style: TextStyle(color: Color(0xFF3D8FCC)),
                  ),
                ),
                TextButton(
                  onPressed: () => _showResetPasswordDialog(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Құпия сөзді жаңарту',
                    style: TextStyle(color: Color(0xFF3D8FCC)),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9B8E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
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
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

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
              'Аудан',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              decoration: _inputDecoration(
                isMobile: isMobile,
                hint: 'Ауданды таңдаңыз',
                icon: Icons.place_outlined,
              ),
              items: astanaDistricts
                  .map(
                    (district) => DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                });
              },
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
                onPressed: isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D8FCC),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
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
