// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final String _username = "Username"; // Normalde bu kullanıcı verilerinden gelir

  // Örnek takvim tarihleri
  final List<DateTime> _weekDays = List.generate(
    5,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  // Örnek ders listesi
  final List<Map<String, dynamic>> _classes = [
    {
      'startTime': '08:00',
      'endTime': '08:45',
      'name': 'Full Body',
      'status': 'upcoming', // upcoming, ongoing, past
    },
    {
      'startTime': '10:00',
      'endTime': '10:45',
      'name': 'Pilates',
      'status': 'upcoming',
    },
    {
      'startTime': '12:00',
      'endTime': '12:45',
      'name': 'Full Body',
      'status': 'upcoming',
    },
    {
      'startTime': '17:00',
      'endTime': '17:45',
      'name': 'Full Body',
      'status': 'upcoming',
    },
    {
      'startTime': '19:00',
      'endTime': '19:45',
      'name': 'Cycling',
      'status': 'upcoming',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SUGYM+',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Karşılama mesajı
              Text(
                'Welcome $_username',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Takvim tarihleri
              _buildCalendar(),
              const SizedBox(height: 24),
              
              // Seçili tarih başlığı
              Text(
                DateFormat('MMMM dd, EEEE').format(_weekDays[_selectedIndex]).toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Ders listesi
              ..._classes.map((classInfo) => _buildClassCard(classInfo)),
            ],
          ),
        ),
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
          if (index == 1) {
            Navigator.pushNamed(context, '/classes');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  // Takvim widget'i
  Widget _buildCalendar() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final day = _weekDays[index];
          final isSelected = index == _selectedIndex;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(day),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('E').format(day),
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Ders kartı widget'i
  Widget _buildClassCard(Map<String, dynamic> classInfo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ders saati
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${classInfo['startTime']}/${classInfo['endTime']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  classInfo['name'],
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Rezervasyon/İptal düğmesi
            if (classInfo['status'] == 'upcoming')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Rezervasyon sayfasına yönlendir
                  Navigator.pushNamed(
                    context, 
                    '/reservations',
                    arguments: classInfo,
                  );
                },
                child: const Text('Reserve'),
              ),
            if (classInfo['status'] == 'reserved')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // İptal işlemleri
                },
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}
