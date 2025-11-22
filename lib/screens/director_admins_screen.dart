import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tazaqala/models/district_stat.dart';
import 'package:tazaqala/models/user.dart';
import 'package:tazaqala/services/report_service.dart';
import 'package:tazaqala/services/user_service.dart';
import 'package:tazaqala/utils/constans.dart';

class DirectorAdminsScreen extends StatefulWidget {
  const DirectorAdminsScreen({super.key});

  @override
  State<DirectorAdminsScreen> createState() => _DirectorAdminsScreenState();
}

class _DirectorAdminsScreenState extends State<DirectorAdminsScreen> {
  final UserService _userService = UserService();
  final ReportService _reportService = ReportService();

  List<UserModel> _admins = [];
  List<DistrictStat> _districtStats = [];
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
      final results = await Future.wait([
        _userService.fetchAdmins(),
        _reportService.fetchDistrictStats(),
      ]);
      setState(() {
        _admins = results[0] as List<UserModel>;
        _districtStats = results[1] as List<DistrictStat>;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          title: const Text('Аудан админдері'),
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

    final groupedAdmins = <String, List<UserModel>>{};
    for (final district in astanaDistricts) {
      groupedAdmins[district] = [];
    }
    for (final admin in _admins) {
      final district = admin.district;
      if (district != null) {
        groupedAdmins.putIfAbsent(district, () => []);
        groupedAdmins[district]!.add(admin);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аудан админдері'),
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
          children: [
            _buildDistrictStats(),
            const SizedBox(height: 20),
            ...groupedAdmins.entries.map((entry) {
              final admins = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E9B8E),
                    ),
                  ),
                  children: admins.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Әзірге админ жоқ',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ]
                      : admins
                          .map(
                            (admin) => _AdminTile(
                              admin: admin,
                              onEdit: () =>
                                  _showAdminForm(context, existing: admin),
                            ),
                          )
                          .toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictStats() {
    if (_districtStats.isEmpty) {
      return Container(
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
        child: const Text('Шағым статистикасы қолжетімсіз.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Аудан бойынша статистика',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E9B8E),
          ),
        ),
        const SizedBox(height: 12),
        ..._districtStats.map((stat) => _buildDistrictCard(stat)),
      ],
    );
  }

  Widget _buildDistrictCard(DistrictStat stat) {
    final total = stat.total;
    final done = stat.statusCounts['done'] ?? 0;
    final inProgress = stat.statusCounts['in_progress'] ?? 0;
    final reviewing = stat.statusCounts['reviewing'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.district,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$total шағым',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E9B8E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _statusChip('Шешілді', done, Colors.green),
              _statusChip('Жұмыс үстінде', inProgress, Colors.orange),
              _statusChip('Қаралуда', reviewing, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, int value, Color color) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  Future<void> _showAdminForm(BuildContext context, {UserModel? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final passwordController = TextEditingController();
    String? selectedDistrict = existing?.district ?? astanaDistricts.first;
    bool isActive = existing?.isActive ?? true;
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleSubmit() async {
              if (!formKey.currentState!.validate()) return;
              setModalState(() => isSaving = true);
              try {
                if (existing == null) {
                  await _userService.createAdmin(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    district: selectedDistrict!,
                  );
                } else {
                  await _userService.updateAdmin(
                    id: existing.id,
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text.isEmpty
                        ? null
                        : passwordController.text,
                    district: selectedDistrict,
                    isActive: isActive,
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Қате: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setModalState(() => isSaving = false);
                }
              }
            }

            final bottom = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing == null ? 'Жаңа админ қосу' : 'Админді өңдеу',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Аты-жөні',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Атын енгізіңіз'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || !value.contains('@')
                                ? 'Дұрыс email енгізіңіз'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: existing == null
                              ? 'Құпия сөз'
                              : 'Құпия сөз (қаласаңыз)',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (existing == null &&
                              (value == null || value.length < 6)) {
                            return 'Кемінде 6 таңба';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedDistrict,
                        decoration: const InputDecoration(
                          labelText: 'Аудан',
                          border: OutlineInputBorder(),
                        ),
                        items: astanaDistricts
                            .map(
                              (district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedDistrict = value;
                          });
                        },
                      ),
                      if (existing != null) ...[
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Белсенді'),
                          value: isActive,
                          onChanged: (value) {
                            setModalState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E9B8E),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(existing == null ? 'Қосу' : 'Сақтау'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
    final statusColor = admin.isActive == false ? Colors.red : Colors.green;
    final createdAt =
        DateFormat('dd.MM.yyyy').format(DateTime.now()); // demo placeholder

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2E9B8E),
        child: Text(
          admin.name.isNotEmpty ? admin.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(admin.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(admin.email, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            admin.isActive == false ? 'Белсенді емес' : 'Белсенді',
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
          Text(
            'Жаңартылды: $createdAt',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Color(0xFF3D8FCC)),
        onPressed: onEdit,
      ),
    );
  }
}
