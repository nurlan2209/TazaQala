import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/report.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/services/report_service.dart';
import 'package:tazaqala/utils/constans.dart';
import 'auth_screen.dart';
import 'create_report_screen.dart';
import 'help_screen.dart';
import 'news_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'admin_dashboard_screen.dart';
import 'director_admins_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoadingReports = false;
  bool _reportsLoaded = false;
  String? _error;
  List<ReportModel> _latestReports = [];
  final ReportService _reportService = ReportService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reportsLoaded) {
      _loadReports();
      _reportsLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    final isPrivileged = isAdmin;

    // Reset index if role changed and current tab is out of range
    final maxIndex = isAdmin ? 3 : 4;
    if (_currentIndex > maxIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      });
    }
    final safeIndex = _currentIndex.clamp(0, maxIndex);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _getPageByIndex(safeIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) {
            final auth = context.read<AuthProvider>();
            final isAdm = auth.isAdmin;
            final profileTabIndex = isAdm ? 3 : 4;

            if (index == profileTabIndex && !auth.isAuthenticated) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E9B8E),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: Colors.white,
          elevation: 0,
          items: isAdmin
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Басты бет',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group),
                    label: 'Қызметкерлер',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.description),
                    label: 'Шағымдар',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Профиль',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Басты бет',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.description),
                    label: 'Шағымдар',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.newspaper),
                    label: 'Жаңалықтар',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.help_outline),
                    label: 'Көмек',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Профиль',
                  ),
                ],
        ),
      ),
    );
  }

  Widget _getPageByIndex(int index) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final isPrivileged = isAdmin;

    if (isPrivileged) {
      switch (index) {
        case 0:
          return AdminDashboardScreen();
        case 1:
          return const StaffManagementScreen();
        case 2:
          return ReportsScreen();
        case 3:
          return const ProfileScreen();
        default:
          return AdminDashboardScreen();
      }
    }

    switch (index) {
      case 0:
        return _buildMainPage();
      case 1:
        return ReportsScreen();
      case 2:
        return NewsScreen();
      case 3:
        return HelpScreen();
      case 4:
        return const ProfileScreen();
    }
    return _buildMainPage();
  }

  Widget _buildMainPage() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isMobile ? 100 : 120,
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
                    isMobile ? 16 : 20,
                    isMobile ? 50 : 60,
                    isMobile ? 16 : 20,
                    isMobile ? 12 : 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: isMobile ? 32 : 36,
                        height: isMobile ? 32 : 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.energy_savings_leaf,
                          color: const Color(0xFF2E9B8E),
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 10),
                      Text(
                        'TazaQala',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreateReportCard(isMobile),
                  SizedBox(height: isMobile ? 20 : 24),
                  Row(
                    children: [
                      Icon(Icons.receipt_long,
                          color: Colors.grey[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Соңғы шағымдар',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => _currentIndex = 1),
                        child: Row(
                          children: [
                            Text(
                              'Барлығы',
                              style: TextStyle(
                                color: const Color(0xFF3D8FCC),
                                fontSize: isMobile ? 12 : 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: const Color(0xFF3D8FCC),
                              size: isMobile ? 14 : 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 12 : 14),
                  if (_isLoadingReports)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    _buildErrorState()
                  else if (_latestReports.isEmpty)
                    _buildEmptyState()
                  else
                    ..._latestReports
                        .take(4)
                        .map((report) => _buildReportCard(report, isMobile)),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateReportCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E9B8E), Color(0xFF3D8FCC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E9B8E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_circle_outline,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'Шағым қосу',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Text(
            'Мәселені суретке түсіріп, сипаттама беріңіз. Біз оны тиісті ауданға жібереміз.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isMobile ? 12 : 13,
              height: 1.4,
            ),
          ),
          SizedBox(height: isMobile ? 14 : 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateReportScreen(),
                  ),
                );
                if (result == true) {
                  _loadReports();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E9B8E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 13 : 15,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Жаңа шағым жасау',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 14),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              report.imageUrl,
              width: isMobile ? 70 : 80,
              height: isMobile ? 70 : 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isMobile ? 70 : 80,
                  height: isMobile ? 70 : 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: isMobile ? 70 : 80,
                  height: isMobile ? 70 : 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: isMobile ? 12 : 14),
          Expanded(
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
                          fontSize: isMobile ? 13 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 10,
                        vertical: isMobile ? 4 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(report.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusLabel(report.status),
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 5 : 6),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: isMobile ? 13 : 14, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text(
                      report.district,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd.MM.yyyy').format(report.createdAt),
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 7),
                Text(
                  report.description,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 10),
            const Text('Соңғы шағымдар табылмады'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(_error ?? 'Қате пайда болды'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadReports,
            child: const Text('Қайталау'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadReports() async {
    final auth = context.read<AuthProvider>();
    final district = auth.user?.district;

    setState(() {
      _isLoadingReports = true;
      _error = null;
    });

    try {
      final data = await _reportService.fetchReports(district: district);
      if (mounted) {
        setState(() {
          _latestReports = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Шағымдарды жүктеу кезінде қате';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReports = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return const Color(0xFF2E9B8E);
      case 'in_progress':
      case 'reviewing':
        return const Color(0xFFFFC107);
      default:
        return Colors.grey;
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
}
