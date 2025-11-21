import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String selectedFilter = 'Барлығы';
  String selectedCity = 'Барлығы Қала';
  bool showMap = false;

  final List<String> filters = ['Барлығы', 'Шешілді', 'Күтуде'];
  final List<String> cities = [
    'Барлығы Қала',
    'Алматы',
    'Астана',
    'Шымкент',
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
    {
      'id': 2,
      'author': 'Нұрлан Әбдіғалиев',
      'location': 'Астана',
      'date': '09.11.2025, 19:20:00',
      'status': 'Шешілді',
      'statusColor': const Color(0xFF2E9B8E),
      'title': 'Жолда үлкен шұңқыр пайда болды',
      'tag': '#Жолдар',
      'coordinates': '42.3417, 69.5901',
      'image': null,
      'lat': 51.1694,
      'lng': 71.4491,
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
                      // Заголовок и кнопка Switch to User
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
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
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
                                  Icon(
                                    Icons.person,
                                    size: isMobile ? 16 : 18,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: isMobile ? 4 : 6),
                                  Text(
                                    'Switch to User',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 14 : 20),
                      // Фильтры
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
                      // Город и карта
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
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
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
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: isMobile ? 16 : 18,
                                    ),
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                showMap = !showMap;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 12,
                                vertical: isMobile ? 8 : 10,
                              ),
                              decoration: BoxDecoration(
                                color: showMap
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
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
                                    color: showMap
                                        ? const Color(0xFF2E9B8E)
                                        : Colors.white,
                                    size: isMobile ? 14 : 16,
                                  ),
                                  SizedBox(width: isMobile ? 4 : 6),
                                  Text(
                                    'Картада көру',
                                    style: TextStyle(
                                      color: showMap
                                          ? const Color(0xFF2E9B8E)
                                          : Colors.white,
                                      fontSize: isMobile ? 11 : 13,
                                    ),
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
          ),

          // Контент - карта или список
          if (showMap)
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
                      target: LatLng(
                        filteredReports.isNotEmpty
                            ? filteredReports[0]['lat']
                            : 43.2220,
                        filteredReports.isNotEmpty
                            ? filteredReports[0]['lng']
                            : 76.8512,
                      ),
                      zoom: 12,
                    ),
                    markers: filteredReports.map((report) {
                      return Marker(
                        markerId: MarkerId(report['id'].toString()),
                        position: LatLng(report['lat'], report['lng']),
                        infoWindow: InfoWindow(
                          title: report['title'],
                          snippet: report['status'],
                        ),
                      );
                    }).toSet(),
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                  ),
                ),
              ),
            )
          else
          // Список отчетов
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

  Widget _buildReportCard(Map<String, dynamic> report, bool isMobile) {
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
            )
          else
            Container(
              width: double.infinity,
              height: isMobile ? 180 : 220,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(
                Icons.image,
                size: isMobile ? 50 : 60,
                color: Colors.grey[400],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID и автор
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
                // Локация и дата
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isMobile ? 13 : 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: isMobile ? 3 : 4),
                    Text(
                      '${report['location']} • ${report['date']}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 10 : 12),
                // Описание
                Text(
                  report['title'],
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 8 : 10),
                // Тег и координаты
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
                    Icon(
                      Icons.location_on,
                      size: isMobile ? 14 : 16,
                      color: Colors.blue[700],
                    ),
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
                // Кнопки действий
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _markAsResolved(report['id']);
                        },
                        icon: Icon(Icons.check_circle, size: isMobile ? 16 : 18),
                        label: Text(
                          'Шешілді',
                          style: TextStyle(fontSize: isMobile ? 12 : 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9B8E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showDeleteConfirmation(report['id']);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 10,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, size: isMobile ? 16 : 18),
                            SizedBox(width: isMobile ? 4 : 6),
                            Text(
                              'Жою',
                              style: TextStyle(fontSize: isMobile ? 12 : 13),
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
        ],
      ),
    );
  }

  void _markAsResolved(int reportId) {
    setState(() {
      final index = reports.indexWhere((r) => r['id'] == reportId);
      if (index != -1) {
        reports[index]['status'] = 'Шешілді';
        reports[index]['statusColor'] = const Color(0xFF2E9B8E);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Шағым шешілді деп белгіленді!'),
        backgroundColor: Color(0xFF2E9B8E),
      ),
    );
  }

  void _showDeleteConfirmation(int reportId) {
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
        content: const Text('Шағымды жойғыңыз келетініне сенімдісіз бе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                reports.removeWhere((r) => r['id'] == reportId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Шағым жойылды'),
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
}
