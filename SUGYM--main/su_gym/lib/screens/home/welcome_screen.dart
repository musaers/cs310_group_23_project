// lib/screens/home/welcome_screen.dart
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo ve başlık
              const Text(
                'SUGYM+',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Karşılama metni
              Text(
                'Hi, welcome back, ${_getUserName()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              
              // Ana menü butonları
              _buildMenuButton(
                context,
                'Classes',
                () => Navigator.pushNamed(context, '/classes'),
                Icons.fitness_center,
              ),
              const SizedBox(height: 15),
              
              _buildMenuButton(
                context,
                'Reservations',
                () => Navigator.pushNamed(context, '/reservations'),
                Icons.calendar_today,
              ),
              const SizedBox(height: 15),
              
              _buildMenuButton(
                context,
                'User Profile',
                () => Navigator.pushNamed(context, '/profile'),
                Icons.person,
              ),
              const SizedBox(height: 15),
              
              _buildMenuButton(
                context,
                'Leaderboard',
                () => Navigator.pushNamed(context, '/leaderboard'),
                Icons.leaderboard,
              ),
              const SizedBox(height: 15),
              
              _buildMenuButton(
                context,
                'Payments',
                () => Navigator.pushNamed(context, '/payment'),
                Icons.payment,
              ),
              const SizedBox(height: 15),
              
              _buildMenuButton(
                context,
                'Feedback',
                () => Navigator.pushNamed(context, '/feedback'),
                Icons.feedback,
              ),
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

  Widget _buildMenuButton(
    BuildContext context, 
    String title, 
    VoidCallback onPressed, 
    IconData icon,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Kullanıcı adını almak için yardımcı fonksiyon (gerçek uygulamada bu veri depolama veya API'dan gelir)
  String _getUserName() {
    // Örnek kullanıcı adı
    return 'User';
  }
}
