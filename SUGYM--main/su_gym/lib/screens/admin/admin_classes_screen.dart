// lib/screens/admin/admin_classes_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/class_model.dart';

class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({Key? key}) : super(key: key);

  @override
  _AdminClassesScreenState createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  bool _isLoading = true;
  List<ClassModel> _classes = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('classes')
          .orderBy('day')
          .orderBy('startTime')
          .get();

      final List<ClassModel> classes =
          snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();

      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Dersler yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteClass(String classId) async {
    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .delete();

      // Listeyi güncelle
      setState(() {
        _classes.removeWhere((cls) => cls.id == classId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ders başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ders silinirken bir hata oluştu: $e'),
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
          'Dersler',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClasses,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hata!',
                        style: GoogleFonts.ubuntu(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _loadClasses,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _classes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            color: Colors.grey,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz Ders Eklenmemiş',
                            style: GoogleFonts.ubuntu(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yeni bir ders eklemek için aşağıdaki butona tıklayın',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final cls = _classes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cls.name,
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: Text(
                                        cls.day,
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${cls.startTime} - ${cls.endTime}',
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.person,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cls.trainer,
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.grey.shade700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      cls.location,
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.people,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${cls.enrolled}/${cls.capacity}',
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Düzenle'),
                                      onPressed: () {
                                        // Düzenleme sayfasına git
                                        // Bu kısmı daha sonra ekleyebilirsiniz
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete,
                                          size: 16, color: Colors.red),
                                      label: const Text('Sil',
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        // Silme onayı
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              'Dersi Sil',
                                              style: GoogleFonts.ubuntu(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: Text(
                                              '${cls.name} dersini silmek istediğinize emin misiniz?',
                                              style: GoogleFonts.ubuntu(),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'İptal',
                                                  style: GoogleFonts.ubuntu(),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteClass(cls.id);
                                                },
                                                child: Text(
                                                  'Sil',
                                                  style: GoogleFonts.ubuntu(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/classes/create');
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
        tooltip: 'Yeni Ders Ekle',
      ),
    );
  }
}
