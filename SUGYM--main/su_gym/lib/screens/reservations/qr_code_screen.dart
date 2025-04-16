// lib/screens/reservations/qr_code_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek QR kod verisi (gerçek uygulamada kullanıcı kimliği ve rezervasyon bilgileri içerebilir)
    final String qrData = _generateRandomQRData();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Başlık
            const Text(
              'SUGYM+',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            
            // Bilgilendirme metni
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Show this QR code at the reception to check in for your reserved classes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // QR kod gösterimi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                errorStateBuilder: (context, error) {
                  return const Center(
                    child: Text(
                      'Something went wrong!',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                embeddedImage: const AssetImage('assets/logo.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(40, 40),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Kullanıcı bilgileri
            const Text(
              'User: John Doe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Membership: Premium',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Valid until: ${_getFormattedDate()}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            
            // Alt kısım
            Container(
              padding: const EdgeInsets.all(16),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back to Reservations',
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
    );
  }

  // Örnek QR kodu için rastgele veri oluştur
  String _generateRandomQRData() {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random rnd = Random();
    final String randomString = String.fromCharCodes(
      Iterable.generate(
        20,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
    
    return 'SUGYM_USER_123456_$randomString';
  }

  // Örnek tarih formatı
  String _getFormattedDate() {
    final DateTime now = DateTime.now();
    final DateTime validUntil = now.add(const Duration(days: 365));
    
    final String day = validUntil.day.toString().padLeft(2, '0');
    final String month = validUntil.month.toString().padLeft(2, '0');
    final String year = validUntil.year.toString();
    
    return '$day/$month/$year';
  }
}