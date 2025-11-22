import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/report.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/services/report_service.dart';
import 'package:tazaqala/utils/constans.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ReportService _reportService = ReportService();

  List<ReportModel> _reports = [];
  bool _isLoading = true;
  bool _showMap = false;
  String _selectedFilter = 'Барлығы';
  String? _selectedDistrict;
  String? _errorMessage;

  final Map<String, String?> _statusFilters = {
    'Барлығы': null,
    'Күтуде': 'new',
    'Қаралуда': 'reviewing',
    'Жұмыс үстінде': 'in_progress',
    'Шешілді': 'done',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (!auth.isDirector) {
        _selectedDistrict = auth.user?.district;
      }
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      String? district;
      if (auth.isDirector) {
        if (_selectedDistrict != null && _selectedDistrict != 'Барлығы') {
          district = _selectedDistrict;
        }
      } else {
        district = auth.user?.district;
      }
      final data = await _reportService.fetchReports(district: district);
      setState(() {
        _reports = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ReportModel> get _filteredReports {
    final status = _statusFilters[_selectedFilter];
    return _reports.where((report) {
      final matchesStatus = status == null || report.status == status;
      return matchesStatus;
    }).toList();
  }

  Map<String, int> get _statusSummary {
    final summary = <String, int>{
      'new': 0,
      'reviewing': 0,
      'in_progress': 0,
      'done': 0,
    };
    for (final report in _reports) {
      final key = report.status ?? 'new';
      summary[key] = (summary[key] ?? 0) + 1;
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                onPressed: _loadReports,
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
        onRefresh: _loadReports,
        child: CustomScrollView(
          slivers: [
            _buildHeader(isMobile),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(isMobile),
                    SizedBox(height: isMobile ? 16 : 20),
                    if (_showMap)
                      _buildMapSection(isMobile)
                    else
                      _buildReportList(isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildHeader(bool isMobile) {
    final auth = context.watch<AuthProvider>();
    final canChooseDistrict = auth.isDirector;

    return SliverAppBar(
      expandedHeight: isMobile ? 180 : 200,
      floating: false,
      pinned: true,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: isMobile ? 36 : 40,
                      height: isMobile ? 36 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    const Text(
                      'Шағымдар',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showMap = !_showMap;
                        });
                      },
                      icon: Icon(
                        _showMap ? Icons.list_alt : Icons.map_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusFilters.keys.map((label) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(label, isMobile),
                      );
                    }).toList(),
                  ),
                ),
                if (canChooseDistrict) ...[
                  const SizedBox(height: 12),
                  PopupMenuButton<String>(
                    initialValue: _selectedDistrict ?? 'Барлығы',
                    onSelected: (value) {
                      setState(() {
                        _selectedDistrict = value == 'Барлығы' ? null : value;
                      });
                      _loadReports();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 12,
                        vertical: isMobile ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedDistrict ?? 'Барлығы',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 12 : 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Барлығы',
                        child: Text('Барлығы'),
                      ),
                      ...astanaDistricts.map(
                        (d) => PopupMenuItem(value: d, child: Text(d)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isMobile) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
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

  Widget _buildSummaryCards(bool isMobile) {
    final summary = _statusSummary;
    final cards = [
      _SummaryCardData(
        title: 'Барлық шағым',
        value: _reports.length.toString(),
        color: const Color(0xFF2E9B8E),
        icon: Icons.bar_chart,
      ),
      _SummaryCardData(
        title: 'Күтуде',
        value: (summary['new'] ?? 0).toString(),
        color: const Color(0xFFFFC107),
        icon: Icons.priority_high,
      ),
      _SummaryCardData(
        title: 'Қаралуда',
        value: (summary['reviewing'] ?? 0).toString(),
        color: const Color(0xFF3D8FCC),
        icon: Icons.loop,
      ),
      _SummaryCardData(
        title: 'Шешілді',
        value: (summary['done'] ?? 0).toString(),
        color: const Color(0xFF2E9B8E),
        icon: Icons.check_circle,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isMobile ? 1.4 : 1.6,
      children: cards
          .map(
            (card) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: card.color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(card.icon, color: card.color),
                  const Spacer(),
                  Text(
                    card.value,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: card.color,
                    ),
                  ),
                  Text(
                    card.title,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: card.color.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMapSection(bool isMobile) {
    if (_filteredReports.isEmpty) {
      return _buildEmptyState();
    }

    final initial = _filteredReports.first;
    final markers = _filteredReports.map((report) {
      return Marker(
        markerId: MarkerId(report.id),
        position: LatLng(report.lat, report.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _colorHue(_statusColor(report.status)),
        ),
        infoWindow: InfoWindow(
          title: report.category,
          snippet: report.description,
        ),
      );
    }).toSet();

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(initial.lat, initial.lng),
            zoom: 12,
          ),
          markers: markers,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  Widget _buildReportList(bool isMobile) {
    if (_filteredReports.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _filteredReports.map((report) {
        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
            title: Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        report.district ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.label, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(report.category),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm')
                        .format(report.createdAt.toLocal()),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            trailing: _buildActionButtons(report),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(ReportModel report) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.play_arrow,
          label: 'Жұмыс',
          color: Colors.orange,
          onTap: () => _updateStatus(report, 'in_progress'),
        ),
        const SizedBox(height: 6),
        _actionButton(
          icon: Icons.check,
          label: 'Шешілді',
          color: Colors.green,
          onTap: () => _updateStatus(report, 'done'),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(ReportModel report, String status) async {
    try {
      await _reportService.updateReport(id: report.id, status: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Статус "${report.category}" жаңартылды'),
          ),
        );
      }
      await _loadReports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Icon(Icons.inbox, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Бұл фильтрде шағым табылмады'),
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'done':
        return const Color(0xFF2E9B8E);
      case 'in_progress':
        return Colors.orange;
      case 'reviewing':
        return const Color(0xFF3D8FCC);
      default:
        return const Color(0xFFFFC107);
    }
  }

  double _colorHue(Color color) {
    return HSVColor.fromColor(color).hue;
  }
}

class _SummaryCardData {
  _SummaryCardData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;
}
