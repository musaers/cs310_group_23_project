// lib/screens/feedback/feedback_screen.dart
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  
  double _classRating = 4.0;
  double _trainerRating = 4.0;
  double _facilityRating = 4.0;
  double _overallRating = 4.0;
  String? _selectedClass;
  
  // Örnek ders listesi
  final List<String> _classes = [
    'Full Body',
    'Pilates',
    'Yoga',
    'Cycling',
    'Zumba',
    'HIIT',
    'CrossFit',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                const Text(
                  'Rate us',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us what you think about our services. Your feedback is valuable to us!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Ders seçimi
                const Text(
                  'Select a class (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  hint: const Text('Select a class'),
                  value: _selectedClass,
                  items: _classes.map((className) {
                    return DropdownMenuItem<String>(
                      value: className,
                      child: Text(className),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                // Derecelendirmeler
                _buildRatingSection('Class Rating', _classRating, (rating) {
                  setState(() {
                    _classRating = rating;
                  });
                }),
                
                _buildRatingSection('Trainer Rating', _trainerRating, (rating) {
                  setState(() {
                    _trainerRating = rating;
                  });
                }),
                
                _buildRatingSection('Facility Rating', _facilityRating, (rating) {
                  setState(() {
                    _facilityRating = rating;
                  });
                }),
                
                _buildRatingSection('Overall Experience', _overallRating, (rating) {
                  setState(() {
                    _overallRating = rating;
                  });
                }),
                
                const SizedBox(height: 24),
                
                // Geri bildirim metni
                const Text(
                  'Your thoughts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feedbackController,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience with us...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Gönder düğmesi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitFeedback,
                    child: const Text(
                      'Submit Feedback',
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
        ),
      ),
    );
  }

  // Derecelendirme bölümü widget'ı
  Widget _buildRatingSection(String title, double rating, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Slider(
                value: rating,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                label: rating.toString(),
                onChanged: onChanged,
                activeColor: Colors.blue,
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  rating.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Geri bildirim gönderme fonksiyonu
  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      // Geri bildirim gönderme işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Ana sayfaya dön
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
