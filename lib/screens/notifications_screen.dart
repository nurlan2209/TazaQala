import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0;

  @override
  bool get wantKeepAlive => true;

  final List<String> filters = ['Барлығы', 'Оқылмаған', 'Оқылған'];

  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'type': 'warning',
      'icon': Icons.access_time,
      'iconColor': const Color(0xFFFFA726),
      'bgColor': const Color(0xFFFFF3E0),
      'title': 'Назар аудару қажет',
      'description': 'Астана қалалғында 5-тен астам күтілетін шағымдар бар',
      'time': '4 күн бұрын',
      'isRead': false,
      'showAction': true,
    },
    {
      'id': 2,
      'type': 'info',
      'icon': Icons.info_outline,
      'iconColor': const Color(0xFF42A5F5),
      'bgColor': const Color(0xFFE3F2FD),
      'title': 'Жаңа пайдаланушы тіркелді',
      'description': 'Ерлан Нұрғалиев жүйеге тіркелді',
      'time': '4 күн бұрын',
      'isRead': false,
      'showAction': false,
    },
    {
      'id': 3,
      'type': 'news',
      'icon': Icons.article_outlined,
      'iconColor': const Color(0xFF66BB6A),
      'bgColor': const Color(0xFFE8F5E9),
      'title': 'Жаңа жаңалық қосылды',
      'description': 'Жол жөндеу жұмыстары туралы жаңа жаңалық жарияланды',
      'time': '5 күн бұрын',
      'isRead': false,
      'showAction': false,
    },
    {
      'id': 4,
      'type': 'technical',
      'icon': Icons.build_circle_outlined,
      'iconColor': const Color(0xFFEF5350),
      'bgColor': const Color(0xFFFFEBEE),
      'title': 'Жүйе техникалық қызмет көрсету',
      'description': 'Ертең түні 2:00-ден 4:00-ге дейін техникалық қызмет көрсету жоспарланған',
      'time': '5 күн бұрын',
      'isRead': true,
      'showAction': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedFilterIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredNotifications {
    if (_selectedFilterIndex == 0) return notifications;
    if (_selectedFilterIndex == 1) {
      return notifications.where((n) => !n['isRead']).toList();
    }
    return notifications.where((n) => n['isRead']).toList();
  }

  int get unreadCount => notifications.where((n) => !n['isRead']).length;
  int get readCount => notifications.where((n) => n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return CustomScrollView(
      slivers: [
        _buildAppBar(isMobile),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Барлық хабарламалар',
                        notifications.length.toString(),
                        Icons.notifications_active,
                        const Color(0xFF2E9B8E),
                        isMobile,
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: _buildStatCard(
                        'Оқылмаған',
                        unreadCount.toString(),
                        Icons.circle_notifications,
                        const Color(0xFFFF9800),
                        isMobile,
                      ),
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: _buildStatCard(
                        'Оқылған',
                        readCount.toString(),
                        Icons.done_all,
                        const Color(0xFF66BB6A),
                        isMobile,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                child: Column(
                  children: filteredNotifications
                      .map((notif) => _buildNotificationCard(notif, isMobile))
                      .toList(),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(bool isMobile) {
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: isMobile ? 36 : 40,
                                height: isMobile ? 36 : 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: isMobile ? 20 : 24,
                                ),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Хабарламалар',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$unreadCount оқылмаған хабарлама',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isMobile ? 11 : 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'read_all') {
                          _markAllAsRead();
                        } else if (value == 'delete_read') {
                          _deleteReadNotifications();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'read_all',
                          child: Row(
                            children: [
                              Icon(Icons.done_all, size: 20),
                              SizedBox(width: 12),
                              Text('Оқылды деп белгілеу'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete_read',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Оқылғанды жою', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 14 : 16),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: const Color(0xFF2E9B8E),
                    unselectedLabelColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.normal,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Барлығы'),
                      Tab(text: 'Оқылмаған'),
                      Tab(text: 'Оқылған'),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
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
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, bool isMobile) {
    return Dismissible(
      key: Key(notif['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        setState(() {
          notifications.removeWhere((n) => n['id'] == notif['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Хабарлама жойылды'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _markAsRead(notif),
        child: Container(
          margin: EdgeInsets.only(bottom: isMobile ? 10 : 12),
          decoration: BoxDecoration(
            color: notif['isRead'] ? Colors.white : notif['bgColor'],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif['isRead']
                  ? Colors.grey[200]!
                  : notif['iconColor'].withOpacity(0.3),
              width: notif['isRead'] ? 1 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notif['iconColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    notif['icon'],
                    color: notif['iconColor'],
                    size: isMobile ? 20 : 24,
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'],
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                              ),
                            ),
                          ),
                          if (!notif['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      Text(
                        notif['description'],
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Text(
                        notif['time'],
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (notif['showAction']) ...[
                        SizedBox(height: isMobile ? 10 : 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _markAsRead(notif);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Оқылды деп белгіленді'),
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
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 8 : 10,
                                  ),
                                ),
                                child: Text(
                                  'Оқылды деп белгілеу',
                                  style: TextStyle(fontSize: isMobile ? 11 : 12),
                                ),
                              ),
                            ),
                            SizedBox(width: isMobile ? 6 : 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF3D8FCC),
                                side: const BorderSide(color: Color(0xFF3D8FCC)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 16,
                                  vertical: isMobile ? 8 : 10,
                                ),
                              ),
                              child: Text(
                                'Толығырақ',
                                style: TextStyle(fontSize: isMobile ? 11 : 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteNotification(notif['id']),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.grey[400],
                    size: isMobile ? 20 : 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsRead(Map<String, dynamic> notif) {
    setState(() {
      notif['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notif in notifications) {
        notif['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Барлық хабарламалар оқылды'),
        backgroundColor: const Color(0xFF2E9B8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteReadNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Жою'),
          ],
        ),
        content: const Text('Оқылған хабарламаларды жойғыңыз келетініне сенімдісіз бе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                notifications.removeWhere((n) => n['isRead']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Оқылған хабарламалар жойылды'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Иә, жою'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Жою'),
          ],
        ),
        content: const Text('Хабарламаны жойғыңыз келетініне сенімдісіз бе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Жоқ'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                notifications.removeWhere((n) => n['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Хабарлама жойылды'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Иә, жою'),
          ),
        ],
      ),
    );
  }
}
