// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/service_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String _adminUsername = "Admin";

  // Statistics data
  int _totalUsers = 0;
  int _activeMembers = 0;
  int _todayReservations = 0;
  int _totalClasses = 0;

  // Recent activity list
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadStatistics();
    _loadRecentActivities();
  }

  // Load admin data
  Future<void> _loadAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists) {
          setState(() {
            _adminUsername = adminDoc.data()?['username'] ?? "Admin";
          });
        }
      }
    } catch (e) {
      print('Error loading admin data: $e');
    }
  }

  // Load statistics
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Total users count
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Active memberships count
      final activeMembers = await FirebaseFirestore.instance
          .collection('users')
          .where('membership.status', isEqualTo: 'Active')
          .get();

      // Today's reservations
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayReservations = await FirebaseFirestore.instance
          .collection('reservations')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      // Total classes
      final classesSnapshot =
          await FirebaseFirestore.instance.collection('classes').get();

      setState(() {
        _totalUsers = userSnapshot.docs.length;
        _activeMembers = activeMembers.docs.length;
        _todayReservations = todayReservations.docs.length;
        _totalClasses = classesSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load recent activities
  Future<void> _loadRecentActivities() async {
    try {
      // Recent user registrations
      final recentUsers = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      // Recent reservations
      final recentReservations = await FirebaseFirestore.instance
          .collection('reservations')
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      // Recent feedback
      final recentFeedbacks = await FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      List<Map<String, dynamic>> activities = [];

      // Add user registrations
      for (var doc in recentUsers.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        activities.add({
          'type': 'user_registration',
          'title': 'New User Registration',
          'description': '${data['username']} has registered',
          'time': _getTimeAgo(createdAt),
          'color': Colors.green,
          'icon': Icons.person_add,
        });
      }

      // Add reservations
      for (var doc in recentReservations.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        activities.add({
          'type': 'reservation',
          'title': 'New Reservation',
          'description': '${data['className']} class has been reserved',
          'time': _getTimeAgo(createdAt),
          'color': Colors.blue,
          'icon': Icons.calendar_today,
        });
      }

      // Add feedback
      for (var doc in recentFeedbacks.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now();

        activities.add({
          'type': 'feedback',
          'title': 'New Feedback',
          'description': 'Rating: ${data['overallRating']}/5.0',
          'time': _getTimeAgo(createdAt),
          'color': Colors.purple,
          'icon': Icons.feedback,
        });
      }

      // Sort by time
      activities.sort((a, b) {
        final aTime = a['time'] as String;
        final bTime = b['time'] as String;

        // "Just now" is newest
        if (aTime == 'Just now') return -1;
        if (bTime == 'Just now') return 1;

        // "X minutes ago" sorting
        if (aTime.contains('minute') && bTime.contains('minute')) {
          final aMinutes = int.tryParse(aTime.split(' ')[0]) ?? 0;
          final bMinutes = int.tryParse(bTime.split(' ')[0]) ?? 0;
          return aMinutes.compareTo(bMinutes);
        }

        // "X hours ago" sorting
        if (aTime.contains('hour') && bTime.contains('hour')) {
          final aHours = int.tryParse(aTime.split(' ')[0]) ?? 0;
          final bHours = int.tryParse(bTime.split(' ')[0]) ?? 0;
          return aHours.compareTo(bHours);
        }

        // "X days ago" sorting
        if (aTime.contains('day') && bTime.contains('day')) {
          final aDays = int.tryParse(aTime.split(' ')[0]) ?? 0;
          final bDays = int.tryParse(bTime.split(' ')[0]) ?? 0;
          return aDays.compareTo(bDays);
        }

        // Mixed sorting
        if (aTime.contains('minute') && bTime.contains('hour')) return -1;
        if (aTime.contains('hour') && bTime.contains('minute')) return 1;
        if (aTime.contains('minute') && bTime.contains('day')) return -1;
        if (aTime.contains('day') && bTime.contains('minute')) return 1;
        if (aTime.contains('hour') && bTime.contains('day')) return -1;
        if (aTime.contains('day') && bTime.contains('hour')) return 1;

        return 0;
      });

      // Get the latest 4 activities
      setState(() {
        _recentActivities = activities.take(4).toList();
      });
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  // Format time ago
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  // Sign out
  Future<void> _logout() async {
    await context.authService.signOut();
    Navigator.pushReplacementNamed(context, '/admin/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SUGYM+ Admin Panel',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadStatistics();
              _loadRecentActivities();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      'Welcome, $_adminUsername',
                      style: GoogleFonts.ubuntu(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here are the stats for today',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          title: 'Total Users',
                          value: '$_totalUsers',
                          icon: Icons.people,
                          color: Colors.blue,
                          onTap: () {
                            // In the future: Navigate to users list or show detailed info
                            Navigator.pushNamed(context, '/admin/users');
                          },
                        ),
                        _buildStatCard(
                          title: 'Active Memberships',
                          value: '$_activeMembers',
                          icon: Icons.card_membership,
                          color: Colors.green,
                          onTap: () {
                            // In the future: Navigate to memberships list
                            Navigator.pushNamed(context, '/admin/memberships');
                          },
                        ),
                        _buildStatCard(
                          title: 'Today\'s Reservations',
                          value: '$_todayReservations',
                          icon: Icons.calendar_today,
                          color: Colors.orange,
                          onTap: () {
                            // In the future: Navigate to reservations list
                            Navigator.pushNamed(context, '/admin/reservations');
                          },
                        ),
                        _buildStatCard(
                          title: 'Total Classes',
                          value: '$_totalClasses',
                          icon: Icons.fitness_center,
                          color: Colors.purple,
                          onTap: () {
                            // Navigate to classes list
                            Navigator.pushNamed(context, '/admin/classes');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent activities
                    Text(
                      'Recent Activities',
                      style: GoogleFonts.ubuntu(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityList(),
                    const SizedBox(height: 24),

                    // Quick action buttons
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.ubuntu(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            title: 'Add New Class',
                            icon: Icons.add_circle,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/admin/classes/create');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            title: 'Post Announcement',
                            icon: Icons.announcement,
                            color: Colors.orange,
                            onTap: () {
                              // Navigation for announcements
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            title: 'Membership Plans',
                            icon: Icons.card_membership,
                            color: Colors.green,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/admin/memberships');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            title: 'View Feedback',
                            icon: Icons.feedback,
                            color: Colors.purple,
                            onTap: () {
                              // Navigation for feedback
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Drawer (sidebar) menu
  Widget _buildDrawer() {
    // Menu items list
    final List<Map<String, dynamic>> _menuItems = [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'route': '/admin/dashboard',
      },
      {
        'title': 'Users',
        'icon': Icons.people,
        'route': '/admin/users',
      },
      {
        'title': 'Classes',
        'icon': Icons.fitness_center,
        'route': '/admin/classes',
      },
      {
        'title': 'Reservations',
        'icon': Icons.calendar_today,
        'route': '/admin/reservations',
      },
      {
        'title': 'Membership Plans',
        'icon': Icons.card_membership,
        'route': '/admin/memberships',
      },
      {
        'title': 'Feedback',
        'icon': Icons.feedback,
        'route': '/admin/feedback',
      },
      {
        'title': 'Announcements',
        'icon': Icons.announcement,
        'route': '/admin/announcements',
      },
      {
        'title': 'Settings',
        'icon': Icons.settings,
        'route': '/admin/settings',
      },
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.purple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.purple,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Admin Panel',
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _adminUsername,
                  style: GoogleFonts.ubuntu(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          ..._menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: _selectedIndex == index ? Colors.purple : Colors.grey,
              ),
              title: Text(
                item['title'],
                style: GoogleFonts.ubuntu(
                  color: _selectedIndex == index ? Colors.purple : Colors.black,
                  fontWeight: _selectedIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: _selectedIndex == index,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                Navigator.pop(context); // Close drawer

                // Navigate to the relevant page (don't navigate if already on the page)
                if (item['route'] != '/admin/dashboard' ||
                    _selectedIndex != 0) {
                  Navigator.pushNamed(context, item['route']);
                }
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Logout',
              style: GoogleFonts.ubuntu(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  // Logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout from the admin panel?',
          style: GoogleFonts.ubuntu(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.ubuntu(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              'Logout',
              style: GoogleFonts.ubuntu(),
            ),
          ),
        ],
      ),
    );
  }

  // Recent activity list
  Widget _buildActivityList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: _recentActivities.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No recent activities',
                  style: GoogleFonts.ubuntu(color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = _recentActivities[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: activity['color'].withOpacity(0.2),
                    child: Icon(
                      activity['icon'],
                      color: activity['color'],
                    ),
                  ),
                  title: Text(
                    activity['title'],
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    activity['description'],
                    style: GoogleFonts.ubuntu(),
                  ),
                  trailing: Text(
                    activity['time'],
                    style: GoogleFonts.ubuntu(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Statistics card widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: GoogleFonts.ubuntu(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick action button widget
  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
