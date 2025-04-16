// lib/screens/classes/class_detail_screen.dart
import 'package:flutter/material.dart';

class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sınıf bilgilerini al (normal durumda Navigator ile geçilir)
    final Map<String, dynamic> classInfo = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {
      'id': '1',
      'name': 'Full Body',
      'startTime': '10:00',
      'endTime': '10:45',
      'day': 'Monday',
      'trainer': 'John Doe',
      'capacity': 20,
      'enrolled': 15,
      'description': 'This full-body workout targets all major muscle groups with a combination of strength training and cardio exercises. Suitable for all fitness levels with modifications provided.',
      'equipment': ['Dumbbells', 'Resistance bands', 'Exercise mat'],
      'intensity': 'Medium',
      'calories': '300-500',
      'location': 'Studio A',
    };

    // Doluluk oranı
    final double occupancyRate = classInfo['enrolled'] / classInfo['capacity'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          classInfo['name'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ders resmi (gerçek uygulamada bu bir resim olacaktır)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.blue.shade100,
              child: Center(
                child: Icon(
                  _getClassIcon(classInfo['name']),
                  size: 80,
                  color: Colors.blue,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve zaman bilgisi
                  Text(
                    classInfo['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${classInfo['day']} ${classInfo['startTime']} - ${classInfo['endTime']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Eğitmen bilgisi
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Trainer: ${classInfo['trainer']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Konum bilgisi
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Location: ${classInfo['location']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Doluluk oranı
                  const Text(
                    'Occupancy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                              : (occupancyRate > 0.5 ? Colors.orange : Colors.green),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${classInfo['enrolled']}/${classInfo['capacity']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Açıklama
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    classInfo['description'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Dersin detayları
                  const Text(
                    'Class Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          'Intensity',
                          classInfo['intensity'],
                          Icons.speed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailCard(
                          'Calories',
                          classInfo['calories'],
                          Icons.whatshot,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Gerekli ekipmanlar
                  const Text(
                    'Required Equipment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (classInfo['equipment'] as List<String>).map((equipment) {
                      return Chip(
                        avatar: const Icon(Icons.fitness_center, size: 16),
                        label: Text(equipment),
                        backgroundColor: Colors.blue.shade50,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  
                  // Rezervasyon butonu
                  SizedBox(
                    width: double.infinity,
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
                        Navigator.pushNamed(
                          context,
                          '/reservations',
                          arguments: classInfo,
                        );
                      },
                      child: const Text(
                        'Reserve',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Geri dönüş butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Back to Classes',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Detay kartı widget'ı
  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Ders tipine göre simge seçme
  IconData _getClassIcon(String className) {
    switch (className.toLowerCase()) {
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.accessibility_new;
      case 'cycling':
        return Icons.directions_bike;
      case 'zumba':
        return Icons.music_note;
      case 'hiit':
        return Icons.flash_on;
      default:
        return Icons.fitness_center;
    }
  }
}
