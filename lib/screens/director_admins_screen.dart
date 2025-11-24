import 'package:flutter/material.dart';
import 'package:tazaqala/models/user.dart';
import 'package:tazaqala/services/user_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final UserService _userService = UserService();

  List<UserModel> _staff = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _userService.fetchAdmins();
      setState(() => _staff = users);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Қызметкерлер'),
          backgroundColor: const Color(0xFF2E9B8E),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Қайталау'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Қызметкерлер'),
        backgroundColor: const Color(0xFF2E9B8E),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdminForm(context),
        backgroundColor: const Color(0xFF2E9B8E),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: _staff.isEmpty
              ? [
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: const Text('Қызметкерлер тізімі бос.'),
                  ),
                ]
              : _staff
                  .map(
                    (admin) => _AdminTile(
                      admin: admin,
                      onEdit: () => _showAdminForm(context, existing: admin),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Future<void> _showAdminForm(BuildContext context,
      {UserModel? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final passController = TextEditingController();
    bool isActive = existing?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existing == null ? 'Жаңа қызметкер' : 'Өңдеу'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Аты-жөні'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passController,
                      decoration: const InputDecoration(labelText: 'Құпия сөз'),
                    ),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                      title: const Text('Белсенді'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Жабу'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final name = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passController.text.trim();

                          if (name.isEmpty || email.isEmpty) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Барлық өрістерді толтырыңыз')),
                            );
                            return;
                          }

                          try {
                            if (existing == null) {
                              await _userService.createAdmin(
                                name: name,
                                email: email,
                                password:
                                    password.isEmpty ? '123456' : password,
                              );
                            } else {
                              await _userService.updateAdmin(
                                id: existing.id,
                                name: name,
                                email: email,
                                password: password,
                                isActive: isActive,
                              );
                            }
                            if (mounted) Navigator.pop(ctx);
                            _loadData();
                          } catch (e) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(existing == null ? 'Қосу' : 'Сақтау'),
                )
              ],
            );
          },
        );
      },
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.admin, required this.onEdit});

  final UserModel admin;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(admin.name),
        subtitle: Text(admin.email),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              admin.isActive == true ? 'Белсенді' : 'Белсенді емес',
              style: TextStyle(
                color: admin.isActive == true ? Colors.green : Colors.red,
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: const Text('Өңдеу'),
            ),
          ],
        ),
      ),
    );
  }
}
