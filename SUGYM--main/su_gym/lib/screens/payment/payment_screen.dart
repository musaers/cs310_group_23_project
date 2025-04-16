// lib/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek üyelik planları
    final List<Map<String, dynamic>> membershipPlans = [
      {
        'id': '1',
        'name': 'Premium',
        'durations': [
          {'months': 1, 'price': 2900},
          {'months': 6, 'price': 2700},
          {'months': 12, 'price': 2500},
        ],
        'features': [
          'Access to all gym facilities',
          'Access to all classes',
          'Personal trainer (2 sessions per month)',
          'Nutrition consulting',
          'Locker included',
        ],
        'color': Colors.blue,
      },
      {
        'id': '2',
        'name': 'Platinum',
        'durations': [
          {'months': 1, 'price': 5000},
          {'months': 6, 'price': 4700},
          {'months': 12, 'price': 4500},
        ],
        'features': [
          'Premium features +',
          'Unlimited personal trainer sessions',
          'Private locker',
          'Towel service',
          'Spa access',
        ],
        'color': Colors.purple,
      },
      {
        'id': '3',
        'name': 'Student',
        'durations': [
          {'months': 1, 'price': 2200},
          {'months': 6, 'price': 2000},
          {'months': 12, 'price': 1800},
        ],
        'features': [
          'Valid student ID required',
          'Access to all gym facilities',
          'Access to all classes (limited spots)',
          'No personal trainer sessions',
        ],
        'color': Colors.teal,
      },
      {
        'id': '4',
        'name': 'Family (per person)',
        'durations': [
          {'months': 1, 'price': 2200},
          {'months': 6, 'price': 2100},
          {'months': 12, 'price': 2000},
        ],
        'features': [
          'Minimum 2 family members',
          'Same household required',
          'Access to all gym facilities',
          'Access to all classes',
          'Shared personal trainer (2 sessions per month)',
        ],
        'color': Colors.green,
      },
    ];

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
              ...membershipPlans.map((plan) => _buildPlanCard(context, plan)),
            ],
          ),
        ),
      ),
    );
  }

  // Üyelik plan kartı
  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Plan başlığı
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: plan['color'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              plan['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Plan içeriği
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Süre ve fiyat seçenekleri
                ..._buildDurationPriceOptions(plan['durations']),
                const SizedBox(height: 24),
                
                // Özellikler başlığı
                const Text(
                  'Features:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Özellikler listesi
                ...plan['features'].map<Widget>((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(feature),
                      ),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 24),
                
                // Satın alma düğmesi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: plan['color'],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _showPaymentConfirmation(context, plan);
                    },
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
    );
  }

  // Süre ve fiyat seçenekleri
  List<Widget> _buildDurationPriceOptions(List<dynamic> durations) {
    return durations.map<Widget>((duration) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Duration: ${duration['months']} ${duration['months'] == 1 ? 'Month' : 'Months'}',
              style: const TextStyle(
                fontSize: 16,
              ),
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
  void _showPaymentConfirmation(BuildContext context, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscribe to ${plan['name']}?'),
        content: const Text(
          'You will be directed to payment. Would you like to continue?',
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
              // Ödeme sayfasına yönlendir (Bu örnekte sadece geri dön)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${plan['name']} plan purchased successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}
