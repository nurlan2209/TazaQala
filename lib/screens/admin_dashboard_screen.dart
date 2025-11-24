import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/report.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/services/report_service.dart';
import 'admin_reports_screen.dart';
import 'director_admins_screen.dart';
import 'ai_recommendations_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ReportService _reportService = ReportService();
  late Future<List<ReportModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<List<ReportModel>> _loadData() async {
    final auth = context.read<AuthProvider>();
    // Districts no longer used; fetch according to server-side role filtering.
    return _reportService.fetchReports();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDirector = auth.isDirector;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isDirector ? 'Директор дэшборды' : 'Әкімдік дэшборды'),
        backgroundColor: const Color(0xFF2E9B8E),
        actions: null,
      ),
      body: FutureBuilder<List<ReportModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final reports = snapshot.data ?? [];
          final stats = _buildStats(reports);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 12),
                _buildStatCards(stats, isMobile),
                const SizedBox(height: 16),
                _buildActions(isDirector, isMobile),
                if (!isDirector) ...[
                  const SizedBox(height: 16),
                  _buildRecentReports(reports, isMobile),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final auth = context.read<AuthProvider>();
    final isDirector = auth.isDirector;
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E9B8E), Color(0xFF3D8FCC)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.dashboard, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            isDirector ? 'Директор панелі' : 'Әкімдік панелі',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(Map<String, int> stats, bool isMobile) {
    final cards = [
      _StatCard(
        title: 'Барлығы',
        value: stats['total'] ?? 0,
        color: const Color(0xFF2E9B8E),
      ),
      _StatCard(
        title: 'Күтуде',
        value: stats['pending'] ?? 0,
        color: const Color(0xFFFFC107),
      ),
      _StatCard(
        title: 'Қаралуда',
        value: stats['in_progress'] ?? 0,
        color: const Color(0xFF3D8FCC),
      ),
      _StatCard(
        title: 'Шешілді',
        value: stats['done'] ?? 0,
        color: const Color(0xFF4CAF50),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildActions(bool isDirector, bool isMobile) {
    if (isDirector) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(
          label: 'Шағымдар',
          icon: Icons.receipt_long,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentReports(List<ReportModel> reports, bool isMobile) {
    final sorted = [...reports]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest = sorted.take(6).toList();

    if (latest.isEmpty) {
      return const _EmptyBlock(text: 'Шағымдар табылмады');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.history, color: Colors.black54),
            SizedBox(width: 8),
            Text(
              'Соңғы шағымдар',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...latest.map((r) => _ReportTile(report: r, isMobile: isMobile)),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _refresh,
            child: const Text('Қайталау'),
          ),
        ],
      ),
    );
  }

  Map<String, int> _buildStats(List<ReportModel> reports) {
    final result = {
      'total': reports.length,
      'pending': 0,
      'in_progress': 0,
      'done': 0,
    };
    for (final r in reports) {
      switch (r.status) {
        case 'done':
          result['done'] = (result['done'] ?? 0) + 1;
          break;
        case 'in_progress':
        case 'reviewing':
          result['in_progress'] = (result['in_progress'] ?? 0) + 1;
          break;
        default:
          result['pending'] = (result['pending'] ?? 0) + 1;
      }
    }
    return result;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF2E9B8E)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.isMobile});

  final ReportModel report;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.category,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(report.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(report.status),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.red[400]),
              const SizedBox(width: 4),
              Text(report.district, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 10),
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd.MM.yyyy').format(report.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'done':
        return 'Шешілді';
      case 'in_progress':
      case 'reviewing':
        return 'Қаралуда';
      default:
        return 'Күтуде';
    }
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}
