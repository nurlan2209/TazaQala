import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:tazaqala/providers/auth_provider.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'news_screen.dart';
import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = 'Алматы';
  bool isDropdownOpen = false;
  String selectedFilter = 'Барлығы';
  File? _selectedImage;
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  int _currentIndex = 0;

  final List<String> cities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Ақтөбе',
    'Қарағанды',
    'Тараз',
    'Павлодар',
    'Семей',
    'Ақтау',
    'Атырау',
  ];

  final List<String> filters = ['Барлығы', 'Шешілді', 'Күтуде'];

  final List<String> categories = [
    'Қоқыс',
    'Жолдар',
    'Жарық',
    'Су',
    'Ағаш',
    'Басқа',
  ];

  final List<Map<String, dynamic>> allReports = [
    {
      'author': 'Айжан Смағұлова',
      'location': 'Алматы',
      'status': 'Күтуде',
      'statusColor': const Color(0xFFFFC107),
      'title': 'Көшеде қоқыс жиналып қалды, тазалау қажет',
      'image': 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400',
    },
    {
      'author': 'Ерлан Нұрғалиев',
      'location': 'Астана',
      'status': 'Шешілді',
      'statusColor': const Color(0xFF2E9B8E),
      'title': 'Көше жарығы жұмыс істемейді',
      'image': 'https://images.unsplash.com/photo-1513828583688-c52646db42da?w=400',
    },
    {
      'author': 'Мадина Қалиева',
      'location': 'Шымкент',
      'status': 'Күтуде',
      'statusColor': const Color(0xFFFFC107),
      'title': 'Жолда үлкен шұңқыр пайда болды',
      'image': 'https://images.unsplash.com/photo-1625047509168-a7026f36de04?w=400',
    },
    {
      'author': 'Нұрлан Әбдіғали',
      'location': 'Алматы',
      'status': 'Шешілді',
      'statusColor': const Color(0xFF2E9B8E),
      'title': 'Паркта су құбыры жарылды',
      'image': 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400',
    },
    {
      'author': 'Гүлнар Досова',
      'location': 'Ақтөбе',
      'status': 'Күтуде',
      'statusColor': const Color(0xFFFFC107),
      'title': 'Аулада қоқыс контейнерлері жоқ',
      'image': 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400',
    },
  ];

  final List<Map<String, dynamic>> newsItems = [
    {
      'title': 'Жаңа экологиялық бағдарлама басталды',
      'description':
      'Алматы қалалық әкімдігі жаңа экологиялық бағдарламаны бастады. Бұл бағдарлама...',
      'image': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
    },
    {
      'title': 'Жол жөндеу жұмыстары аяқталды',
      'description':
      'Астана қалалық әкімдігі негізгі көшелерді жөндеу жұмыстарын аяқтады...',
      'image': 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
    },
  ];

  // Фильтрация по статусу и городу
  List<Map<String, dynamic>> get filteredReports {
    return allReports.where((report) {
      bool matchesFilter = selectedFilter == 'Барлығы' || report['status'] == selectedFilter;
      bool matchesCity = report['location'] == selectedCity;
      return matchesFilter && matchesCity;
    }).toList();
  }

  // Новости по городу
  List<Map<String, dynamic>> get filteredNews {
    return newsItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _getPageByIndex(_currentIndex),
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
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 3) {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              }
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E9B8E),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
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
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help_outline),
              label: 'Көмек',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPageByIndex(int index) {
    switch (index) {
      case 0:
        return _buildMainPage();
      case 1:
        return ReportsScreen();
      case 2:
        return NewsScreen();
      case 4:
        return HelpScreen();
      default:
        return _buildMainPage();
    }
  }

  Widget _buildMainPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Stack(
      children: [
        CustomScrollView(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 16,
                            ),
                            height: isMobile ? 45 : 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.grey[400],
                                  size: isMobile ? 20 : 22,
                                ),
                                SizedBox(width: isMobile ? 10 : 12),
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Іздеу',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: isMobile ? 14 : 15,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 10 : 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 16,
                              vertical: isMobile ? 12 : 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedCity,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: isMobile ? 6 : 8),
                                Icon(
                                  isDropdownOpen
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: isMobile ? 18 : 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    Row(
                      children: [
                        Icon(Icons.newspaper, color: Colors.grey[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Жаңалықтар',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentIndex = 2;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Барлық жаңалықтар',
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
                    ...filteredNews.take(2).map((news) => _buildNewsCard(news, isMobile)),
                    SizedBox(height: isMobile ? 20 : 24),

                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.grey[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Соңғы шағымдар - $selectedCity',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 12 : 14),
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
                    SizedBox(height: isMobile ? 14 : 16),

                    // Показываем отфильтрованные шағымдар
                    if (filteredReports.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Шағымдар табылмады',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filteredReports.map((report) => _buildReportCard(report, isMobile)),

                    SizedBox(height: isMobile ? 20 : 24),

                    Container(
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
                          SizedBox(height: isMobile ? 14 : 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Сипаттама',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: isMobile ? 13 : 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  label: Text(
                                    'Фото жүктеу',
                                    style: TextStyle(fontSize: isMobile ? 12 : 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: isMobile ? 10 : 12),
                              Expanded(
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isMobile ? 12 : 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _selectedCategory ?? 'Қаланы таңдау',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isMobile ? 12 : 13,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  itemBuilder: (context) {
                                    return categories.map((category) {
                                      return PopupMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 12 : 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitReport,
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
                                    'Жіберу',
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
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (isDropdownOpen)
          Positioned(
            top: isMobile ? 100 : 120,
            right: isMobile ? 16 : 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: isMobile ? 160 : 200,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = city == selectedCity;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedCity = city;
                          isDropdownOpen = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 14 : 16,
                          vertical: isMobile ? 11 : 13,
                        ),
                        color: isSelected
                            ? const Color(0xFF3D8FCC).withOpacity(0.1)
                            : Colors.transparent,
                        child: Text(
                          city,
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            color: isSelected
                                ? const Color(0xFF3D8FCC)
                                : Colors.grey[800],
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

        if (isDropdownOpen)
          GestureDetector(
            onTap: () {
              setState(() {
                isDropdownOpen = false;
              });
            },
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
              news['image'],
              width: double.infinity,
              height: isMobile ? 170 : 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: isMobile ? 170 : 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: isMobile ? 170 : 200,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.error)),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title'],
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  news['description'],
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 8 : 10),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: Text(
                    'Толығырақ',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: const Color(0xFF3D8FCC),
                      fontWeight: FontWeight.w500,
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
          vertical: isMobile ? 8 : 9,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E9B8E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E9B8E) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: isMobile ? 12 : 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, bool isMobile) {
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
              report['image'],
              width: isMobile ? 70 : 80,
              height: isMobile ? 70 : 80,
              fit: BoxFit.cover,
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isMobile ? 70 : 80,
                  height: isMobile ? 70 : 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
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
                        report['author'],
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
                        color: report['statusColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report['status'],
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
                      report['location'],
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 7),
                Text(
                  report['title'],
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Фото таңдалды'),
          backgroundColor: const Color(0xFF2E9B8E),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _submitReport() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сипаттама толтырыңыз!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Қаланы таңдаңыз!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Шағым сәтті жіберілді!'),
        backgroundColor: const Color(0xFF2E9B8E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    setState(() {
      _descriptionController.clear();
      _selectedImage = null;
      _selectedCategory = null;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
