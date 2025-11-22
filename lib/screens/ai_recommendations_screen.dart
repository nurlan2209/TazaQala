import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tazaqala/models/ai_insight.dart';
import 'package:tazaqala/services/ai_service.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  final AiService _aiService = AiService();
  late Future<AiInsights> _future;

  @override
  void initState() {
    super.initState();
    _future = _aiService.fetchInsights();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _future = _aiService.fetchInsights();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<AiInsights>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final insights = snapshot.data;
          if (insights == null) {
            return _buildError('Деректер табылмады');
          }

          final stats = insights.stats;
          final summary = insights.summary;
          final recommendations = insights.recommendations;
          final isMobile = MediaQuery.of(context).size.width < 600;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(isMobile),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (summary != null && summary.isNotEmpty)
                          _buildSummaryCard(summary, isMobile),
                        if (summary != null && summary.isNotEmpty)
                          SizedBox(height: isMobile ? 16 : 20),
                        _buildStatsGrid(stats, isMobile),
                        SizedBox(height: isMobile ? 20 : 24),
                        _buildAnalysisCard(stats, isMobile),
                        SizedBox(height: isMobile ? 20 : 24),
                        ...recommendations.map(
                          (rec) => _buildRecommendationCard(rec, isMobile),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 120 : 140,
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
            child: Row(
              children: [
                Container(
                  width: isMobile ? 36 : 40,
                  height: isMobile ? 36 : 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                const Text(
                  'AI ұсыныстар',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AiStats stats, bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      mainAxisSpacing: isMobile ? 12 : 16,
      crossAxisSpacing: isMobile ? 12 : 16,
      childAspectRatio: isMobile ? 1.2 : 1.4,
      children: [
        _buildStatCard(
          icon: Icons.error_outline,
          iconColor: Colors.red,
          title: 'Жоғары басымдық',
          value: stats.highPriority.toString(),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.warning_amber,
          iconColor: Colors.orange,
          title: 'Орташа басымдық',
          value: stats.mediumPriority.toString(),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.bar_chart,
          iconColor: Colors.blue,
          title: 'Барлық шағым',
          value: stats.totalReports.toString(),
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isMobile: isMobile,
        ),
        _buildStatCard(
          icon: Icons.auto_awesome,
          iconColor: Colors.purple,
          title: 'AI дәлдігі',
          value: '${stats.accuracy}%',
          gradient: const LinearGradient(
            colors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Gradient gradient,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: isMobile ? 22 : 26),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isMobile ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(AiStats stats, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Жалпы талдау',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisRow(
            Icons.arrow_upward,
            '${stats.monthlyGrowth}',
            'Шағымдар өсімі (соңғы ай)',
            isMobile,
          ),
          const SizedBox(height: 10),
          _buildAnalysisRow(
            Icons.people_outline,
            '${stats.resolved}/${stats.totalReports}',
            'Шешілген / жалпы шағымдар',
            isMobile,
          ),
          if (stats.topCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Көп шағым түсетін санаттар',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 13 : 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: stats.topCategories
                  .map(
                    (cat) => Chip(
                      label: Text('${cat.category} (${cat.count})'),
                      backgroundColor: Colors.white.withOpacity(0.15),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String summary, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E9B8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.insights, color: Color(0xFF2E9B8E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              summary,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                height: 1.4,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(AiRecommendation rec, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 14),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _mapColor(rec.level).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _mapIcon(rec.level),
                  color: _mapColor(rec.level),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                rec.category,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E9B8E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rec.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rec.description,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showRecommendationDetail(rec),
              child: Text(
                rec.action,
                style: const TextStyle(color: Color(0xFF3D8FCC)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(
      IconData icon, String value, String label, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isMobile ? 12 : 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showRecommendationDetail(AiRecommendation rec) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(rec.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rec.category,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E9B8E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              rec.description,
              style: TextStyle(color: Colors.grey[800], height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF3D8FCC)),
                const SizedBox(width: 6),
                Expanded(child: Text(rec.action)),
              ],
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

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          Text('Қате: $message'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _refresh,
            child: const Text('Қайталау'),
          ),
        ],
      ),
    );
  }

  IconData _mapIcon(String level) {
    switch (level) {
      case 'urgent':
        return Icons.warning_amber;
      case 'warning':
        return Icons.lightbulb_outline;
      default:
        return Icons.auto_fix_high;
    }
  }

  Color _mapColor(String level) {
    switch (level) {
      case 'urgent':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
