import 'package:flutter/material.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  final List<Map<String, dynamic>> recommendations = [
    {
      'id': 1,
      'type': 'urgent',
      'category': 'Қоқыс',
      'tag': '#Жоғары',
      'tagColor': Colors.red,
      'title': 'Қоқыс шағымдары артты',
      'description':
      'Соңғы 7 күнде Алматы қалалығының санаты бойынша шағымдар 45% өсті. Қосымша тазалау қызметін ұйымдастыру ұсынылады.',
      'actionText': 'Қосымша тазалау бригадасын жіберу',
      'icon': Icons.warning_amber,
      'iconColor': Colors.orange,
      'bgColor': const Color(0xFFFFF3E0),
    },
    {
      'id': 2,
      'type': 'warning',
      'category': 'Жолдар',
      'tag': '#Орташа',
      'tagColor': Colors.orange,
      'title': 'Жол жөндеуді жоспарлау',
      'description':
      'Астана қалалғында жол санаты бойынша 8 белсенді шағым бар. Келесі аптада жөндеу жұмыстарын жоспарлау қажет.',
      'actionText': 'Жөндеу жоспарын',
      'icon': Icons.lightbulb_outline,
      'iconColor': Colors.blue,
      'bgColor': const Color(0xFFE3F2FD),
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
          _buildAppBar(isMobile),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Статистика карточки
                  GridView.count(
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
                        value: '2',
                        isMobile: isMobile,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildStatCard(
                        icon: Icons.warning_amber,
                        iconColor: Colors.orange,
                        title: 'Орташа басымдық',
                        value: '2',
                        isMobile: isMobile,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildStatCard(
                        icon: Icons.bar_chart,
                        iconColor: Colors.blue,
                        title: 'Барлық ұсыныстар',
                        value: '5',
                        isMobile: isMobile,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildStatCard(
                        icon: Icons.auto_awesome,
                        iconColor: Colors.purple,
                        title: 'AI дәлдігі',
                        value: '87%',
                        isMobile: isMobile,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFAB47BC), Color(0xFF9C27B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 20 : 24),

                  // Жалпы талдау
                  Container(
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
                              child: const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Жалпы талдау',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildAnalysisRow(
                          Icons.arrow_upward,
                          '23%',
                          'Шағымдар өсімі (соңғы ай)',
                          isMobile,
                        ),
                        const SizedBox(height: 10),
                        _buildAnalysisRow(
                          Icons.schedule,
                          '3.5 күн',
                          'Орташа жауап уақыты',
                          isMobile,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 24),

                  // AI Рекомендации
                  ...recommendations.map((rec) => _buildRecommendationCard(rec, isMobile)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 120 : 140,
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
          background: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 16,
              isMobile ? 50 : 60,
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
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
                              Icons.psychology,
                              color: Colors.white,
                              size: isMobile ? 20 : 24,
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'AI ұсыныстар',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'AI-based recommendations for city management',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isMobile ? 10 : 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
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
                            Icon(Icons.person, size: isMobile ? 16 : 18, color: Colors.grey),
                            SizedBox(width: isMobile ? 4 : 6),
                            Text(
                              'Switch to User',
                              style: TextStyle(fontSize: isMobile ? 11 : 13, color: Colors.grey),
                            ),
                          ],
                        ),
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

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isMobile,
    required Gradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(IconData icon, String value, String label, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: isMobile ? 16 : 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с иконкой
          Container(
            padding: EdgeInsets.all(isMobile ? 14 : 16),
            decoration: BoxDecoration(
              color: rec['bgColor'],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: rec['iconColor'].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    rec['icon'],
                    color: rec['iconColor'],
                    size: isMobile ? 20 : 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec['title'],
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 10,
                              vertical: isMobile ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: rec['tagColor'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              rec['tag'],
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rec['category'],
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Описание
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['description'],
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isMobile ? 14 : 16),
                // Кнопки действий
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _implementRecommendation(rec),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        child: Text(
                          rec['actionText'],
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDetails(rec),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3D8FCC),
                          side: const BorderSide(color: Color(0xFF3D8FCC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        child: Text(
                          'Толығырақ',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w600,
                          ),
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

  void _implementRecommendation(Map<String, dynamic> rec) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(rec['icon'], color: rec['iconColor']),
            const SizedBox(width: 8),
            const Expanded(child: Text('Ұсынысты орындау')),
          ],
        ),
        content: Text(
          '${rec['title']} ұсынысын орындағыңыз келетініне сенімдісіз бе?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${rec['title']} ұсынысы орындалуда...'),
                  backgroundColor: const Color(0xFF2E9B8E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E9B8E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Иә, орындау'),
          ),
        ],
      ),
    );
  }

  void _showDetails(Map<String, dynamic> rec) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rec['bgColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(rec['icon'], color: rec['iconColor'], size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rec['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.category, 'Санат', rec['category']),
                _buildDetailRow(Icons.label, 'Басымдық', rec['tag']),
                const SizedBox(height: 12),
                const Text(
                  'Сипаттама:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rec['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E9B8E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
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
