import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/user.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/utils/constans.dart';
import 'admin_dashboard_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
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
    final codeController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmController = TextEditingController();
    bool codeSent = false;
    bool isProcessing = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(codeSent
                  ? 'Жаңа құпия сөз'
                  : 'Құпия сөзді қалпына келтіру'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      readOnly: codeSent,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (codeSent) ...[
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: 'Код',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: newPassController,
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Жабу'),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          final auth = context.read<AuthProvider>();
                          setStateDialog(() => isProcessing = true);

                          if (!codeSent) {
                            if (email.isEmpty || !email.contains('@')) {
                              setStateDialog(() => isProcessing = false);
                              _showError('Дұрыс email енгізіңіз');
                              return;
                            }
                            final ok = await auth.requestPasswordReset(email);
                            setStateDialog(() => isProcessing = false);
                            if (ok) {
                              _showSuccess('Код поштаға жіберілді');
                              setStateDialog(() => codeSent = true);
                            } else {
                              _showError(
                                  auth.errorMessage ?? 'Қате пайда болды');
                            }
                            return;
                          }

                          final code = codeController.text.trim();
                          final pass = newPassController.text;
                          final confirm = confirmController.text;
                          if (code.isEmpty ||
                              pass.isEmpty ||
                              confirm.isEmpty) {
                            setStateDialog(() => isProcessing = false);
                            _showError('Барлық өрістерді толтырыңыз');
                            return;
                          }
                          if (pass != confirm) {
                            setStateDialog(() => isProcessing = false);
                            _showError('Құпия сөздер сәйкес келмейді');
                            return;
                          }

                          final ok = await auth.resetPassword(
                            token: code,
                            password: pass,
                          );
                          setStateDialog(() => isProcessing = false);
                          if (ok) {
                            _showSuccess('Құпия сөз жаңартылды');
                            if (mounted) Navigator.pop(dialogContext);
                          } else {
                            _showError(auth.errorMessage ?? 'Қате пайда болды');
                          }
                        },
                  child: isProcessing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(codeSent ? 'Жаңарту' : 'Код жіберу'),
                ),
              ],
            );
          },
        );
      },
    );

  }

  void _navigateAfterAuth(UserModel user) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

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
    await Future.delayed(const Duration(milliseconds: 300));
    _navigateAfterAuth(user);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isLoading = context.watch<AuthProvider>().isLoading;

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
                _buildLoginCard(isMobile, isLoading),
                SizedBox(height: isMobile ? 16 : 20),
                Text(
                  'Әлі тіркелмедіңіз бе?',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistrationScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E9B8E)),
                      foregroundColor: const Color(0xFF2E9B8E),
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Тіркелу',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(bool isMobile, bool isLoading) {
    return Container(
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

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirm = _confirmController.text;
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showError('Барлық өрістерді толтырыңыз');
      return;
    }
    if (!email.contains('@')) {
      _showError('Email форматы дұрыс емес');
      return;
    }
    if (pass.length < 6) {
      _showError('Құпия сөз кемінде 6 таңба');
      return;
    }
    if (pass != confirm) {
      _showError('Құпия сөздер сәйкес келмейді');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: name,
      email: email,
      password: pass,
      district: null,
    );
    if (!ok) {
      _showError(auth.errorMessage ?? 'Қате пайда болды');
      return;
    }
    _showSuccess('Тіркелу сәтті!');
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Тіркелу'),
        backgroundColor: const Color(0xFF2E9B8E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
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
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  isMobile: isMobile,
                  hint: 'Айжан Смағұлова',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  isMobile: isMobile,
                  hint: 'example@mail.com',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Құпия сөз',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePass,
                decoration: _inputDecoration(
                  isMobile: isMobile,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_off : Icons.visibility,
                      size: isMobile ? 20 : 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Құпия сөзді растау',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: _inputDecoration(
                  isMobile: isMobile,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: isMobile ? 20 : 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
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
                    padding:
                        EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
