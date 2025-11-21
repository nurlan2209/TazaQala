import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<Map<String, dynamic>> news = [
    {
      'id': 1,
      'title': 'Жол жөндеу жұмыстары аяқталды',
      'location': 'Астана',
      'date': '11.11.2025',
      'description':
      'Астана қалалық әкімдігі негізгі көшелерде жөндеу жұмыстарын аяқтады. Жаңадан жөнделген жолдар көзір пайдалануға дайын.',
      'image': 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
    },
    {
      'id': 2,
      'title': 'Жаңа саябақ ашылды',
      'location': 'Шымкент',
      'date': '10.11.2025',
      'description':
      'Шымкент қалалық әкімдігі тұрғындар үшін жаңа саябақ ашты. Саябақта балалар ойын алаңы, спорт алаңы және демалу орындары бар.',
      'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    },
    {
      'id': 3,
      'title': 'Жаңа экологиялық бағдарлама басталды',
      'location': 'Алматы',
      'date': '12.11.2025',
      'description':
      'Алматы қалалық әкімдігі жаңа экологиялық бағдарламаны бастады. Бұл бағдарлама қаланың экологиясын жақсартуға және...',
      'image': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // AppBar с градиентом
          SliverAppBar(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: isMobile ? 36 : 40,
                              height: isMobile ? 36 : 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.newspaper,
                                color: Colors.white,
                                size: isMobile ? 20 : 24,
                              ),
                            ),
                            SizedBox(width: isMobile ? 8 : 12),
                            Flexible(
                              child: Text(
                                'Жаңалықтар',
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
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showAddNewsDialog(isMobile),
                            icon: Icon(Icons.add, size: isMobile ? 16 : 18),
                            label: Text(
                              '+ қосу',
                              style: TextStyle(fontSize: isMobile ? 12 : 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E9B8E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 16,
                                vertical: isMobile ? 6 : 8,
                              ),
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 16,
                              vertical: isMobile ? 6 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings,
                                  size: isMobile ? 16 : 18,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: isMobile ? 4 : 6),
                                Text(
                                  'Switch to Admin',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Список новостей
          SliverPadding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildNewsCard(news[index], isMobile);
                },
                childCount: news.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> newsItem, bool isMobile) {
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
          // Изображение
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              newsItem['image'],
              width: double.infinity,
              height: isMobile ? 180 : 220,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: isMobile ? 180 : 220,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: isMobile ? 180 : 220,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.broken_image,
                    size: isMobile ? 40 : 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsItem['title'],
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
                    Icon(
                      Icons.location_on,
                      size: isMobile ? 13 : 14,
                      color: Colors.red[400],
                    ),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      newsItem['location'],
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      '• ${newsItem['date']}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 10),
                Text(
                  newsItem['description'],
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                // Кнопки действий
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDetailDialog(newsItem, isMobile),
                        icon: Icon(
                          Icons.article_outlined,
                          size: isMobile ? 16 : 18,
                        ),
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
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 10),
                    IconButton(
                      onPressed: () => _showEditDialog(newsItem, isMobile),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: isMobile ? 20 : 22,
                        color: Colors.grey[700],
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(newsItem['id']),
                      icon: Icon(
                        Icons.delete_outline,
                        size: isMobile ? 20 : 22,
                        color: Colors.red,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

  void _showDetailDialog(Map<String, dynamic> newsItem, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  newsItem['image'],
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
                      newsItem['title'],
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
                        Text(
                          newsItem['location'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          newsItem['date'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      newsItem['description'],
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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

  void _showEditDialog(Map<String, dynamic> newsItem, bool isMobile) {
    final titleController = TextEditingController(text: newsItem['title']);
    final locationController = TextEditingController(text: newsItem['location']);
    final descriptionController =
    TextEditingController(text: newsItem['description']);
    final imageController = TextEditingController(text: newsItem['image']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: Color(0xFF2E9B8E)),
                    const SizedBox(width: 8),
                    Text(
                      'Жаңалықты өзгерту',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Тақырып',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Орналасқан жері',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Сипаттама',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'Сурет сілтемесі (URL)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Болдырмау'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            newsItem['title'] = titleController.text;
                            newsItem['location'] = locationController.text;
                            newsItem['description'] = descriptionController.text;
                            newsItem['image'] = imageController.text;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Жаңалық өзгертілді!'),
                              backgroundColor: Color(0xFF2E9B8E),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Сақтау'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddNewsDialog(bool isMobile) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_circle, color: Color(0xFF2E9B8E)),
                    const SizedBox(width: 8),
                    Text(
                      'Жаңа жаңалық қосу',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Тақырып',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Орналасқан жері',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Сипаттама',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'Сурет сілтемесі (URL)',
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Болдырмау'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Тақырыпты толтырыңыз!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            news.insert(0, {
                              'id': news.length + 1,
                              'title': titleController.text,
                              'location': locationController.text,
                              'date': _getCurrentDate(),
                              'description': descriptionController.text,
                              'image': imageController.text.isEmpty
                                  ? 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800'
                                  : imageController.text,
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Жаңалық қосылды!'),
                              backgroundColor: Color(0xFF2E9B8E),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Қосу'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int newsId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Жою'),
          ],
        ),
        content: const Text('Жаңалықты жойғыңыз келетініне сенімдісіз бе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                news.removeWhere((n) => n['id'] == newsId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Жаңалық жойылды'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Иә, жою'),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
  }
}
