// lib/screens/classes/classes_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  // Dinamik ders listesi - artık boş başlıyor
  List<Map<String, dynamic>> _classes = [];

  // Örnek hafta günleri
  final List<DateTime> _weekDays = List.generate(
    5,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadClasses(); // Firebase'den dersleri yükle
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Firebase'den dersleri yükleme fonksiyonu
  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Firestore'dan dersleri çek
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .orderBy('day')
          .orderBy('startTime')
          .get();

      // Verileri işle ve _classes listesine ekle
      final List<Map<String, dynamic>> loadedClasses = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'startTime': data['startTime'] ?? '',
          'endTime': data['endTime'] ?? '',
          'trainer': data['trainer'] ?? '',
          'capacity': data['capacity'] ?? 0,
          'enrolled': data['enrolled'] ?? 0,
          'day': data['day'] ?? '',
          // Diğer alanlar...
        };
      }).toList();

      // State'i güncelle
      setState(() {
        _classes = loadedClasses;
        _isLoading = false;
      });

      print('Loaded ${_classes.length} classes from Firestore');
    } catch (e) {
      print('Error loading classes: $e');
      setState(() {
        _errorMessage = 'Dersler yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Classes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Classes'),
            Tab(text: 'My Reservations'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadClasses,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllClassesTab(),
                    _buildMyReservationsTab(),
                    _buildFavoritesTab(),
                  ],
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
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  // Tüm dersler sekmesi
  Widget _buildAllClassesTab() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: _classes.isEmpty
              ? const Center(child: Text('Henüz ders bulunmuyor.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    return _buildClassCard(_classes[index]);
                  },
                ),
        ),
      ],
    );
  }

  // Rezervasyonlar sekmesi
  Widget _buildMyReservationsTab() {
    final reservedClasses =
        _classes.where((c) => c['id'] == '1' || c['id'] == '3').toList();

    return reservedClasses.isEmpty
        ? const Center(child: Text('Henüz rezervasyon yapmadınız.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservedClasses.length,
            itemBuilder: (context, index) {
              final classInfo =
                  Map<String, dynamic>.from(reservedClasses[index]);
              classInfo['isReserved'] = true;
              return _buildClassCard(classInfo);
            },
          );
  }

  // Favoriler sekmesi
  Widget _buildFavoritesTab() {
    final favoriteClasses =
        _classes.where((c) => c['id'] == '2' || c['id'] == '5').toList();

    return favoriteClasses.isEmpty
        ? const Center(child: Text('Henüz favori ders eklemediniz.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteClasses.length,
            itemBuilder: (context, index) {
              final classInfo =
                  Map<String, dynamic>.from(favoriteClasses[index]);
              classInfo['isFavorite'] = true;
              return _buildClassCard(classInfo);
            },
          );
  }

  // Tarih seçici
  Widget _buildDateSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final day = _weekDays[index];
          final isSelected = index == _selectedDayIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(left: 16),
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

  // Ders kartı
  Widget _buildClassCard(Map<String, dynamic> classInfo) {
    final bool isReserved = classInfo['isReserved'] ?? false;
    final bool isFavorite = classInfo['isFavorite'] ?? false;

    // Doluluk oranı
    final int capacity = classInfo['capacity'] ?? 0;
    final int enrolled = classInfo['enrolled'] ?? 0;
    final double occupancyRate = capacity > 0 ? enrolled / capacity : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/class-detail',
            arguments: classInfo,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    classInfo['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          // Favori ekle/çıkar
                        },
                      ),
                      Text(
                        '${classInfo['startTime']} - ${classInfo['endTime']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Trainer: ${classInfo['trainer']}'),
              const SizedBox(height: 8),
              Text('Day: ${classInfo['day']}'),
              const SizedBox(height: 12),

              // Doluluk göstergesi
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: occupancyRate,
                        backgroundColor: Colors.grey.shade200,
                        color: occupancyRate > 0.8
                            ? Colors.red
                            : (occupancyRate > 0.5
                                ? Colors.orange
                                : Colors.green),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Occupancy ${(occupancyRate * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rezervasyon/İptal düğmesi
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isReserved)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // İptal işlemi
                      },
                      child: const Text('Cancel'),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Rezervasyon yap
                        Navigator.pushNamed(
                          context,
                          '/reservations',
                          arguments: classInfo,
                        );
                      },
                      child: const Text('Reserve'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
