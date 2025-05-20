// lib/screens/admin/admin_class_create_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/service_provider.dart';

class AdminClassCreateScreen extends StatefulWidget {
  const AdminClassCreateScreen({Key? key}) : super(key: key);

  @override
  _AdminClassCreateScreenState createState() => _AdminClassCreateScreenState();
}

class _AdminClassCreateScreenState extends State<AdminClassCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _trainerController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _equipmentController =
      TextEditingController(); // Yeni eklenen controllör

  List<String> _equipment = [];
  String _intensity = 'Medium';
  String _day = 'Monday';

  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Günler ve yoğunluk seçenekleri
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> _intensityLevels = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _nameController.dispose();
    _trainerController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _caloriesController.dispose();
    _equipmentController.dispose(); // Yeni eklenen controllör dispose
    super.dispose();
  }

  // Ekipman ekleme fonksiyonu
  void _addEquipment(String equipment) {
    if (equipment.isNotEmpty && !_equipment.contains(equipment)) {
      setState(() {
        _equipment.add(equipment);
        _equipmentController.clear(); // Controllörü temizle
      });
    }
  }

  // Ekipman silme fonksiyonu
  void _removeEquipment(String equipment) {
    setState(() {
      _equipment.remove(equipment);
    });
  }

  // Ders oluşturma fonksiyonu
  Future<void> _createClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      // Firestore referansı oluştur
      final classesRef = FirebaseFirestore.instance.collection('classes');

      // Yeni ders dokümanı oluştur
      await classesRef.add({
        'name': _nameController.text.trim(),
        'trainer': _trainerController.text.trim(),
        'startTime': _startTimeController.text.trim(),
        'endTime': _endTimeController.text.trim(),
        'day': _day,
        'capacity': int.parse(_capacityController.text.trim()),
        'enrolled': 0,
        'description': _descriptionController.text.trim(),
        'equipment': _equipment,
        'intensity': _intensity,
        'calories': _caloriesController.text.trim(),
        'location': _locationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Başarı mesajı
      setState(() {
        _successMessage = 'Ders başarıyla oluşturuldu!';

        // Formları temizle
        _nameController.clear();
        _trainerController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
        _capacityController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _caloriesController.clear();
        _equipment = [];
      });

      // 3 saniye sonra başarı mesajını kaldır
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = '';
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ders oluşturulurken bir hata oluştu: $e';
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
          'Yeni Ders Oluştur',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                Text(
                  'Ders Bilgileri',
                  style: GoogleFonts.ubuntu(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Hata mesajı
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: GoogleFonts.ubuntu(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Başarı mesajı
                if (_successMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _successMessage,
                            style: GoogleFonts.ubuntu(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Ders adı
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ders Adı',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen ders adını girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Eğitmen adı
                TextFormField(
                  controller: _trainerController,
                  decoration: const InputDecoration(
                    labelText: 'Eğitmen',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen eğitmen adını girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gün seçimi
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gün',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  value: _day,
                  items: _days.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _day = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Saat bilgileri
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Başlangıç Saati',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                          hintText: '09:00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Başlangıç saatini girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _endTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Bitiş Saati',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                          hintText: '10:00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitiş saatini girin';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Kapasite
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Kapasite',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kapasite girin';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Yoğunluk
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Yoğunluk',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.speed),
                  ),
                  value: _intensity,
                  items: _intensityLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _intensity = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Kalori
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Yakılan Kalori (örn: 300-500)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                ),
                const SizedBox(height: 16),

                // Konum
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Konum',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konum bilgisini girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Açıklama
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ders açıklaması girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Ekipman bölümü
                Text(
                  'Gerekli Ekipmanlar',
                  style: GoogleFonts.ubuntu(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Ekipman ekleme - GÜNCELLENDİ
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _equipmentController, // Controllör atandı
                        decoration: const InputDecoration(
                          labelText: 'Ekipman',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                        onFieldSubmitted: (value) {
                          _addEquipment(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                      ),
                      onPressed: () {
                        // Controllör kullanarak ekipman ekleme
                        if (_equipmentController.text.isNotEmpty) {
                          _addEquipment(_equipmentController.text);
                        }
                      },
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Eklenen ekipmanların listesi
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _equipment.map((equipment) {
                    return Chip(
                      label: Text(equipment),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _removeEquipment(equipment),
                      backgroundColor: Colors.purple.withOpacity(0.1),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Ders oluşturma düğmesi
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.purple,
                          ),
                          onPressed: _createClass,
                          child: Text(
                            'Dersi Oluştur',
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
}
