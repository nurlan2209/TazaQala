import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/report.dart';
import 'package:tazaqala/models/user.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/services/report_service.dart';
import 'package:tazaqala/services/user_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  final UserService _userService = UserService();

  final List<String> _filters = ['Барлығы', 'Шешілді', 'Күтуде'];
  String _selectedFilter = 'Барлығы';
  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;
  List<ReportModel> _reports = [];
  List<UserModel> _staff = [];

  List<ReportModel> get filteredReports {
    return _reports.where((report) {
      if (_selectedFilter == 'Шешілді' && report.status != 'done') {
        return false;
      }
      if (_selectedFilter == 'Күтуде' && report.status == 'done') {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAdmin) {
      await _loadStaff();
    }
    await _loadReports();
  }

  Future<void> _loadStaff() async {
    try {
      final users = await _userService.fetchAdmins();
      if (!mounted) return;
      setState(() => _staff = users);
    } catch (_) {
      // ignore staff errors
    }
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _reportService.fetchReports();
      if (!mounted) return;
      setState(() => _reports = data);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Деректерді жүктеу кезінде қате пайда болды';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadInitial,
                child: const Text('Қайталау'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadInitial,
        child: CustomScrollView(
          slivers: [
            _buildHeader(isMobile),
            if (filteredReports.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState(isMobile))
            else
              SliverPadding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReportCard(
                      filteredReports[index],
                      isMobile,
                    ),
                    childCount: filteredReports.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildHeader(bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 130 : 150,
      collapsedHeight: isMobile ? 90 : 100,
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 14 : 18,
                isMobile ? 20 : 24,
                isMobile ? 14 : 18,
                isMobile ? 10 : 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isMobile ? 36 : 40,
                        height: isMobile ? 36 : 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      const Text(
                        'Шағымдар',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filters
                        .map((f) => _buildFilterChip(f, isMobile))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isMobile) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 18,
          vertical: isMobile ? 9 : 11,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2E9B8E) : Colors.white,
            fontSize: isMobile ? 12 : 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Column(
        children: [
          Icon(Icons.inbox, size: isMobile ? 48 : 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text('Шағымдар табылмады', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return const Color(0xFF2E9B8E);
      case 'in_progress':
      case 'reviewing':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFFFFC107);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'done':
        return 'Шешілді';
      case 'in_progress':
        return 'Жұмыс үстінде';
      case 'reviewing':
        return 'Қаралуда';
      default:
        return 'Күтуде';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Widget _buildReportCard(ReportModel report, bool isMobile) {
    final auth = context.read<AuthProvider>();
    final assignedName = _staff.firstWhere(
      (u) => u.id == report.assignedTo,
      orElse: () => UserModel(id: '', name: '', email: '', role: ''),
    );
    final isAssignedToMyStaff =
        report.assignedTo != null && assignedName.id.isNotEmpty;
    final isTakenByOtherAdmin =
        report.assignedTo != null && report.assignedTo!.isNotEmpty && !isAssignedToMyStaff;
    final isStaffSelf =
        auth.isStaff && report.assignedTo != null && report.assignedTo == auth.user?.id;
    final canManage = (auth.isAdmin && !isTakenByOtherAdmin) || isStaffSelf;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                report.imageUrl,
                width: double.infinity,
                height: isMobile ? 180 : 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: isMobile ? 180 : 220,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.category,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(report.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(report.status),
                        style: TextStyle(
                          color: _statusColor(report.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      report.district,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(report.createdAt.toLocal()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: TextStyle(fontSize: isMobile ? 13 : 14, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (report.assignedTo != null && report.assignedTo!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          assignedName.name.isNotEmpty
                              ? assignedName.name
                              : isTakenByOtherAdmin
                                  ? 'Басқа админнің қызметкері'
                                  : (auth.isStaff
                                      ? 'Сізге тағайындалған'
                                      : 'Тағайындалған'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: isMobile ? 6 : 8,
                  runSpacing: isMobile ? 6 : 8,
                  children: [
                    _buildActionButton(
                      icon: Icons.article_outlined,
                      label: 'Толығырақ',
                      color: Colors.grey[700]!,
                      isMobile: isMobile,
                      onPressed: () => _showDetailDialog(report),
                    ),
                    if (canManage)
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Жаңарту',
                        color: const Color(0xFF2E9B8E),
                        isMobile: isMobile,
                        onPressed: () => _showUpdateSheet(report),
                      ),
                  ],
                ),
                if (isTakenByOtherAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Бұл шағым басқа админге тағайындалған',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isMobile,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: Icon(icon, size: isMobile ? 16 : 18),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 12 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDetailDialog(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (report.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.network(
                        report.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.category,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(report.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusLabel(report.status),
                                style: TextStyle(
                                  color: _statusColor(report.status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${report.lat}, ${report.lng}',
                                style: TextStyle(color: Colors.grey[700])),
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(report.createdAt.toLocal()),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          report.description,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        _buildReportMap(report),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportMap(ReportModel report) {
    final target = LatLng(report.lat, report.lng);
    final marker = Marker(
      markerId: MarkerId(report.id),
      position: target,
      infoWindow: InfoWindow(title: report.category),
    );

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: target, zoom: 14),
          markers: {marker},
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          compassEnabled: false,
          liteModeEnabled: false,
        ),
      ),
    );
  }

  void _showUpdateSheet(ReportModel report) {
    final statusOptions = [
      {'value': 'new', 'label': 'Күтуде'},
      {'value': 'reviewing', 'label': 'Қаралуда'},
      {'value': 'in_progress', 'label': 'Жұмыс үстінде'},
      {'value': 'done', 'label': 'Шешілді'},
    ];

    final auth = context.read<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final isStaff = auth.isStaff;

    String? selectedStatus = report.status;
    String? selectedStaff = report.assignedTo;
    final categoryController = TextEditingController(text: report.category);
    final descriptionController =
        TextEditingController(text: report.description);
    final latController =
        TextEditingController(text: report.lat.toStringAsFixed(6));
    final lngController =
        TextEditingController(text: report.lng.toStringAsFixed(6));
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleSave() async {
              setModalState(() => isSaving = true);
              try {
                double? lat;
                double? lng;
                if (isAdmin) {
                  lat = double.tryParse(latController.text.trim());
                  lng = double.tryParse(lngController.text.trim());
                  if (lat == null || lng == null) {
                    throw Exception('Координаталар дұрыс емес');
                  }
                }

                await _reportService.updateReport(
                  id: report.id,
                  category: isAdmin ? categoryController.text.trim() : null,
                  description:
                      isAdmin ? descriptionController.text.trim() : null,
                  status: selectedStatus,
                  lat: lat,
                  lng: lng,
                  assignedTo: isAdmin ? selectedStaff : null,
                );

                if (mounted) {
                  Navigator.pop(context);
                  _loadReports();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Шағым жаңартылды')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Қате: $e')));
                }
              } finally {
                if (mounted) setModalState(() => isSaving = false);
              }
            }

            final bottom = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Шағымды өңдеу',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryController,
                      readOnly: !isAdmin,
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      readOnly: !isAdmin,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Сипаттама',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      items: statusOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Мәртебе',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setModalState(() {
                        selectedStatus = value;
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (isAdmin && _staff.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedStaff,
                        decoration: const InputDecoration(
                          labelText: 'Қызметкер тағайындау',
                          border: OutlineInputBorder(),
                        ),
                        items: _staff
                            .map(
                              (u) => DropdownMenuItem<String>(
                                value: u.id,
                                child: Text(u.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setModalState(() {
                          selectedStaff = value;
                        }),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isAdmin) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latController,
                              decoration: const InputDecoration(
                                labelText: 'Ені (lat)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: true,
                                decimal: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: lngController,
                              decoration: const InputDecoration(
                                labelText: 'Бойлығы (lng)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: true,
                                decimal: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : handleSave,
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
                            : const Text('Сақтау'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}
