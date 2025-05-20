// lib/screens/profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controller'lar
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  // Doğum tarihi seçici için
  DateTime? _selectedDateOfBirth;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
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

      final userData = docSnapshot.data() as Map<String, dynamic>;

      // Form alanlarını mevcut değerlerle doldur
      setState(() {
        _nameController.text = userData['username'] ?? '';
        _emailController.text = userData['email'] ?? '';

        // Doğum tarihi
        if (userData['dateOfBirth'] != null) {
          _selectedDateOfBirth =
              (userData['dateOfBirth'] as Timestamp).toDate();
        }

        // Fitness bilgileri
        if (userData['fitness'] != null &&
            userData['fitness'] is Map<String, dynamic>) {
          final fitness = userData['fitness'] as Map<String, dynamic>;
          if (fitness['currentWeight'] != null) {
            _currentWeightController.text = fitness['currentWeight'].toString();
          }
          if (fitness['targetWeight'] != null) {
            _targetWeightController.text = fitness['targetWeight'].toString();
          }
        }

        _isLoading = false;
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  // Formda değişiklik yapıldığında çağrılır
  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  // Doğum tarihi seçici
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  // Profil güncelleme
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Önce mevcut kullanıcı verilerini al
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData =
          docSnapshot.exists ? docSnapshot.data() as Map<String, dynamic> : {};

      // Fitness verileri
      Map<String, dynamic> fitnessData = {};
      if (userData.containsKey('fitness') && userData['fitness'] is Map) {
        fitnessData = Map<String, dynamic>.from(userData['fitness'] as Map);
      }

      // Güncel kilo ve hedef kilo güncelleme
      if (_currentWeightController.text.isNotEmpty) {
        final currentWeight = int.tryParse(_currentWeightController.text);
        if (currentWeight != null) {
          fitnessData['currentWeight'] = currentWeight;
        }
      }

      if (_targetWeightController.text.isNotEmpty) {
        final targetWeight = int.tryParse(_targetWeightController.text);
        if (targetWeight != null) {
          fitnessData['targetWeight'] = targetWeight;
        }
      }

      // Başlangıç kilosu belirtilmemiş ise, güncel kiloyu başlangıç kilosu olarak ata
      if (!fitnessData.containsKey('startingWeight') &&
          fitnessData.containsKey('currentWeight') &&
          fitnessData['currentWeight'] != null) {
        fitnessData['startingWeight'] = fitnessData['currentWeight'];
      }

      // İlerleme hesapla - tüm gerekli değerlerin var ve null olmadığından emin ol
      if (fitnessData.containsKey('startingWeight') &&
          fitnessData.containsKey('targetWeight') &&
          fitnessData.containsKey('currentWeight') &&
          fitnessData['startingWeight'] != null &&
          fitnessData['targetWeight'] != null &&
          fitnessData['currentWeight'] != null) {
        final startingWeight = fitnessData['startingWeight'] as int;
        final targetWeight = fitnessData['targetWeight'] as int;
        final currentWeight = fitnessData['currentWeight'] as int;

        // Eğer hedef kilo, başlangıç kilosundan küçükse (kilo vermek istiyorsa)
        if (targetWeight < startingWeight) {
          final totalLoss = startingWeight - targetWeight;
          final currentLoss = startingWeight - currentWeight;

          // İlerleme oranı (0.0 - 1.0 arası)
          final progress =
              totalLoss > 0 ? (currentLoss / totalLoss).clamp(0.0, 1.0) : 0.0;
          fitnessData['progress'] = progress;
        }
        // Eğer hedef kilo, başlangıç kilosundan büyükse (kilo almak istiyorsa)
        else if (targetWeight > startingWeight) {
          final totalGain = targetWeight - startingWeight;
          final currentGain = currentWeight - startingWeight;

          // İlerleme oranı (0.0 - 1.0 arası)
          final progress =
              totalGain > 0 ? (currentGain / totalGain).clamp(0.0, 1.0) : 0.0;
          fitnessData['progress'] = progress;
        }
        // Hedef ve başlangıç aynıysa, ilerleme %100
        else {
          fitnessData['progress'] = 1.0;
        }
      }

      // Veritabanı güncelleme
      Map<String, dynamic> updateData = {
        'username': _nameController.text,
        'updatedAt': FieldValue.serverTimestamp(),
        'fitness': fitnessData,
      };

      // Doğum tarihi sadece seçilmişse ekle
      if (_selectedDateOfBirth != null) {
        updateData['dateOfBirth'] = _selectedDateOfBirth;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      // E-posta güncelleme - sadece Firebase Auth'da yapılır ve değişiklik varsa
      if (_emailController.text.isNotEmpty &&
          _emailController.text != user.email) {
        await user.updateEmail(_emailController.text);
      }

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

      // Profil sayfasına dön
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Çıkış onay dialogu
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unsaved Changes',
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: GoogleFonts.ubuntu(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No, Keep Editing',
              style: GoogleFonts.ubuntu(),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, Discard',
              style: GoogleFonts.ubuntu(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? _buildErrorView()
                : _buildEditForm(),
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

  // Düzenleme formu
  Widget _buildEditForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _onFormChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil resmi
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Fotoğraf seçme işlemi - İleri aşamada eklenebilir
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Photo upload feature coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Kişisel bilgiler bölümü
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),

              // Kullanıcı adı
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // E-posta
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Doğum tarihi
              InkWell(
                onTap: () => _selectDateOfBirth(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDateOfBirth != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
                        : 'Select Date',
                    style: GoogleFonts.ubuntu(),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Fitness bilgileri bölümü
              _buildSectionTitle('Fitness Information'),
              const SizedBox(height: 16),

              // Mevcut kilo
              TextFormField(
                controller: _currentWeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Weight (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final weightValue = int.tryParse(value);
                    if (weightValue == null || weightValue <= 0) {
                      return 'Please enter a valid weight';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Hedef kilo
              TextFormField(
                controller: _targetWeightController,
                decoration: const InputDecoration(
                  labelText: 'Target Weight (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final weightValue = int.tryParse(value);
                    if (weightValue == null || weightValue <= 0) {
                      return 'Please enter a valid weight';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Güvenlik bölümü
              _buildSectionTitle('Security'),
              const SizedBox(height: 16),

              // Şifre değiştirme
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Şifre sıfırlama e-postası gönder
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && user.email != null) {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: user.email!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.lock),
                label: const Text('Change Password'),
              ),
              const SizedBox(height: 40),

              // Kaydet düğmesi
              SizedBox(
                width: double.infinity,
                child: _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _updateProfile,
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.ubuntu(
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
    );
  }

  // Bölüm başlığı widget'ı
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.ubuntu(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
