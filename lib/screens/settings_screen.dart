import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Контроллеры для изменения пароля
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Контроллеры для аккаунта
  final TextEditingController _nameController = TextEditingController(text: 'Айжан Смагулова');
  final TextEditingController _emailController = TextEditingController(text: 'aizhan@example.com');

  // Контроллеры для системных параметров
  final TextEditingController _maxFileSizeController = TextEditingController(text: '10');
  final TextEditingController _maxComplaintAgeController = TextEditingController(text: '5');

  // Настройки уведомлений
  bool notifyNewComplaints = true;
  bool notifyNewUsers = true;
  bool notifyEmail = false;

  // Категории жалоб
  List<Map<String, dynamic>> categories = [
    {'name': 'Қоқыс', 'isActive': true},
    {'name': 'Жарық', 'isActive': true},
    {'name': 'Жолдар', 'isActive': true},
    {'name': 'Саябақтар', 'isActive': true},
    {'name': 'Басқа', 'isActive': true},
  ];

  // Системные настройки
  bool enableTechnicalMode = false;

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifyNewComplaints = prefs.getBool('notifyNewComplaints') ?? true;
      notifyNewUsers = prefs.getBool('notifyNewUsers') ?? true;
      notifyEmail = prefs.getBool('notifyEmail') ?? false;
      enableTechnicalMode = prefs.getBool('enableTechnicalMode') ?? false;
      _maxFileSizeController.text = prefs.getString('maxFileSize') ?? '10';
      _maxComplaintAgeController.text = prefs.getString('maxComplaintAge') ?? '5';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifyNewComplaints', notifyNewComplaints);
    await prefs.setBool('notifyNewUsers', notifyNewUsers);
    await prefs.setBool('notifyEmail', notifyEmail);
    await prefs.setBool('enableTechnicalMode', enableTechnicalMode);
    await prefs.setString('maxFileSize', _maxFileSizeController.text);
    await prefs.setString('maxComplaintAge', _maxComplaintAgeController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Параметрлер сақталды'),
          backgroundColor: const Color(0xFF2E9B8E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _maxFileSizeController.dispose();
    _maxComplaintAgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isMobile),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Аккаунт параметрлері
                  _buildSection(
                    icon: Icons.person,
                    title: 'Аккаунт параметрлері',
                    isMobile: isMobile,
                    children: [
                      _buildTextField(
                        label: 'Аты-жөні',
                        controller: _nameController,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      ElevatedButton(
                        onPressed: _updateAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 24,
                            vertical: isMobile ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Сақтау',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 16 : 20),

                  // Құпия сөзді өзгерту
                  _buildSection(
                    icon: Icons.lock,
                    title: 'Құпия сөзді өзгерту',
                    isMobile: isMobile,
                    children: [
                      _buildPasswordField(
                        label: 'Ағымдағы құпия сөз',
                        controller: _oldPasswordController,
                        obscureText: _obscureOldPassword,
                        onToggle: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildPasswordField(
                        label: 'Жаңа құпия сөз',
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildPasswordField(
                        label: 'Құпия сөзді растау',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D8FCC),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 24,
                            vertical: isMobile ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Құпия сөзді өзгерту',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 16 : 20),

                  // Хабарламалар параметрлері
                  _buildSection(
                    icon: Icons.notifications,
                    title: 'Хабарламалар параметрлері',
                    isMobile: isMobile,
                    children: [
                      _buildSwitchTile(
                        title: 'Жаңа шағымдар туралы хабарламалар',
                        value: notifyNewComplaints,
                        onChanged: (val) => setState(() => notifyNewComplaints = val),
                        isMobile: isMobile,
                      ),
                      _buildSwitchTile(
                        title: 'Жаңа пайдаланушылар туралы хабарламалар',
                        value: notifyNewUsers,
                        onChanged: (val) => setState(() => notifyNewUsers = val),
                        isMobile: isMobile,
                      ),
                      _buildSwitchTile(
                        title: 'Email хабарламалар',
                        value: notifyEmail,
                        onChanged: (val) => setState(() => notifyEmail = val),
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 16 : 20),

                  // Шағым категориялары
                  _buildSection(
                    icon: Icons.category,
                    title: 'Шағым категориялары',
                    isMobile: isMobile,
                    children: [
                      ...categories.asMap().entries.map((entry) {
                        int index = entry.key;
                        var category = entry.value;
                        return _buildCategoryItem(
                          category['name'],
                          category['isActive'],
                          index,
                          isMobile,
                        );
                      }).toList(),
                      SizedBox(height: isMobile ? 10 : 12),
                      ElevatedButton.icon(
                        onPressed: _addCategory,
                        icon: Icon(Icons.add, size: isMobile ? 18 : 20),
                        label: Text(
                          'Жаңа категория қосу',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 20,
                            vertical: isMobile ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 16 : 20),

                  // Жүйе параметрлері
                  _buildSection(
                    icon: Icons.settings_applications,
                    title: 'Жүйе параметрлері',
                    isMobile: isMobile,
                    children: [
                      _buildTextField(
                        label: 'Максималды файл өлшемі (MB)',
                        controller: _maxFileSizeController,
                        keyboardType: TextInputType.number,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildTextField(
                        label: 'Шағым шешу мерзімі (күн)',
                        controller: _maxComplaintAgeController,
                        keyboardType: TextInputType.number,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildSwitchTile(
                        title: 'Техникалық қызмет көрсету режимі',
                        value: enableTechnicalMode,
                        onChanged: (val) => setState(() => enableTechnicalMode = val),
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D8FCC),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 24,
                            vertical: isMobile ? 10 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Сақтау',
                          style: TextStyle(fontSize: isMobile ? 13 : 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 20 : 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 100 : 120,
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
          background: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 16,
              isMobile ? 50 : 60,
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isMobile ? 36 : 40,
                        height: isMobile ? 36 : 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Flexible(
                        child: Text(
                          'Параметрлер',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required bool isMobile,
    required List<Widget> children,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(icon, size: isMobile ? 20 : 22, color: const Color(0xFF2E9B8E)),
              SizedBox(width: isMobile ? 8 : 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 14 : 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: isMobile ? 14 : 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2E9B8E), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(fontSize: isMobile ? 14 : 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2E9B8E), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                size: isMobile ? 20 : 22,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: Colors.grey[800],
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E9B8E),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, bool isActive, int index, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 10),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => _editCategory(index),
                child: Text(
                  'Өңдеу',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: const Color(0xFF3D8FCC),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _deleteCategory(index),
                child: Text(
                  'Жою',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateAccount() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Барлық өрістерді толтырыңыз'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Аккаунт мәліметтері жаңартылды'),
        backgroundColor: const Color(0xFF2E9B8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _changePassword() {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Барлық өрістерді толтырыңыз'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Жаңа құпия сөздер сәйкес келмейді'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Құпия сөз кемінде 6 таңбадан тұруы керек'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Құпия сөз сәтті өзгертілді'),
        backgroundColor: const Color(0xFF2E9B8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addCategory() {
    final TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Жаңа категория қосу'),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(
            hintText: 'Категория атауы',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  categories.add({
                    'name': categoryController.text,
                    'isActive': true,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Категория қосылды'),
                    backgroundColor: const Color(0xFF2E9B8E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E9B8E),
            ),
            child: const Text('Қосу'),
          ),
        ],
      ),
    );
  }

  void _editCategory(int index) {
    final TextEditingController categoryController = TextEditingController(
      text: categories[index]['name'],
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Категорияны өңдеу'),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(
            hintText: 'Категория атауы',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  categories[index]['name'] = categoryController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Категория өңделді'),
                    backgroundColor: const Color(0xFF2E9B8E),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D8FCC),
            ),
            child: const Text('Сақтау'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Жою'),
          ],
        ),
        content: Text('${categories[index]['name']} категориясын жойғыңыз келетініне сенімдісіз бе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                categories.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Категория жойылды'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Иә, жою'),
          ),
        ],
      ),
    );
  }
}
