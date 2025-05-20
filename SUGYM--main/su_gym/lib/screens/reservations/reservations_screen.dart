// lib/screens/reservations/reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../services/service_provider.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _reservations = [];
  Map<String, dynamic>?
      _selectedClass; // User selected class (comes as argument)
  DateTime _selectedDate = DateTime.now(); // Default to today
  bool _isCreatingReservation = false; // Reservation creation state

  // Firestore listener subscription
  StreamSubscription<QuerySnapshot>? _reservationsSubscription;

  @override
  void initState() {
    super.initState();
    // Check arguments after page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkArguments();
      _setupReservationsListener();
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription
    _reservationsSubscription?.cancel();
    super.dispose();
  }

  // Check page arguments
  void _checkArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      setState(() {
        _selectedClass = arguments;
        // If argument includes a day, set selected date to that day
        final dayName = _selectedClass!['day'];
        if (dayName != null && dayName.isNotEmpty) {
          _selectedDate = _getDateFromDayName(dayName);
        }
      });
      print('Selected class: ${_selectedClass?['name']}');
    } else {
      print('No class selected');
    }
  }

  // Get date from day name
  DateTime _getDateFromDayName(String dayName) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final today = DateTime.now();
    final todayWeekday = today.weekday; // 1 = Monday, 7 = Sunday

    final targetWeekday = daysOfWeek.indexOf(dayName) + 1;
    final difference = targetWeekday - todayWeekday;

    // If target day is before today, get next week's day
    final daysToAdd = difference < 0 ? difference + 7 : difference;
    return today.add(Duration(days: daysToAdd));
  }

  // Setup real-time Firestore listener
  void _setupReservationsListener() {
    // Cancel previous subscription if exists
    _reservationsSubscription?.cancel();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Set up real-time listener for user's reservations
      _reservationsSubscription = FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: false)
          .snapshots()
          .listen(
        (snapshot) {
          final List<Map<String, dynamic>> reservations =
              snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // Convert Firestore Timestamp to DateTime
            DateTime date = DateTime.now();
            if (data['date'] != null && data['date'] is Timestamp) {
              date = (data['date'] as Timestamp).toDate();
            }

            return {
              'id': doc.id,
              'userId': data['userId'] ?? '',
              'classId': data['classId'] ?? '',
              'className': data['className'] ?? '',
              'startTime': data['startTime'] ?? '',
              'endTime': data['endTime'] ?? '',
              'day': data['day'] ?? '',
              'date': date,
              'status': data['status'] ?? 'Pending',
              'createdAt': data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
            };
          }).toList();

          if (mounted) {
            setState(() {
              _reservations = reservations;
              _isLoading = false;
            });
          }

          print('Reservations updated: ${reservations.length} items');
        },
        onError: (error) {
          print('Error listening to reservations: $error');
          if (mounted) {
            setState(() {
              _errorMessage = 'Failed to load reservations: $error';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      print('Error setting up reservation listener: $e');
      setState(() {
        _errorMessage = 'Failed to load reservations: $e';
        _isLoading = false;
      });
    }
  }

  // Create reservation
  Future<void> _createReservation() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingReservation = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Prepare reservation data
      final reservationData = {
        'userId': user.uid,
        'classId': _selectedClass!['id'],
        'className': _selectedClass!['name'],
        'startTime': _selectedClass!['startTime'],
        'endTime': _selectedClass!['endTime'],
        'day': _selectedClass!['day'],
        'date': _selectedDate,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add reservation to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('reservations')
          .add(reservationData);

      print('Reservation created: ${docRef.id}');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Reservation created successfully! Waiting for approval.'),
          backgroundColor: Colors.green,
        ),
      );

      // No need to manually reload reservations, we have real-time listener

      // Clear selected class after successful reservation
      setState(() {
        _selectedClass = null;
      });
    } catch (e) {
      print('Error creating reservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating reservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCreatingReservation = false;
      });
    }
  }

  // Cancel reservation
  Future<void> _cancelReservation(String reservationId, String classId) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Cancel Reservation',
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to cancel this reservation?',
                style: GoogleFonts.ubuntu(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No', style: GoogleFonts.ubuntu()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes', style: GoogleFonts.ubuntu()),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      // Get reservation status before updating
      DocumentSnapshot reservationDoc = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .get();

      if (!reservationDoc.exists) {
        throw Exception('Reservation not found');
      }

      Map<String, dynamic> data = reservationDoc.data() as Map<String, dynamic>;
      String currentStatus = data['status'] ?? 'Pending';

      // Update reservation status to Cancelled
      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId)
          .update({'status': 'Cancelled'});

      // Update class enrolled count if the reservation was Approved
      if (currentStatus == 'Approved') {
        await FirebaseFirestore.instance
            .collection('classes')
            .doc(classId)
            .update({'enrolled': FieldValue.increment(-1)});
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // No need to manually reload reservations, we have real-time listener
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
          'My Reservations',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorMessage()
              : _buildReservationsContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/classes');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/qr-code');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.qr_code, color: Colors.white),
      ),
    );
  }

  // Error message widget
  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setupReservationsListener,
              child: Text(
                'Try Again',
                style: GoogleFonts.ubuntu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Main content widget
  Widget _buildReservationsContent() {
    // If a class is selected, show reservation creation screen
    if (_selectedClass != null) {
      return _buildCreateReservationView();
    }

    // Otherwise, show existing reservations
    return _reservations.isEmpty
        ? _buildEmptyReservationsMessage()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reservations.length,
            itemBuilder: (context, index) {
              return _buildReservationCard(_reservations[index]);
            },
          );
  }

  // Empty reservations message
  Widget _buildEmptyReservationsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No reservations yet',
            style: GoogleFonts.ubuntu(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a class to make a reservation',
            style: GoogleFonts.ubuntu(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/classes');
            },
            child: Text(
              'Browse Classes',
              style: GoogleFonts.ubuntu(),
            ),
          ),
        ],
      ),
    );
  }

  // Reservation card
  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    // Format date
    final date = reservation['date'] as DateTime;
    final formattedDate = DateFormat('MMMM d, yyyy').format(date);

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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation['className'],
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation['day']}, $formattedDate',
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    reservation['status'],
                    style: GoogleFonts.ubuntu(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${reservation['startTime']} - ${reservation['endTime']}',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (reservation['status'] != 'Cancelled')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _cancelReservation(
                          reservation['id'], reservation['classId']);
                    },
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Reservation creation screen
  Widget _buildCreateReservationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reservation details card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Reservation Details',
                    style: GoogleFonts.ubuntu(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Class name
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Class',
                              style: GoogleFonts.ubuntu(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _selectedClass!['name'],
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Day and Time
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time',
                              style: GoogleFonts.ubuntu(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${_selectedClass!['day']}, ${_selectedClass!['startTime']} - ${_selectedClass!['endTime']}',
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date selection
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: GoogleFonts.ubuntu(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM d, yyyy').format(_selectedDate),
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.ubuntu(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Create reservation button
          SizedBox(
            width: double.infinity,
            child: _isCreatingReservation
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _createReservation,
                    child: Text(
                      'Confirm Reservation',
                      style: GoogleFonts.ubuntu(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedClass = null;
                });
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Existing reservations title
          if (_reservations.isNotEmpty) ...[
            Text(
              'Your Current Reservations',
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Existing reservations list
            ..._reservations
                .map((reservation) => _buildReservationCard(reservation)),
          ],
        ],
      ),
    );
  }
}
