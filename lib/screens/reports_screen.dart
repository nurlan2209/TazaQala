import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/report.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/services/report_service.dart';
import 'package:tazaqala/utils/constans.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  static const LatLng _astanaCenter = LatLng(51.1694, 71.4491);

  String selectedFilter = 'Барлығы';
  String? selectedDistrict;
  List<String> districtOptions = ['Барлығы'];
  bool showMap = false;
  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;
  List<ReportModel> _reports = [];
  Set<Polygon> _districtPolygons = {};

  final List<String> filters = ['Барлығы', 'Шешілді', 'Күтуде'];

  List<ReportModel> get filteredReports {
    return _reports.where((report) {
      if (selectedFilter == 'Шешілді' && report.status != 'done') {
        return false;
      }
      if (selectedFilter == 'Күтуде' && report.status == 'done') {
        return false;
      }
      if (selectedDistrict != null &&
          selectedDistrict!.isNotEmpty &&
          selectedDistrict != 'Барлығы') {
        return report.district == selectedDistrict;
      }
      return true;
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isDirector) {
        districtOptions = ['Барлығы', ...astanaDistricts];
        selectedDistrict = 'Барлығы';
      } else {
        final userDistrict =
            authProvider.user?.district ?? astanaDistricts.first;
        districtOptions = [userDistrict];
        selectedDistrict = userDistrict;
      }
      _districtPolygons = _buildPolygons();
      _initialized = true;
      _loadReports();
    }
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final queryDistrict = authProvider.isDirector
          ? (selectedDistrict == 'Барлығы' ? null : selectedDistrict)
          : authProvider.user?.district;

      final data = await _reportService.fetchReports(district: queryDistrict);
      if (!mounted) return;
      setState(() {
        _reports = data;
        _districtPolygons = _buildPolygons();
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Деректерді жүктеу кезінде қате пайда болды';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final authProvider = context.watch<AuthProvider>();
    final canChangeDistrict = authProvider.isDirector;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // AppBar с градиентом
          SliverAppBar(
            expandedHeight: isMobile ? 200 : 220,
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
                      // Заголовок и кнопка Admin
                      Row(
                        children: [
                          Container(
                            width: isMobile ? 36 : 40,
                            height: isMobile ? 36 : 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: isMobile ? 20 : 24,
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Flexible(
                            child: Text(
                              'Шағымдар',
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
                      SizedBox(height: isMobile ? 14 : 20),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          runAlignment: WrapAlignment.start,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...filters.map((filter) => _buildFilterChip(filter, isMobile)),
                            _buildDistrictSelector(isMobile, canChangeDistrict),
                            _buildMapToggle(isMobile),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            SliverToBoxAdapter(child: _buildLoadingState())
          else if (_errorMessage != null)
            SliverToBoxAdapter(child: _buildErrorState())
          else if (filteredReports.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState(isMobile))
          else if (showMap)
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                margin: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _getInitialCameraTarget(),
                      zoom: selectedDistrict == 'Барлығы' ? 11.5 : 13,
                    ),
                    markers: filteredReports.map((report) {
                      return Marker(
                        markerId: MarkerId(report.id),
                        position: LatLng(report.lat, report.lng),
                        infoWindow: InfoWindow(
                          title: report.category,
                          snippet: _statusLabel(report.status),
                        ),
                      );
                    }).toSet(),
                    polygons: _districtPolygons,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildReportCard(
                      filteredReports[index],
                      isMobile,
                    );
                  },
                  childCount: filteredReports.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isMobile) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 18,
          vertical: isMobile ? 9 : 11,
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

  Widget _buildDistrictSelector(bool isMobile, bool canChangeDistrict) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            selectedDistrict ?? 'Аудан таңдалмады',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 11 : 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 16,
        vertical: isMobile ? 9 : 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      constraints: BoxConstraints(
        minWidth: isMobile ? 180 : 210,
      ),
      child: content,
    );
  }

  Widget _buildMapToggle(bool isMobile) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showMap = !showMap;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: showMap ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              color: showMap ? const Color(0xFF2E9B8E) : Colors.white,
              size: isMobile ? 14 : 16,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              'Картада көру',
              style: TextStyle(
                color: showMap ? const Color(0xFF2E9B8E) : Colors.white,
                fontSize: isMobile ? 11 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E9B8E)),
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Қате пайда болды',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadReports,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E9B8E),
            ),
            child: const Text('Қайталау'),
          )
        ],
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
          const Text(
            'Бұл ауданда шағымдар табылмады',
            textAlign: TextAlign.center,
          ),
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

  Set<Polygon> _buildPolygons() {
    final polygons = <Polygon>{};
    final selection = selectedDistrict;
    if (selection == null || selection.isEmpty || selection == 'Барлығы') {
      astanaDistrictPolygons.forEach((district, rawPoints) {
        final polygon = _createPolygon(district, rawPoints);
        if (polygon != null) polygons.add(polygon);
      });
    } else {
      final polygon =
          _createPolygon(selection, astanaDistrictPolygons[selection]);
      if (polygon != null) polygons.add(polygon);
    }
    return polygons;
  }

  Polygon? _createPolygon(String district, List<List<double>>? rawPoints) {
    if (rawPoints == null || rawPoints.length < 3) return null;
    final points =
        rawPoints.map((entry) => LatLng(entry[0], entry[1])).toList();
    return Polygon(
      polygonId: PolygonId(district),
      points: points,
      strokeColor: const Color(0xFF2E9B8E),
      fillColor: const Color(0x332E9B8E),
      strokeWidth: 2,
    );
  }

  LatLng _getInitialCameraTarget() {
    if (filteredReports.isNotEmpty) {
      return LatLng(filteredReports.first.lat, filteredReports.first.lng);
    }

    if (_districtPolygons.isNotEmpty) {
      final polygon = _districtPolygons.first;
      if (polygon.points.isNotEmpty) {
        return _calculateCentroid(polygon.points);
      }
    }

    final fallbackDistrict = selectedDistrict == 'Барлығы'
        ? astanaDistricts.first
        : selectedDistrict;
    final rawPoints = astanaDistrictPolygons[fallbackDistrict];
    if (rawPoints != null && rawPoints.length >= 3) {
      final points =
          rawPoints.map((entry) => LatLng(entry[0], entry[1])).toList();
      return _calculateCentroid(points);
    }

    return _astanaCenter;
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    double lat = 0;
    double lng = 0;
    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  Widget _buildReportCard(ReportModel report, bool isMobile) {
    final authProvider = context.read<AuthProvider>();
    final canManage = authProvider.isAdmin || authProvider.isDirector;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
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
          if (report.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                report.imageUrl,
                width: double.infinity,
                height: isMobile ? 180 : 220,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        report.category,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 12,
                        vertical: isMobile ? 4 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(report.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(report.status),
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isMobile ? 13 : 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      report.district,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      '• ${_formatDate(report.createdAt)}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 10 : 12),
                Text(
                  report.description,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 8 : 10),
                SizedBox(height: isMobile ? 12 : 16),
                Wrap(
                  spacing: isMobile ? 6 : 8,
                  runSpacing: isMobile ? 6 : 8,
                  children: [
                    _buildActionButton(
                      icon: Icons.article_outlined,
                      label: 'Толығырақ',
                      color: Colors.grey[700]!,
                      isMobile: isMobile,
                      onPressed: () {
                        _showDetailDialog(report);
                      },
                    ),
                    if (canManage)
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Жаңарту',
                        color: const Color(0xFF2E9B8E),
                        isMobile: isMobile,
                        onPressed: () {
                          _showUpdateSheet(report);
                        },
                      ),
                  ],
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
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isMobile ? 16 : 18),
      label: Text(
        label,
        style: TextStyle(fontSize: isMobile ? 11 : 12),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 6 : 8,
        ),
      ),
    );
  }

  void _showDetailDialog(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(report.category),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(label: 'Аудан', value: report.district),
            const SizedBox(height: 8),
            _buildDetailItem(
              label: 'Мәртебе',
              value: _statusLabel(report.status),
              badgeColor: _statusColor(report.status),
            ),
            const SizedBox(height: 8),
            _buildDetailItem(
              label: 'Күні',
              value: _formatDate(report.createdAt),
            ),
            const SizedBox(height: 8),
            _buildDetailItem(
              label: 'Координаталар',
              value:
                  '${report.lat.toStringAsFixed(4)}, ${report.lng.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 12),
            Text(
              'Сипаттама',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жабу'),
          ),
        ],
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

    String? selectedStatus = report.status;
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
                final lat = double.tryParse(latController.text.trim());
                final lng = double.tryParse(lngController.text.trim());
                if (lat == null || lng == null) {
                  throw Exception('Координаталар дұрыс емес');
                }

                await _reportService.updateReport(
                  id: report.id,
                  category: categoryController.text.trim(),
                  description: descriptionController.text.trim(),
                  status: selectedStatus,
                  lat: lat,
                  lng: lng,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Шағымды өңдеу',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Сипаттама',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
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
                      onChanged: (value) {
                        setModalState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latController,
                            decoration: const InputDecoration(
                              labelText: 'Ені (lat)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
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
                            keyboardType: TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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

  Widget _buildDetailItem({
    required String label,
    required String value,
    Color? badgeColor,
  }) {
    if (badgeColor != null) {
      return Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
