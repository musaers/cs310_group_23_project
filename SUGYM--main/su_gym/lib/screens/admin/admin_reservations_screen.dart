// lib/screens/admin/admin_reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _reservations = [];
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  // Firestore listener subscription
  StreamSubscription<QuerySnapshot>? _reservationsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _setupReservationsListener();
      }
    });
    _setupReservationsListener();
  }

  @override
  void dispose() {
    // Cancel the stream subscription
    _reservationsSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // Setup real-time Firestore listener
  void _setupReservationsListener() {
    // Cancel previous subscription
    _reservationsSubscription?.cancel();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      Query query = FirebaseFirestore.instance.collection('reservations');

      // Apply filters based on the selected tab
      switch (_tabController.index) {
        case 0: // Today
          final today = DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day);
          final tomorrow = today.add(const Duration(days: 1));
          query = query
              .where('date', isGreaterThanOrEqualTo: today)
              .where('date', isLessThan: tomorrow);
          break;
        case 1: // Upcoming
          final now = DateTime.now();
          query = query.where('date', isGreaterThanOrEqualTo: now);
          break;
        case 2: // History
          final now = DateTime.now();
          query = query.where('date', isLessThan: now);
          break;
      }

      // Order by date
      query = query.orderBy('date');

      // Set up the real-time listener
      _reservationsSubscription = query.snapshots().listen(
        (snapshot) async {
          final List<Map<String, dynamic>> reservations = [];

          // For each reservation, load user data
          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // Get user data
            DocumentSnapshot? userDoc;
            try {
              if (data['userId'] != null) {
                userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['userId'])
                    .get();
              }
            } catch (e) {
              print('Error fetching user: $e');
            }

            Map<String, dynamic> reservation = {
              'id': doc.id,
              'userId': data['userId'] ?? '',
              'classId': data['classId'] ?? '',
              'className': data['className'] ?? 'Unknown Class',
              'startTime': data['startTime'] ?? '',
              'endTime': data['endTime'] ?? '',
              'day': data['day'] ?? '',
              'date': data['date'] is Timestamp
                  ? (data['date'] as Timestamp).toDate()
                  : DateTime.now(),
              'status': data['status'] ?? 'Pending',
              'createdAt': data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
            };

            // Add user info if available
            if (userDoc != null && userDoc.exists) {
              Map<String, dynamic> userData =
                  userDoc.data() as Map<String, dynamic>;
              reservation['username'] = userData['username'] ?? 'Unknown User';
              reservation['userEmail'] = userData['email'] ?? '';
            } else {
              reservation['username'] = 'Unknown User';
              reservation['userEmail'] = '';
            }

            reservations.add(reservation);
          }

          if (mounted) {
            setState(() {
              _reservations = reservations;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          print('Error listening to reservations: $error');
          if (mounted) {
            setState(() {
              _errorMessage = 'Error listening to reservations: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      print('Error setting up reservation listener: $e');
      setState(() {
        _errorMessage = 'Error setting up reservation listener: $e';
        _isLoading = false;
      });
    }
  }

  // Approve reservation
  Future<void> _approveReservation(String reservationId, String classId) async {
    try {
      // First get reservation details
      DocumentSnapshot reservationDoc = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .get();

      if (!reservationDoc.exists) {
        throw Exception('Reservation not found');
      }

      Map<String, dynamic> reservationData =
          reservationDoc.data() as Map<String, dynamic>;
      String oldStatus = reservationData['status'];

      // Update reservation status to Approved
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({'status': 'Approved'});

      // If the reservation was previously pending, increment the enrolled count
      if (oldStatus == 'Pending') {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .update({'enrolled': FieldValue.increment(1)});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation approved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // No need to reload reservations manually, we have real-time listener
    } catch (e) {
      print('Error approving reservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving reservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Cancel reservation (update to Cancelled status)
  Future<void> _cancelReservation(String reservationId, String classId) async {
    try {
      // First get reservation details
      DocumentSnapshot reservationDoc = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .get();

      if (!reservationDoc.exists) {
        throw Exception('Reservation not found');
      }

      Map<String, dynamic> reservationData =
          reservationDoc.data() as Map<String, dynamic>;
      String oldStatus = reservationData['status'];

      // Update reservation status to Cancelled
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({'status': 'Cancelled'});

      // If the reservation was previously approved, decrement the enrolled count
      if (oldStatus == 'Approved') {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .update({'enrolled': FieldValue.increment(-1)});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // No need to reload reservations manually, we have real-time listener
    } catch (e) {
      print('Error cancelling reservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling reservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservations Management',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _setupReservationsListener,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date indicator for Today tab
          if (_tabController.index == 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.purple.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing reservations for: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)}',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),

          // Reservations list
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
                              onPressed: _setupReservationsListener,
                              child: Text(
                                'Try Again',
                                style: GoogleFonts.ubuntu(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _reservations.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _reservations.length,
                            itemBuilder: (context, index) {
                              return _buildReservationItem(
                                  _reservations[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _setupReservationsListener();
    }
  }

  // Empty state widget
  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_tabController.index) {
      case 0:
        message = 'No reservations for today';
        icon = Icons.event_busy;
        break;
      case 1:
        message = 'No upcoming reservations';
        icon = Icons.calendar_today;
        break;
      case 2:
        message = 'No reservation history';
        icon = Icons.history;
        break;
      default:
        message = 'No reservations found';
        icon = Icons.event_busy;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.ubuntu(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Reservation item widget - simplified to match your UI
  Widget _buildReservationItem(Map<String, dynamic> reservation) {
    // Check if this is the selected reservation (showing details)
    // Status color
    Color statusColor;
    switch (reservation['status']) {
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Formatted date
    final reservationDate = reservation['date'] as DateTime;
    final formattedDate =
        DateFormat('EEE, MMM d, yyyy').format(reservationDate);

    // Check if reservation is in the past
    final isPastReservation = reservationDate.isBefore(DateTime.now());

    return Column(
      children: [
        // First part - always visible, similar to what's in your UI
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: const Icon(Icons.calendar_today, color: Colors.purple),
          ),
          title: Text(
            reservation['className'],
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Tue, May 20, 2025 · ${reservation['startTime']} - ${reservation['endTime']}',
            style: GoogleFonts.ubuntu(),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              reservation['status'],
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            // Show a dialog with details and action buttons
            _showReservationActions(reservation);
          },
        ),
        const Divider(),
      ],
    );
  }

  // Show a dialog with reservation details and actions
  void _showReservationActions(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reservation Details',
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class info
            Text(
              reservation['className'],
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${reservation['startTime']} - ${reservation['endTime']}',
              style: GoogleFonts.ubuntu(),
            ),
            const SizedBox(height: 16),

            // User info
            Text(
              'User Information',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text('Username: ${reservation['username']}'),
            Text('Email: ${reservation['userEmail']}'),
            const SizedBox(height: 16),

            // Reservation info
            Text(
              'Reservation Information',
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text('ID: ${reservation['id']}'),
            Text('Status: ${reservation['status']}'),
            Text(
                'Created: ${DateFormat('dd/MM/yyyy HH:mm').format(reservation['createdAt'])}'),
          ],
        ),
        actions: [
          // Close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.ubuntu(),
            ),
          ),

          // Action buttons based on status
          if (reservation['status'] == 'Pending')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _approveReservation(reservation['id'], reservation['classId']);
              },
              child: Text(
                'Approve',
                style: GoogleFonts.ubuntu(),
              ),
            ),

          if (reservation['status'] != 'Cancelled')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _cancelReservation(reservation['id'], reservation['classId']);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.ubuntu(),
              ),
            ),
        ],
      ),
    );
  }
}
