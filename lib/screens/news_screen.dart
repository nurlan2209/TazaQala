import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tazaqala/models/news.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'package:tazaqala/services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<NewsItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadNews();
  }

  Future<List<NewsItem>> _loadNews() {
    final authProvider = context.read<AuthProvider>();
    final district =
        authProvider.isDirector ? null : authProvider.user?.district;
    return _newsService.fetchNews(district: district);
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _future = _loadNews();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<NewsItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildNewsCard(items[index], MediaQuery.of(context).size.width < 600),
                      childCount: items.length,
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

  SliverAppBar _buildHeader() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SliverAppBar(
      expandedHeight: isMobile ? 140 : 160,
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
                    Icons.newspaper,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                const Text(
                  'Жаңалықтар',
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

  Widget _buildNewsCard(NewsItem newsItem, bool isMobile) {
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              newsItem.imageUrl ??
                  'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
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
                Text(
                  newsItem.title,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: isMobile ? 13 : 14, color: Colors.red[400]),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      newsItem.district,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      '• ${_formatDate(newsItem.publishedAt)}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 10),
                Text(
                  newsItem.description,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetailDialog(newsItem, isMobile),
                    icon: Icon(Icons.article_outlined, size: isMobile ? 16 : 18),
                    label: Text(
                      'Толығырақ',
                      style: TextStyle(fontSize: isMobile ? 12 : 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3D8FCC),
                      side: const BorderSide(color: Color(0xFF3D8FCC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  void _showDetailDialog(NewsItem newsItem, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  newsItem.imageUrl ??
                      'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsItem.title,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text(newsItem.district),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(_formatDate(newsItem.publishedAt)),
                      ],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      newsItem.description,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Жабу'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Жаңалықтар әлі жоқ'),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
