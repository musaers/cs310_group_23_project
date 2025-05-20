// lib/screens/admin/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  String _filterOption = 'All';
  String _errorMessage = '';

  final List<String> _filterOptions = [
    'All',
    'Active Membership',
    'No Membership',
    'Recent Joins'
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Load users from Firestore
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      Query query = FirebaseFirestore.instance.collection('users');

      // Apply filters
      if (_filterOption == 'Active Membership') {
        query = query.where('membership.status', isEqualTo: 'Active');
      } else if (_filterOption == 'No Membership') {
        query = query.where('membership.status', isEqualTo: 'Inactive');
      } else if (_filterOption == 'Recent Joins') {
        // Get users joined in the last 30 days
        DateTime thirtyDaysAgo =
            DateTime.now().subtract(const Duration(days: 30));
        query = query.where('createdAt', isGreaterThanOrEqualTo: thirtyDaysAgo);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      final QuerySnapshot snapshot = await query.get();

      final List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Extract user data
        Map<String, dynamic> user = {
          'id': doc.id,
          'username': data['username'] ?? 'Unknown',
          'email': data['email'] ?? 'No email',
          'createdAt': data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        };

        // Extract membership data if available
        if (data['membership'] != null && data['membership'] is Map) {
          Map<String, dynamic> membership =
              Map<String, dynamic>.from(data['membership']);
          user['membershipStatus'] = membership['status'] ?? 'Unknown';
          user['membershipPlan'] = membership['plan'] ?? 'None';

          if (membership['endDate'] != null) {
            user['membershipEndDate'] =
                (membership['endDate'] as Timestamp).toDate();
          }
        } else {
          user['membershipStatus'] = 'Inactive';
          user['membershipPlan'] = 'None';
        }

        // Extract fitness data if available
        if (data['fitness'] != null && data['fitness'] is Map) {
          Map<String, dynamic> fitness =
              Map<String, dynamic>.from(data['fitness']);
          user['currentWeight'] = fitness['currentWeight'];
          user['targetWeight'] = fitness['targetWeight'];
          user['progress'] = fitness['progress'] ?? 0.0;
        }

        // Extract statistics data if available
        if (data['statistics'] != null && data['statistics'] is Map) {
          Map<String, dynamic> statistics =
              Map<String, dynamic>.from(data['statistics']);
          user['totalVisits'] = statistics['totalVisits'] ?? 0;
          user['mostAttendedClass'] = statistics['mostAttendedClass'] ?? '';
        }

        users.add(user);
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        setState(() {
          _users = users.where((user) {
            return user['username']
                    .toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                user['email']
                    .toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
          }).toList();
        });
      } else {
        setState(() {
          _users = users;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                // Search box
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _loadUsers();
                  },
                ),
                const SizedBox(height: 16),

                // Filter options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(option),
                          selected: _filterOption == option,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _filterOption = option;
                              });
                              _loadUsers();
                            }
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.purple.shade100,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 60),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ubuntu(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: Text(
                                'Try Again',
                                style: GoogleFonts.ubuntu(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_off,
                                    color: Colors.grey, size: 60),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try changing your search or filter',
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return _buildUserListItem(user);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // User list item widget
  Widget _buildUserListItem(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: const Icon(Icons.person, color: Colors.purple),
        ),
        title: Text(
          user['username'],
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user['membershipStatus'] == 'Active'
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: user['membershipStatus'] == 'Active'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  child: Text(
                    '${user['membershipStatus']}: ${user['membershipPlan']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: user['membershipStatus'] == 'Active'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (user['membershipEndDate'] != null &&
                    user['membershipStatus'] == 'Active')
                  Text(
                    'Expires: ${DateFormat('dd/MM/yyyy').format(user['membershipEndDate'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Account details section
                _buildDetailSection(
                  'Account Details',
                  [
                    {'label': 'User ID', 'value': user['id']},
                    {
                      'label': 'Joined',
                      'value':
                          DateFormat('dd/MM/yyyy').format(user['createdAt'])
                    },
                  ],
                ),
                const SizedBox(height: 16),

                // Membership details if active
                if (user['membershipStatus'] == 'Active')
                  _buildDetailSection(
                    'Membership Details',
                    [
                      {'label': 'Plan', 'value': user['membershipPlan']},
                      {
                        'label': 'Expires',
                        'value': user['membershipEndDate'] != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(user['membershipEndDate'])
                            : 'Never'
                      },
                    ],
                  ),

                // Fitness details if available
                if (user['currentWeight'] != null ||
                    user['targetWeight'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        'Fitness Details',
                        [
                          {
                            'label': 'Current Weight',
                            'value': user['currentWeight'] != null
                                ? '${user['currentWeight']} kg'
                                : 'Not set'
                          },
                          {
                            'label': 'Target Weight',
                            'value': user['targetWeight'] != null
                                ? '${user['targetWeight']} kg'
                                : 'Not set'
                          },
                          {
                            'label': 'Progress',
                            'value': '${(user['progress'] * 100).toInt()}%'
                          },
                        ],
                      ),
                    ],
                  ),

                // Statistics details if available
                if (user['totalVisits'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        'Activity Statistics',
                        [
                          {
                            'label': 'Total Visits',
                            'value': user['totalVisits'].toString()
                          },
                          {
                            'label': 'Most Attended Class',
                            'value': user['mostAttendedClass'].isNotEmpty
                                ? user['mostAttendedClass']
                                : 'None'
                          },
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        // Edit user (not implemented)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature not implemented yet'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.block, color: Colors.red),
                      label: const Text('Deactivate',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        // Deactivate user (not implemented)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Deactivate feature not implemented yet'),
                          ),
                        );
                      },
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

  // Detail section widget
  Widget _buildDetailSection(String title, List<Map<String, String>> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...details.map((detail) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  detail['label']!,
                  style: GoogleFonts.ubuntu(
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  detail['value']!,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

