// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // E-posta kontrolü
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi giriniz';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    return null;
  }

  // Şifre sıfırlama e-postası gönderme
  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simüle edilmiş e-posta gönderme
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Şifremi Unuttum',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _emailSent ? _buildSuccessMessage() : _buildForm(),
      ),
    );
  }

  // Form widget'ı
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo ve başlık
          Text(
            'SUGYM+',
            style: GoogleFonts.ubuntu(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Bilgi metni
          Text(
            'Lütfen hesabınızla ilişkili e-posta adresini girin. Size şifre sıfırlama bağlantısı içeren bir e-posta göndereceğiz.',
            style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // E-posta girişi
          TextFormField(
            controller: _emailController,
            style: GoogleFonts.ubuntu(),
            decoration: InputDecoration(
              labelText: 'E-posta Adresi',
              labelStyle: GoogleFonts.ubuntu(),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 30),

          // Gönder düğmesi
          _isLoading
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
                onPressed: _sendResetEmail,
                child: Text(
                  'Sıfırlama Bağlantısı Gönder',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          const SizedBox(height: 20),

          // Giriş sayfasına dönüş
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Giriş Sayfasına Dön', style: GoogleFonts.ubuntu()),
          ),
        ],
      ),
    );
  }

  // Başarı mesajı widget'ı
  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        Text(
          'Sıfırlama Bağlantısı Gönderildi',
          style: GoogleFonts.ubuntu(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Şifre sıfırlama talimatları ${_emailController.text} adresine gönderildi. Lütfen e-postanızı kontrol edin.',
          style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            'Giriş Sayfasına Dön',
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

