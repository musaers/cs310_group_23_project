// lib/screens/admin/admin_signup_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/service_provider.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({Key? key}) : super(key: key);

  @override
  _AdminSignupScreenState createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminCodeController = TextEditingController(); // Admin kayıt kodu

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';

  // Bu kod değeri normalde güvenli bir yerde saklanmalı,
  // Firebase Remote Config veya Firestore'da şifrelenmiş olarak tutulabilir
  final String _validAdminCode = "SUGYM_ADMIN_2025";

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    // Admin kodu kontrolü
    if (_adminCodeController.text.trim() != _validAdminCode) {
      setState(() {
        _errorMessage = 'Geçersiz admin kayıt kodu. Lütfen doğru kodu girin.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Şifreler eşleşmiyor';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Admin kayıt işlemi
      await context.authService.registerAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      // Başarılı kayıt mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Admin hesabı başarıyla oluşturuldu. Şimdi giriş yapabilirsiniz.'),
          backgroundColor: Colors.green,
        ),
      );

      // Admin giriş sayfasına yönlendir
      Navigator.pushReplacementNamed(context, '/admin/login');
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'Bu e-posta adresi zaten kullanımda.';
            break;
          case 'weak-password':
            _errorMessage =
                'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
            break;
          case 'invalid-email':
            _errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
            break;
          default:
            _errorMessage = 'Kayıt sırasında bir hata oluştu: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Kaydı',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo ve başlık
                  const SizedBox(height: 40),
                  Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: Colors.purple,
                  ),
                  Text(
                    'SUGYM+ Admin Kayıt',
                    style: GoogleFonts.ubuntu(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Hata mesajı (varsa)
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage,
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Kullanıcı adı alanı
                  TextFormField(
                    controller: _usernameController,
                    style: GoogleFonts.ubuntu(),
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      labelStyle: GoogleFonts.ubuntu(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir kullanıcı adı girin';
                      }
                      if (value.length < 3) {
                        return 'Kullanıcı adı en az 3 karakter olmalıdır';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // E-posta alanı
                  TextFormField(
                    controller: _emailController,
                    style: GoogleFonts.ubuntu(),
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      labelStyle: GoogleFonts.ubuntu(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen e-postanızı girin';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Lütfen geçerli bir e-posta adresi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Şifre alanı
                  TextFormField(
                    controller: _passwordController,
                    style: GoogleFonts.ubuntu(),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: GoogleFonts.ubuntu(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir şifre girin';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalıdır';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Şifre onay alanı
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: GoogleFonts.ubuntu(),
                    decoration: InputDecoration(
                      labelText: 'Şifre Onay',
                      labelStyle: GoogleFonts.ubuntu(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi onaylayın';
                      }
                      if (value != _passwordController.text) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Admin kayıt kodu alanı
                  TextFormField(
                    controller: _adminCodeController,
                    style: GoogleFonts.ubuntu(),
                    decoration: InputDecoration(
                      labelText: 'Admin Kayıt Kodu',
                      labelStyle: GoogleFonts.ubuntu(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.code),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen admin kayıt kodunu girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Kayıt düğmesi
                  _isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(color: Colors.purple))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _signup,
                          child: Text(
                            'KAYIT OL',
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),

                  // Admin giriş sayfasına bağlantı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten bir admin hesabınız var mı?   ',
                        style: GoogleFonts.ubuntu(),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/admin/login');
                        },
                        child: Text(
                          'GİRİŞ YAP',
                          style: GoogleFonts.ubuntu(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
