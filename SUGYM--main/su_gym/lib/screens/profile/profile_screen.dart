// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Kullanıcı bilgileri
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Kullanıcı verilerini Firestore'dan yükle
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('User profile not found');
      }

      setState(() {
        _userData = docSnapshot.data();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  // Çıkış yap
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _userData == null
                  ? _buildEmptyProfileView()
                  : _buildProfileContent(),
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

  // Hata görünümü
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: Text(
                'Try Again',
                style: GoogleFonts.ubuntu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Boş profil görünümü
  Widget _buildEmptyProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Profile not available',
            style: GoogleFonts.ubuntu(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please log in to view your profile',
            style: GoogleFonts.ubuntu(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Log In',
              style: GoogleFonts.ubuntu(),
            ),
          ),
        ],
      ),
    );
  }

  // Profil içeriği
  Widget _buildProfileContent() {
    // Üyelik bilgileri
    final membership = _userData!['membership'] as Map<String, dynamic>?;
    final isActiveMembership = membership != null &&
        membership['status'] == 'Active' &&
        membership['plan'] != null;

    // Fitness bilgileri
    final fitness = _userData!['fitness'] as Map<String, dynamic>?;

    // İstatistik bilgileri
    final statistics = _userData!['statistics'] as Map<String, dynamic>?;

    // Tarih formatı
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    // Üyelik bitiş tarihi
    DateTime? endDate;
    if (isActiveMembership && membership!['endDate'] != null) {
      endDate = (membership['endDate'] as Timestamp).toDate();
    }

    // Doğum tarihi
    DateTime? dateOfBirth;
    if (_userData!['dateOfBirth'] != null) {
      dateOfBirth = (_userData!['dateOfBirth'] as Timestamp).toDate();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil üst bölümü
          _buildProfileHeader(dateOfBirth),

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
                        isActiveMembership ? membership!['plan'] : 'None',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActiveMembership
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isActiveMembership
                                    ? Colors.green
                                    : Colors.grey),
                          ),
                          child: Text(
                            'Status: ${isActiveMembership ? 'Active' : 'Inactive'}',
                            style: GoogleFonts.ubuntu(
                              color: isActiveMembership
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (isActiveMembership) ...[
                        _buildInfoRow(
                            'Start Date',
                            membership!['startDate'] != null
                                ? dateFormat.format(
                                    (membership['startDate'] as Timestamp)
                                        .toDate())
                                : 'N/A'),
                        _buildInfoRow(
                            'End Date',
                            endDate != null
                                ? dateFormat.format(endDate)
                                : 'N/A'),
                        if (endDate != null)
                          _buildInfoRow('Days Remaining',
                              '${endDate.difference(DateTime.now()).inDays} days'),
                      ],
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
                          isActiveMembership ? 'Renew Plan' : 'Get Membership',
                          style: GoogleFonts.ubuntu(),
                        ),
                      ),
                    ],
                  ),
                ),

                // İlerleme bilgileri bölümü
                if (fitness != null)
                  _buildSectionCard(
                    title: 'Fitness Progress',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeightInfo(
                              'Current',
                              fitness['currentWeight'],
                            ),
                            _buildWeightInfo(
                              'Starting',
                              fitness['startingWeight'],
                            ),
                            _buildWeightInfo(
                              'Target',
                              fitness['targetWeight'],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Progress:', style: GoogleFonts.ubuntu()),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value:
                              (fitness['progress'] as num?)?.toDouble() ?? 0.0,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.green,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(((fitness['progress'] as num?)?.toDouble() ?? 0.0) * 100).toInt()}%',
                            style: GoogleFonts.ubuntu(),
                          ),
                        ),
                      ],
                    ),
                  ),

                // İstatistikler bölümü
                if (statistics != null)
                  _buildSectionCard(
                    title: 'Statistics',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'This week',
                          '${statistics['weeklyVisits'] ?? 0} visits',
                        ),
                        _buildInfoRow(
                          'This month',
                          '${statistics['monthlyVisits'] ?? 0} visits',
                        ),
                        _buildInfoRow(
                          'Total visits',
                          '${statistics['totalVisits'] ?? 0}',
                        ),
                        _buildInfoRow(
                          'Most reservation',
                          statistics['mostAttendedClass'] ?? 'None',
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
                          onPressed: _signOut,
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
    );
  }

  // Profil başlık bölümü
  Widget _buildProfileHeader(DateTime? dateOfBirth) {
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
          // Avatar
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
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Kullanıcı adı ve e-posta
          Text(
            _userData!['username'] ?? 'User',
            style: GoogleFonts.ubuntu(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData!['email'] ?? '',
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          if (dateOfBirth != null) ...[
            const SizedBox(height: 4),
            Text(
              'Born: ${DateFormat('dd/MM/yyyy').format(dateOfBirth)}',
              style: GoogleFonts.ubuntu(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
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
  Widget _buildWeightInfo(String label, dynamic weight) {
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
            weight != null ? '$weight kg' : '-- kg',
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
