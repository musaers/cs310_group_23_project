// lib/screens/reservations/reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  // Örnek rezervasyon listesi
  final List<Map<String, dynamic>> _reservations = [
    {
      'id': '1',
      'className': 'Full Body',
      'startTime': '10:00',
      'endTime': '10:45',
      'day': 'Monday',
      'date': '2025-03-31',
      'status': 'Approved', // Approved, Pending, Cancelled
    },
    {
      'id': '2',
      'className': 'Pilates',
      'startTime': '17:00',
      'endTime': '17:45',
      'day': 'Tuesday',
      'date': '2025-04-01',
      'status': 'Approved',
    },
    {
      'id': '3',
      'className': 'Full Body',
      'startTime': '08:00',
      'endTime': '08:45',
      'day': 'Wednesday',
      'date': '2025-04-02',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Reservations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: _reservations.isEmpty
          ? const Center(child: Text('No reservations yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                return _buildReservationCard(_reservations[index]);
              },
            ),
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

  // Rezervasyon kartı
  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    // Tarih formatı
    final date = DateTime.parse(reservation['date']);
    final formattedDate = DateFormat('MMMM d, yyyy').format(date);
    
    // Durum rengi
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation['day']}, $formattedDate',
                      style: TextStyle(
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
                    style: TextStyle(
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
                  style: const TextStyle(
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
                      // İptal iletişim kutusu
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cancel Reservation'),
                          content: const Text(
                            'Are you sure you want to cancel this reservation?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                // İptal işlemi
                                Navigator.pop(context);
                                setState(() {
                                  reservation['status'] = 'Cancelled';
                                });
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );
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
}
