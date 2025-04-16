// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Örnek bildirim verileri
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Membership Renewal',
      'message': 'Your membership will expire in 5 days. Renew now to avoid service interruption.',
      'type': 'important',
      'read': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'title': 'New Class Available',
      'message': 'Try our new HIIT class starting next week. Book your spot now!',
      'type': 'info',
      'read': false,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '3',
      'title': 'Class Cancellation',
      'message': 'Unfortunately, the Yoga class scheduled for tomorrow at 10:00 AM has been cancelled. We apologize for the inconvenience.',
      'type': 'alert',
      'read': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '4',
      'title': 'Special Offer',
      'message': 'Bring a friend this weekend and get 50% off on their day pass!',
      'type': 'promo',
      'read': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '5',
      'title': 'Feedback Request',
      'message': 'How was your experience with our trainer John? Tap to leave feedback.',
      'type': 'info',
      'read': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 4)),
    },
    {
      'id': '6',
      'title': 'Holiday Hours',
      'message': 'Please note that our gym will operate with reduced hours during the upcoming holiday. Check our website for details.',
      'type': 'info',
      'read': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(_notifications[index]);
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text(
            'Back to Main Page',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Bildirimleri okundu olarak işaretleme
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Bildirim öğesi
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    // Bildirimlerin türüne göre simge ve renk belirle
    IconData iconData;
    Color iconColor;
    
    switch (notification['type']) {
      case 'important':
        iconData = Icons.priority_high;
        iconColor = Colors.red;
        break;
      case 'alert':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'promo':
        iconData = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      case 'info':
      default:
        iconData = Icons.info;
        iconColor = Colors.blue;
        break;
    }
    
    // Zaman formatı
    final String formattedTime = _getFormattedTime(notification['timestamp']);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification['read'] 
            ? BorderSide.none 
            : BorderSide(color: iconColor, width: 1.5),
      ),
      elevation: notification['read'] ? 1 : 3,
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bildirim simgesi
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Bildirim içeriği
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        color: notification['read'] ? Colors.grey.shade600 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Bildirim eylemleri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _onNotificationDelete(notification),
                          child: const Text('Delete'),
                        ),
                        if (!notification['read'])
                          TextButton(
                            onPressed: () => _onNotificationMarkAsRead(notification),
                            child: const Text('Mark as read'),
                          ),
                      ],
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

  // Zaman formatlaması
  String _getFormattedTime(DateTime timestamp) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Bildirime tıklama
  void _onNotificationTap(Map<String, dynamic> notification) {
    // Bildirimi okundu olarak işaretle
    setState(() {
      notification['read'] = true;
    });
    
    // Bildirim tipine göre yönlendirme
    switch (notification['type']) {
      case 'important':
        if (notification['title'].contains('Membership')) {
          Navigator.pushNamed(context, '/membership-plans');
        }
        break;
      case 'promo':
        // Promosyon sayfasına yönlendir
        break;
      case 'info':
        if (notification['title'].contains('Class')) {
          Navigator.pushNamed(context, '/classes');
        } else if (notification['title'].contains('Feedback')) {
          Navigator.pushNamed(context, '/feedback');
        }
        break;
      default:
        break;
    }
  }

  // Bildirimi okundu olarak işaretleme
  void _onNotificationMarkAsRead(Map<String, dynamic> notification) {
    setState(() {
      notification['read'] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Bildirimi silme
  void _onNotificationDelete(Map<String, dynamic> notification) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notification['id']);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
