import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tazaqala/models/news.dart';
import 'package:tazaqala/services/news_service.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({Key? key}) : super(key: key);

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<NewsItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadNews();
  }

  Future<List<NewsItem>> _loadNews() => _newsService.fetchNews();

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewsForm(),
        backgroundColor: const Color(0xFF2E9B8E),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final newsItems = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: newsItems.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildNewsAdminCard(newsItems[index]),
                            childCount: newsItems.length,
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
      expandedHeight: isMobile ? 150 : 170,
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
                      child: const Icon(Icons.newspaper, color: Colors.white),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    const Text(
                      'Админ жаңалықтары',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsAdminCard(NewsItem newsItem) {
    final isMobile = MediaQuery.of(context).size.width < 600;
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
              height: isMobile ? 170 : 210,
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text(
                      newsItem.district,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(newsItem.publishedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(newsItem.isPublished ? 'Жарияланған' : 'Жарияланбаған'),
                      backgroundColor:
                          newsItem.isPublished ? Colors.green[50] : Colors.orange[50],
                      labelStyle: TextStyle(
                        color: newsItem.isPublished ? Colors.green : Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showNewsForm(existing: newsItem),
                      icon: const Icon(Icons.edit_outlined),
                      color: const Color(0xFF3D8FCC),
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(newsItem),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
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

  Future<void> _showNewsForm({NewsItem? existing}) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final imageController = TextEditingController(text: existing?.imageUrl ?? '');
    bool isPublished = existing?.isPublished ?? true;
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
            final bottom = MediaQuery.of(context).viewInsets.bottom;
            Future<void> handleSubmit() async {
              if (!formKey.currentState!.validate()) return;
              setModalState(() => isSaving = true);
              try {
                if (existing == null) {
                  await _newsService.createNews(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    imageUrl: imageController.text.trim().isEmpty
                        ? null
                        : imageController.text.trim(),
                    isPublished: isPublished,
                  );
                } else {
                  await _newsService.updateNews(
                    id: existing.id,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    imageUrl: imageController.text.trim(),
                    isPublished: isPublished,
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  _refresh();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Қате: $e')),
                  );
                }
              } finally {
                if (mounted) setModalState(() => isSaving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing == null ? 'Жаңалық қосу' : 'Жаңалықты өңдеу',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Тақырып',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Тақырыпты енгізіңіз' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Сипаттама',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Сипаттаманы енгізіңіз'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'Сурет (URL)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Жариялау'),
                        value: isPublished,
                        onChanged: (value) => setModalState(() => isPublished = value),
                      ),
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

  void _confirmDelete(NewsItem newsItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Жою'),
        content: Text('“${newsItem.title}” жаңалығын жоясыз ба?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Болдырмау'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _newsService.deleteNews(newsItem.id);
                if (mounted) {
                  Navigator.pop(context);
                  _refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Жаңалық жойылды')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Қате: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Жою'),
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
    return Column(
      children: const [
        Icon(Icons.inbox, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text('Жаңалықтар табылмады'),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
