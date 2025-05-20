// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/service_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _username = ""; // Kullanıcı adı dinamik olarak yüklenecek
  bool _isLoading = true;
  String _errorMessage = '';

  // Örnek takvim tarihleri
  final List<DateTime> _weekDays = List.generate(
    5,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  // Dinamik olarak yüklenecek ders listesi
  List<Map<String, dynamic>> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadClasses();
  }

  // Kullanıcı verilerini yükleme
  Future<void> _loadUserData() async {
    try {
      final currentUser = context.authService.currentUser;
      if (currentUser != null) {
        // Firestore'dan kullanıcı bilgilerini al
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = userData['username'] ?? "User";
          });
        }
      }
    } catch (e) {
      print('Kullanıcı verileri yüklenirken hata: $e');
    }
  }

  // Firebase'den dersleri yükleme
  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Seçili günün adını al
      final selectedDay = DateFormat('EEEE').format(_weekDays[_selectedIndex]);

      // Firestore'dan dersleri çek - seçili güne göre filtrele
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('day', isEqualTo: selectedDay)
          .orderBy('startTime')
          .get();

      print('Günlük dersler yükleniyor. Gün: $selectedDay');
      print('Bulunan ders sayısı: ${snapshot.docs.length}');

      // Verileri işle ve _classes listesine ekle
      final List<Map<String, dynamic>> loadedClasses = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'startTime': data['startTime'] ?? '',
          'endTime': data['endTime'] ?? '',
          'day': data['day'] ?? '',
          'trainer': data['trainer'] ?? '',
          'capacity': data['capacity'] ?? 0,
          'enrolled': data['enrolled'] ?? 0,
          'description': data['description'] ?? '',
          'intensity': data['intensity'] ?? '',
          'calories': data['calories'] ?? '',
          'location': data['location'] ?? '',
          'status': 'upcoming', // Varsayılan durum
        };
      }).toList();

      setState(() {
        _classes = loadedClasses;
        _isLoading = false;
      });

      if (_classes.isEmpty) {
        print('Seçili gün için ders bulunamadı: $selectedDay');
      } else {
        print('${_classes.length} ders başarıyla yüklendi');
      }
    } catch (e) {
      print('Dersler yüklenirken hata: $e');
      setState(() {
        _errorMessage =
            'Dersler yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
        _isLoading = false;
      });
    }
  }

  // Tarih değiştiğinde dersleri yeniden yükle
  void _onDateChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _loadClasses(); // Yeni tarihe göre dersleri yükle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SUGYM+',
          style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold, color: Colors.white),
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
                style: GoogleFonts.ubuntu(
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
                DateFormat('MMMM dd, EEEE')
                    .format(_weekDays[_selectedIndex])
                    .toUpperCase(),
                style: GoogleFonts.ubuntu(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Yükleniyor göstergesi
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              // Hata mesajı
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadClasses,
                          child: Text(
                            'Tekrar Dene',
                            style: GoogleFonts.ubuntu(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Dersler listesi veya boş mesaj
              else if (_classes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Bu tarih için ders bulunamadı',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
            onTap: () => _onDateChanged(index),
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
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  classInfo['name'],
                  style: GoogleFonts.ubuntu(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Rezervasyon butonu
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
              child: Text(
                'Reserve',
                style: GoogleFonts.ubuntu(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
