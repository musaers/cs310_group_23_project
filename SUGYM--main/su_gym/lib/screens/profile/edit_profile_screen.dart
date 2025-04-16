// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers for form fields
  final TextEditingController _nameController = TextEditingController(text: 'Username');
  final TextEditingController _surnameController = TextEditingController(text: 'Surname');
  final TextEditingController _emailController = TextEditingController(text: 'user.example@gmail.com');
  final TextEditingController _currentWeightController = TextEditingController(text: '68');
  final TextEditingController _targetWeightController = TextEditingController(text: '61');
  
  bool _isLoading = false;
  bool _changesMade = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  // Form değişiklik kontrolü
  void _onFormChanged() {
    setState(() {
      _changesMade = true;
    });
  }

  // Profil güncelleme
  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simüle edilmiş profil güncelleme
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Profil sayfasına dön
        Navigator.pop(context);
      });
    }
  }

  // Çıkış onay iletişim kutusu
  Future<bool> _onWillPop() async {
    if (!_changesMade) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değişiklikler Kaydedilmedi'),
        content: const Text('Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hayır, Devam Et'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, Çık'),
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
          title: const Text(
            'Profili Düzenle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
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
                                // Fotoğraf seçme işlemi
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Kişisel bilgiler bölümü
                  _buildSectionTitle('Kişisel Bilgiler'),
                  const SizedBox(height: 16),
                  
                  // İsim
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'İsim',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen isim giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Soyisim
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(
                      labelText: 'Soyisim',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen soyisim giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // E-posta
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen e-posta giriniz';
                      }
                      
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Geçerli bir e-posta adresi giriniz';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Fitness bilgileri bölümü
                  _buildSectionTitle('Fitness Bilgileri'),
                  const SizedBox(height: 16),
                  
                  // Mevcut kilo
                  TextFormField(
                    controller: _currentWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Mevcut Kilo (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen mevcut kilonuzu giriniz';
                      }
                      
                      final weightValue = int.tryParse(value);
                      if (weightValue == null || weightValue <= 0) {
                        return 'Geçerli bir kilo değeri giriniz';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Hedef kilo
                  TextFormField(
                    controller: _targetWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Hedef Kilo (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen hedef kilonuzu giriniz';
                      }
                      
                      final weightValue = int.tryParse(value);
                      if (weightValue == null || weightValue <= 0) {
                        return 'Geçerli bir kilo değeri giriniz';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Güvenlik bölümü
                  _buildSectionTitle('Güvenlik'),
                  const SizedBox(height: 16),
                  
                  // Şifre değiştirme
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Şifre değiştirme sayfasına yönlendir
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text('Şifremi Değiştir'),
                  ),
                  const SizedBox(height: 40),
                  
                  // Kaydet düğmesi
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
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
                            child: const Text(
                              'Değişiklikleri Kaydet',
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
      ),
    );
  }

  // Bölüm başlığı widget'ı
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
