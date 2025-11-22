import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'notifications_screen.dart';
import 'ai_recommendations_screen.dart';
import 'settings_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  String selectedCity = 'Барлығы Қала';
  String selectedFilter = 'Барлығы';
  String selectedUserFilter = 'Барлығы';
  bool showMap = false;

  final List<String> cities = [
    'Барлығы Қала',
    'Алматы',
    'Астана',
    'Шымкент',
  ];

  final List<String> filters = ['Барлығы', 'Шешілді', 'Күтуде'];
  final List<String> userFilters = ['Барлығы', 'Белсенді', 'Белсенді емес'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> recentReports = [
    {
      'author': 'Айжан Смагулова',
      'location': 'Алматы',
      'date': '10.11.2025, 15:30:00',
      'status': 'Күтуде',
      'statusColor': const Color(0xFFFFC107),
      'title': 'жаңа шағым қосты',
      'icon': Icons.access_time,
      'iconColor': const Color(0xFFFFC107),
    },
    {
      'author': 'Ерлан Нұрғалиев',
      'location': 'Астана',
      'date': '09.11.2025, 19:20:00',
      'status': 'Шешілді',
      'statusColor': const Color(0xFF2E9B8E),
      'title': 'жаңа шағым қосты',
      'icon': Icons.check_circle,
      'iconColor': const Color(0xFF2E9B8E),
    },
    {
      'author': 'Мадина Қалиева',
      'location': 'Шымкент',
      'date': '11.11.2025, 13:15:00',
      'status': 'Күтуде',
      'statusColor': const Color(0xFFFFC107),
      'title': 'жаңа шағым қосты',
      'icon': Icons.access_time,
      'iconColor': const Color(0xFFFFC107),
    },
    {
      'author': 'Айжан Смагулова',
      'location': 'Алматы',
      'date': '08.11.2025, 21:45:00',
      'status': 'Шешілді',
      'statusColor': const Color(0xFF2E9B8E),
      'title': 'жаңа шағым қосты',
      'icon': Icons.check_circle,
      'iconColor': const Color(0xFF2E9B8E),
    },
  ];

  List<Map<String, dynamic>> reports = [
    {
      'id': 1,
      'author': 'Айжан Смагулова',
      'location': 'Алматы',
      'date': '10.11.2025, 15:30:00',
      'status': 'Күтуде',
      'statusColor': const Color(0xFFFFC107),
      'title': 'Кешеде қоқыс жиналып қалды, тазалау қажет',
      'tag': '#Қоқыс',
      'coordinates': '43.2220, 76.8512',
      'image': 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=800',
      'lat': 43.2220,
      'lng': 76.8512,
    },
    {
      'id': 4,
      'author': 'Айжан Смагулова',
      'location': 'Алматы',
      'date': '08.11.2025, 21:45:00',
      'status': 'Шешілді',
      'statusColor': const Color(0xFF2E9B8E),
      'title': 'Саябақта балалар ойын алаңын жөндеу керек',
      'tag': '#Саябақтар',
      'coordinates': '43.2380, 76.8890',
      'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      'lat': 43.2380,
      'lng': 76.8890,
    },
  ];

  List<Map<String, dynamic>> news = [
    {
      'id': 1,
      'title': 'Жаңа экологиялық бағдарлама басталды',
      'location': 'Алматы',
      'date': '12.11.2025',
      'description':
      'Алматы қалалық әкімдігі жаңа экологиялық бағдарламаны бастады. Бұл бағдарлама қаланың экологиясын жақсартуға және...',
      'image': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
    },
    {
      'id': 2,
      'title': 'Жол жөндеу жұмыстары аяқталды',
      'location': 'Астана',
      'date': '11.11.2025',
      'description':
      'Астана қалалық әкімдігі негізгі көшелерді жөндеу жұмыстарын аяқтады. Жаңадан жөнделген жолдар көзір пайдалануға дайын.',
      'image': 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
    },
  ];

  List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'name': 'Айжан Смагулова',
      'email': 'aizhan@example.com',
      'location': 'Алматы',
      'reportsCount': 12,
      'registeredDate': '15.01.2025',
      'status': 'Белсенді',
      'statusColor': const Color(0xFF2E9B8E),
      'avatar': 'https://ui-avatars.com/api/?name=Aizhan+Smagulova&background=2E9B8E&color=fff&size=128',
    },
    {
      'id': 2,
      'name': 'Ерлан Нұрғалиев',
      'email': 'erlan@example.com',
      'location': 'Астана',
      'reportsCount': 8,
      'registeredDate': '10.02.2025',
      'status': 'Белсенді',
      'statusColor': const Color(0xFF2E9B8E),
      'avatar': 'https://ui-avatars.com/api/?name=Erlan+Nurgaliyev&background=3D8FCC&color=fff&size=128',
    },
    {
      'id': 3,
      'name': 'Мадина Қалиева',
      'email': 'madina@example.com',
      'location': 'Шымкент',
      'reportsCount': 5,
      'registeredDate': '20.03.2025',
      'status': 'Белсенді емес',
      'statusColor': Colors.grey,
      'avatar': 'https://ui-avatars.com/api/?name=Madina+Kalieva&background=E91E63&color=fff&size=128',
    },
  ];

  List<Map<String, dynamic>> get filteredReports {
    return reports.where((report) {
      bool matchesFilter = selectedFilter == 'Барлығы' ||
          report['status'] == selectedFilter;
      bool matchesCity = selectedCity == 'Барлығы Қала' ||
          report['location'] == selectedCity;
      return matchesFilter && matchesCity;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredNews {
    if (selectedCity == 'Барлығы Қала') {
      return news;
    }
    return news.where((item) => item['location'] == selectedCity).toList();
  }

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((user) {
      bool matchesFilter = selectedUserFilter == 'Барлығы' ||
          user['status'] == selectedUserFilter;
      bool matchesCity = selectedCity == 'Барлығы Қала' ||
          user['location'] == selectedCity;
      return matchesFilter && matchesCity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildDashboardPage(isMobile),
          _buildReportsPage(isMobile),
          _buildNewsPage(isMobile),
          _buildUsersPage(isMobile),
          const NotificationsScreen(),
          const AIRecommendationsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2E9B8E),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 9,
        unselectedFontSize: 9,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 22),
            label: 'Басқару',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description, size: 22),
            label: 'Шағымдар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper, size: 22),
            label: 'Жаңалықтар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 22),
            label: 'Пайдаланушылар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 22),
            label: 'Хабарламалар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology, size: 22),
            label: 'AI ұсыныстар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 22),
            label: 'Параметрлер',
          ),
        ],
      ),
    );
  }


  Widget _getSelectedPage(bool isMobile) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage(isMobile);
      case 1:
        return _buildReportsPage(isMobile);
      case 2:
        return _buildNewsPage(isMobile);
      case 3:
        return _buildUsersPage(isMobile);
      case 4:
        return const NotificationsScreen();
      case 5:
        return const AIRecommendationsScreen();
      default:
        return _buildDashboardPage(isMobile);
    }
  }

  // ==================== СТРАНИЦА БАСҚАРУ ПАНЕЛІ ====================
  Widget _buildDashboardPage(bool isMobile) {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Басқару панелі', Icons.dashboard, isMobile),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 2 : 4,
                  mainAxisSpacing: isMobile ? 12 : 16,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 1.3 : 1.5,
                  children: [
                    _buildStatCard(
                      icon: Icons.description,
                      iconColor: const Color(0xFF3D8FCC),
                      title: 'Барлық шағымдар',
                      value: '4',
                      isMobile: isMobile,
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle,
                      iconColor: const Color(0xFF2E9B8E),
                      title: 'Шешілді',
                      value: '2',
                      isMobile: isMobile,
                    ),
                    _buildStatCard(
                      icon: Icons.access_time,
                      iconColor: const Color(0xFFFFC107),
                      title: 'Күтуде',
                      value: '2',
                      isMobile: isMobile,
                      showWarning: true,
                    ),
                    _buildStatCard(
                      icon: Icons.people,
                      iconColor: const Color(0xFF9C27B0),
                      title: 'Белсенді пайдаланушылар',
                      value: '1,234',
                      isMobile: isMobile,
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 20 : 24),
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                      Text(
                        'Шағымдар санаты бойынша',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: 30,
                                title: 'Жарық',
                                color: const Color(0xFF3D8FCC),
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: 35,
                                title: 'Қоқыс',
                                color: const Color(0xFF2E9B8E),
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: 20,
                                title: 'Басқа',
                                color: const Color(0xFFE91E63),
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: 15,
                                title: 'Жолдар',
                                color: const Color(0xFFFFC107),
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                      Text(
                        'Қалалар бойынша шағымдар',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 8,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    'complaints : ${rod.toY.toInt()}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const cities = ['Алматы', 'Астана', 'Қарағанды'];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        cities[value.toInt()],
                                        style: TextStyle(fontSize: isMobile ? 11 : 12),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(fontSize: isMobile ? 11 : 12),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 2,
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: 5,
                                    color: const Color(0xFF2E9B8E),
                                    width: isMobile ? 30 : 40,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: 3,
                                    color: const Color(0xFF2E9B8E),
                                    width: isMobile ? 30 : 40,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                    toY: 2,
                                    color: const Color(0xFF2E9B8E),
                                    width: isMobile ? 30 : 40,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                          const Icon(Icons.history, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Соңғы әрекеттер',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 14 : 16),
                      ...recentReports.map((report) => _buildReportItem(report, isMobile)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== СТРАНИЦА ШАҒЫМДАР ====================
  Widget _buildReportsPage(bool isMobile) {
    return CustomScrollView(
      slivers: [
        _buildAppBarWithFilters('Шағымдар', Icons.receipt_long, isMobile),
        SliverPadding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildFullReportCard(filteredReports[index], isMobile);
              },
              childCount: filteredReports.length,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== СТРАНИЦА ЖАҢАЛЫҚТАР ====================
  Widget _buildNewsPage(bool isMobile) {
    return CustomScrollView(
      slivers: [
        _buildAppBarForNews('Жаңалықтар', Icons.newspaper, isMobile),
        SliverPadding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildNewsCard(filteredNews[index], isMobile);
              },
              childCount: filteredNews.length,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== СТРАНИЦА ПАЙДАЛАНУШЫЛАР ====================
  Widget _buildUsersPage(bool isMobile) {
    int totalUsers = users.length;
    int activeUsers = users.where((u) => u['status'] == 'Белсенді').length;
    int inactiveUsers = users.where((u) => u['status'] == 'Белсенді емес').length;
    int totalReports = users.fold(0, (sum, user) => sum + (user['reportsCount'] as int));

    return CustomScrollView(
      slivers: [
        _buildAppBarForUsers('Пайдаланушылар', Icons.people, isMobile),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 2 : 4,
                  mainAxisSpacing: isMobile ? 12 : 16,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 1.3 : 1.5,
                  children: [
                    _buildStatCard(
                      icon: Icons.people,
                      iconColor: const Color(0xFF3D8FCC),
                      title: 'Барлық пайдаланушылар',
                      value: totalUsers.toString(),
                      isMobile: isMobile,
                    ),
                    _buildStatCard(
                      icon: Icons.verified, // <- замена
                      iconColor: const Color(0xFF2E9B8E),
                      title: 'Белсенді',
                      value: activeUsers.toString(),
                      isMobile: isMobile,
                    ),
                    _buildStatCard(
                      icon: Icons.person_off,
                      iconColor: Colors.grey,
                      title: 'Белсенді емес',
                      value: inactiveUsers.toString(),
                      isMobile: isMobile,
                    ),
                    _buildStatCard(
                      icon: Icons.description,
                      iconColor: const Color(0xFFFFC107),
                      title: 'Барлық шағымдар',
                      value: totalReports.toString(),
                      isMobile: isMobile,
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 16 : 20),
                ...filteredUsers.map((user) => _buildUserCard(user, isMobile)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== APPBARS ====================
  Widget _buildAppBar(String title, IconData icon, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 100 : 120,
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
                        child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Flexible(
                        child: Text(
                          title,
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
                const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarWithFilters(String title, IconData icon, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 200 : 220,
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
                            child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Flexible(
                            child: Text(
                              title,
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
                    const SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: isMobile ? 14 : 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(filter, isMobile),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 12),
                Row(
                  children: [
                    Flexible(
                      child: PopupMenuButton<String>(
                        initialValue: selectedCity,
                        onSelected: (value) {
                          setState(() {
                            selectedCity = value;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 12,
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedCity,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 11 : 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: isMobile ? 4 : 6),
                              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: isMobile ? 16 : 18),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return cities.map((city) {
                            return PopupMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList();
                        },
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

  Widget _buildAppBarForNews(String title, IconData icon, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 150 : 170,
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
                            child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Flexible(
                            child: Text(
                              title,
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
                    const SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: isMobile ? 14 : 20),
                Row(
                  children: [
                    Flexible(
                      child: PopupMenuButton<String>(
                        initialValue: selectedCity,
                        onSelected: (value) {
                          setState(() {
                            selectedCity = value;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 12,
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedCity,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 11 : 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: isMobile ? 4 : 6),
                              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: isMobile ? 16 : 18),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return cities.map((city) {
                            return PopupMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add, size: isMobile ? 16 : 18),
                      label: Text(
                        'Жаңалық қосу',
                        style: TextStyle(fontSize: isMobile ? 12 : 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E9B8E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 8 : 10,
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

  Widget _buildAppBarForUsers(String title, IconData icon, bool isMobile) {
    return SliverAppBar(
      expandedHeight: isMobile ? 180 : 200,
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
                            child: Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Flexible(
                            child: Text(
                              title,
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
                    const SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: isMobile ? 14 : 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                  height: isMobile ? 40 : 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white70, size: isMobile ? 18 : 20),
                      SizedBox(width: isMobile ? 8 : 12),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14),
                          decoration: InputDecoration(
                            hintText: 'Іздеу',
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 13 : 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      PopupMenuButton<String>(
                        initialValue: selectedCity,
                        onSelected: (value) {
                          setState(() {
                            selectedCity = value;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 12,
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedCity,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 11 : 13,
                                ),
                              ),
                              SizedBox(width: isMobile ? 4 : 6),
                              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: isMobile ? 16 : 18),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return cities.map((city) {
                            return PopupMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList();
                        },
                      ),
                      const SizedBox(width: 8),
                      ...userFilters.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildUserFilterChip(filter, isMobile),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ====================
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isMobile,
    bool showWarning = false,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: isMobile ? 20 : 24),
              ),
              if (showWarning)
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107), size: 20)
              else
                const Icon(Icons.trending_up, color: Color(0xFF2E9B8E), size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                title,
                style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: report['iconColor'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(report['icon'], color: report['iconColor'], size: isMobile ? 20 : 24),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['author'],
                  style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: isMobile ? 3 : 4),
                Text(
                  report['title'],
                  style: TextStyle(fontSize: isMobile ? 12 : 13, color: Colors.grey[700]),
                ),
                SizedBox(height: isMobile ? 3 : 4),
                Text(
                  '${report['location']} • ${report['date']}',
                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: report['statusColor'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              report['status'],
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
            fontSize: isMobile ? 11 : 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUserFilterChip(String label, bool isMobile) {
    final isSelected = selectedUserFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
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
            fontSize: isMobile ? 11 : 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFullReportCard(Map<String, dynamic> report, bool isMobile) {
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
          if (report['image'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                report['image'],
                width: double.infinity,
                height: isMobile ? 180 : 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: isMobile ? 180 : 220,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
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
                        'ID: ${report['id']} - ${report['author']}',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
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
                        color: report['statusColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report['status'],
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
                    Icon(Icons.location_on, size: isMobile ? 13 : 14, color: Colors.grey[600]),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      '${report['location']} • ${report['date']}',
                      style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 10 : 12),
                Text(
                  report['title'],
                  style: TextStyle(fontSize: isMobile ? 13 : 14, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 8 : 10),
                Row(
                  children: [
                    Text(
                      report['tag'],
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.location_on, size: isMobile ? 14 : 16, color: Colors.blue[700]),
                    SizedBox(width: isMobile ? 4 : 6),
                    Text(
                      report['coordinates'],
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.check_circle, size: isMobile ? 16 : 18),
                        label: Text('Шешілді', style: TextStyle(fontSize: isMobile ? 12 : 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, size: isMobile ? 16 : 18),
                            SizedBox(width: isMobile ? 4 : 6),
                            Text('Жою', style: TextStyle(fontSize: isMobile ? 12 : 13)),
                          ],
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
                  height: isMobile ? 180 : 220,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
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
                  style: TextStyle(fontSize: isMobile ? 15 : 17, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: isMobile ? 13 : 14, color: Colors.red[400]),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      newsItem['location'],
                      style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      '• ${newsItem['date']}',
                      style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.edit_outlined, size: isMobile ? 16 : 18),
                        label: Text('Өңдеу', style: TextStyle(fontSize: isMobile ? 12 : 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3D8FCC),
                          side: const BorderSide(color: Color(0xFF3D8FCC)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.delete_outline, size: isMobile ? 16 : 18),
                        label: Text('Жою', style: TextStyle(fontSize: isMobile ? 12 : 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
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

  Widget _buildUserCard(Map<String, dynamic> user, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
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
              CircleAvatar(
                radius: isMobile ? 30 : 35,
                backgroundImage: NetworkImage(user['avatar']),
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            user['name'],
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: FontWeight.bold,
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
                            color: user['statusColor'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['status'],
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Row(
                      children: [
                        Icon(Icons.email, size: isMobile ? 12 : 13, color: Colors.grey[600]),
                        SizedBox(width: isMobile ? 4 : 6),
                        Flexible(
                          child: Text(
                            user['email'],
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: isMobile ? 12 : 13, color: Colors.grey[600]),
                        SizedBox(width: isMobile ? 4 : 6),
                        Text(
                          user['location'],
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
          SizedBox(height: isMobile ? 12 : 14),
          Row(
            children: [
              Icon(Icons.calendar_today, size: isMobile ? 12 : 13, color: Colors.grey[600]),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                '${user['reportsCount']} шағым',
                style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Text(
                'Тіркелген: ${user['registeredDate']}',
                style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showUserDetails(user, isMobile),
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
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _blockUser(user),
                  icon: Icon(Icons.block, size: isMobile ? 16 : 18),
                  label: Text(
                    'Блоктау',
                    style: TextStyle(fontSize: isMobile ? 12 : 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: isMobile ? 40 : 50,
                  backgroundImage: NetworkImage(user['avatar']),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 8 : 10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: user['statusColor'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),
                _buildDetailRow(Icons.email, 'Email', user['email'], isMobile),
                _buildDetailRow(Icons.location_on, 'Қала', user['location'], isMobile),
                _buildDetailRow(Icons.description, 'Шағымдар саны', '${user['reportsCount']}', isMobile),
                _buildDetailRow(Icons.calendar_today, 'Тіркелген күні', user['registeredDate'], isMobile),
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
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      child: Row(
        children: [
          Icon(icon, size: isMobile ? 18 : 20, color: Colors.grey[600]),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _blockUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Блоктау'),
          ],
        ),
        content: Text('${user['name']} пайдаланушыны блоктағыңыз келетініне сенімдісіз бе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user['status'] = 'Белсенді емес';
                user['statusColor'] = Colors.grey;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user['name']} блокталды'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Иә, блоктау'),
          ),
        ],
      ),
    );
  }
}
