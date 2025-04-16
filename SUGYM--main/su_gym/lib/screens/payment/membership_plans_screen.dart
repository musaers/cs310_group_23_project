// lib/screens/payment/membership_plans_screen.dart
import 'package:flutter/material.dart';

class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  _MembershipPlansScreenState createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  // Seçilen planın indeksi
  int _selectedPlanIndex = -1;
  
  // Örnek üyelik planları
  final List<Map<String, dynamic>> _plans = [
    {
      'id': '1',
      'name': 'Premium',
      'description': 'Tüm özelliklere sınırsız erişim',
      'durations': [
        {'months': 1, 'price': 2900},
        {'months': 6, 'price': 2700},
        {'months': 12, 'price': 2500},
      ],
      'features': [
        'Tüm spor salonlarına erişim',
        'Tüm derslere erişim',
        'Kişisel antrenör (ayda 2 seans)',
        'Beslenme danışmanlığı',
        'Dolap dahil',
      ],
      'color': Colors.blue,
    },
    {
      'id': '2',
      'name': 'Platinum',
      'description': 'Lüks ve konfor için en iyi seçenek',
      'durations': [
        {'months': 1, 'price': 5000},
        {'months': 6, 'price': 4700},
        {'months': 12, 'price': 4500},
      ],
      'features': [
        'Premium özellikleri +',
        'Sınırsız kişisel antrenör seansları',
        'Özel dolap',
        'Havlu hizmeti',
        'Spa erişimi',
      ],
      'color': Colors.purple,
    },
    {
      'id': '3',
      'name': 'Student',
      'description': 'Öğrenciler için özel indirimli fiyatlar',
      'durations': [
        {'months': 1, 'price': 2200},
        {'months': 6, 'price': 2000},
        {'months': 12, 'price': 1800},
      ],
      'features': [
        'Geçerli öğrenci kimliği gereklidir',
        'Tüm spor salonlarına erişim',
        'Derslere erişim (sınırlı kontenjan)',
        'Kişisel antrenör seansı yok',
      ],
      'color': Colors.teal,
    },
    {
      'id': '4',
      'name': 'Family',
      'description': 'Aileniz için özel paket (kişi başı fiyat)',
      'durations': [
        {'months': 1, 'price': 2200},
        {'months': 6, 'price': 2100},
        {'months': 12, 'price': 2000},
      ],
      'features': [
        'Minimum 2 aile üyesi',
        'Aynı adres gerekli',
        'Tüm spor salonlarına erişim',
        'Tüm derslere erişim',
        'Paylaşımlı kişisel antrenör (ayda 2 seans)',
      ],
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Membership Plans',
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
              const Text(
                'Choose your plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the membership plan that works best for you.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              
              // Üyelik planları listesi
              ...List.generate(
                _plans.length,
                (index) => _buildPlanCard(context, _plans[index], index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Plan kartı widget'ı
  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? plan['color'] : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? plan['color'].withOpacity(0.3) 
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan başlığı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: plan['color'],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    plan['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan['description'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Plan detayları
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Süre ve fiyat seçenekleri
                  ..._buildDurationOptions(plan['durations']),
                  const SizedBox(height: 16),
                  
                  // Özellikler başlığı
                  const Text(
                    'Features:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Özellikler listesi
                  ...plan['features'].map<Widget>((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: plan['color'],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(feature),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 20),
                  
                  // Satın al düğmesi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: plan['color'],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showPaymentDialog(context, plan),
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  // Süre ve fiyat seçenekleri
  List<Widget> _buildDurationOptions(List<dynamic> durations) {
    return durations.map<Widget>((duration) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration: ${duration['months']} ${duration['months'] == 1 ? 'Month' : 'Months'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Price: ${duration['price']} TL',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Ödeme onay iletişim kutusu
  void _showPaymentDialog(BuildContext context, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase ${plan['name']} Plan?'),
        content: const Text(
          'You will be directed to payment. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: plan['color'],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Ödeme işlemine yönlendir (Bu örnekte sadece geri dön)
              Navigator.pop(context);
              _showSuccessMessage(context, plan);
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  // Başarı mesajı
  void _showSuccessMessage(BuildContext context, Map<String, dynamic> plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plan['name']} plan purchased successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // İsteğe bağlı: Profil sayfasına dön
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, '/profile');
    });
  }
}
