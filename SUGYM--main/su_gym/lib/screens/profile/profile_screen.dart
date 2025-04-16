// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Örnek kullanıcı bilgileri
  final Map<String, dynamic> _userProfile = {
    'name': 'Bryce',
    'surname': 'Mitchell',
    'email': 'thugNasty@ufc.com',
    'plan': 'Premium',
    'startDate': '19/03/2025',
    'endDate': '19/03/2026',
    'status': 'Active',
    'currentWeight': 68,
    'startingWeight': 75,
    'targetWeight': 61,
    'weeklyVisits': 3,
    'monthlyVisits': 12,
    'mostReservedClass': 'Yoga',
    'progress': 0.5, // %50
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Ayarlar ekranına git
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil başlık bölümü
            _buildProfileHeader(),

            // Ana içerik
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üyelik bilgileri bölümü
                  _buildSectionCard(
                    title: 'Membership Details',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'Plan',
                          _userProfile['plan'],
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              'Status: ${_userProfile['status']}',
                              style: GoogleFonts.ubuntu(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        _buildInfoRow('Start Date', _userProfile['startDate']),
                        _buildInfoRow('End Date', _userProfile['endDate']),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/membership-plans');
                          },
                          child: Text(
                            'Change Plan',
                            style: GoogleFonts.ubuntu(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // İlerleme bilgileri bölümü
                  _buildSectionCard(
                    title: 'Progress',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeightInfo(
                              'Current',
                              _userProfile['currentWeight'],
                            ),
                            _buildWeightInfo(
                              'Starting',
                              _userProfile['startingWeight'],
                            ),
                            _buildWeightInfo(
                              'Target',
                              _userProfile['targetWeight'],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Progress:', style: GoogleFonts.ubuntu()),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _userProfile['progress'],
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.green,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(_userProfile['progress'] * 100).toInt()}%',
                            style: GoogleFonts.ubuntu(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // İstatistikler bölümü
                  _buildSectionCard(
                    title: 'Statistics',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'This week',
                          '${_userProfile['weeklyVisits']} visits',
                        ),
                        _buildInfoRow(
                          'This month',
                          '${_userProfile['monthlyVisits']} visits',
                        ),
                        _buildInfoRow(
                          'Most reservation',
                          _userProfile['mostReservedClass'],
                        ),
                      ],
                    ),
                  ),

                  // Aktiviteler bölümü
                  _buildSectionCard(
                    title: 'Activities',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActivityButton(
                          icon: Icons.history,
                          label: 'Training History',
                          onPressed: () {
                            // Antrenman geçmişi sayfasına git
                          },
                        ),
                        _buildActivityButton(
                          icon: Icons.leaderboard,
                          label: 'Leaderboard',
                          onPressed: () {
                            Navigator.pushNamed(context, '/leaderboard');
                          },
                        ),
                        _buildActivityButton(
                          icon: Icons.payment,
                          label: 'Payments',
                          onPressed: () {
                            Navigator.pushNamed(context, '/payment');
                          },
                        ),
                        _buildActivityButton(
                          icon: Icons.feedback,
                          label: 'Feedback',
                          onPressed: () {
                            Navigator.pushNamed(context, '/feedback');
                          },
                        ),
                      ],
                    ),
                  ),

                  // Profil işlemleri bölümü
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/edit-profile');
                            },
                            child: Text(
                              'Edit Profile',
                              style: GoogleFonts.ubuntu(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () {
                              // Çıkış yap
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.ubuntu(
                                color: Colors.red,
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Classes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/classes');
          }
        },
      ),
    );
  }

  // Profil başlık bölümü
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Avatar - NetworkImage kullanarak URL'den fotoğraf
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://media.cnn.com/api/v1/images/stellar/prod/gettyimages-2188806038.jpg?c=original',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kullanıcı adı ve e-posta
          Text(
            '${_userProfile['name']} ${_userProfile['surname']}',
            style: GoogleFonts.ubuntu(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile['email'],
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Bölüm kartı widget'ı
  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),

          // İçerik
          Padding(padding: const EdgeInsets.all(16), child: content),
        ],
      ),
    );
  }

  // Bilgi satırı widget'ı
  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          trailing ??
              Text(
                value,
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
    );
  }

  // Ağırlık bilgisi widget'ı
  Widget _buildWeightInfo(String label, int weight) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.ubuntu(color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$weight kg',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Aktivite butonu widget'ı
  Widget _buildActivityButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
