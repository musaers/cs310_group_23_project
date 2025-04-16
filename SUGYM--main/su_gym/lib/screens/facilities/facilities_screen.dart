// lib/screens/facilities/facilities_screen.dart
import 'package:flutter/material.dart';

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tesis özellikleri ve doluluk oranları
    final Map<String, double> facilityOccupancy = {
      'Fitness': 0.76,
      'Yoga': 0.22,
      'Sauna': 0.84,
    };
    
    // Çalışma saatleri
    final Map<String, String> workingHours = {
      'Weekdays': '06:00 - 23:00',
      'Weekends': '08:00 - 22:00',
    };
    
    // Örnek ekipman listesi
    final List<Map<String, dynamic>> equipment = [
      {'name': 'Treadmill', 'count': 15, 'available': 10},
      {'name': 'Stationary Bike', 'count': 10, 'available': 8},
      {'name': 'Elliptical', 'count': 8, 'available': 5},
      {'name': 'Rowing Machine', 'count': 5, 'available': 3},
      {'name': 'Smith Machine', 'count': 3, 'available': 2},
      {'name': 'Cable Machine', 'count': 4, 'available': 4},
      {'name': 'Bench Press', 'count': 6, 'available': 3},
      {'name': 'Dumbbells', 'count': 20, 'available': 20},
      {'name': 'Kettlebells', 'count': 15, 'available': 15},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Facilities',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tesis durumu kartı
              _buildFacilityStatusCard(facilityOccupancy),
              const SizedBox(height: 24),
              
              // Çalışma saatleri kartı
              _buildWorkingHoursCard(workingHours),
              const SizedBox(height: 24),
              
              // Ekipmanlar bölümü
              const Text(
                'Equipment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Ekipman listesi
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: equipment.length,
                itemBuilder: (context, index) {
                  return _buildEquipmentItem(equipment[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tesis durumu kartı
  Widget _buildFacilityStatusCard(Map<String, double> facilityOccupancy) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Facility Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Her bir özelliğin doluluk göstergesi
            ...facilityOccupancy.entries.map((entry) {
              final String facility = entry.key;
              final double occupancy = entry.value;
              final Color barColor = occupancy > 0.8 
                  ? Colors.red 
                  : (occupancy > 0.5 ? Colors.orange : Colors.green);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        facility,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${(occupancy * 100).toInt()}%',
                        style: TextStyle(
                          color: barColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: occupancy,
                      backgroundColor: Colors.grey.shade200,
                      color: barColor,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Çalışma saatleri kartı
  Widget _buildWorkingHoursCard(Map<String, String> workingHours) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Working Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Çalışma saatleri bilgileri
            ...workingHours.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Ekipman öğesi
  Widget _buildEquipmentItem(Map<String, dynamic> equipment) {
    final double availability = equipment['available'] / equipment['count'];
    final Color availabilityColor = availability > 0.8 
        ? Colors.green 
        : (availability > 0.5 ? Colors.orange : Colors.red);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          equipment['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('Total: ${equipment['count']}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: availabilityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: availabilityColor),
          ),
          child: Text(
            'Available: ${equipment['available']}',
            style: TextStyle(
              color: availabilityColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
