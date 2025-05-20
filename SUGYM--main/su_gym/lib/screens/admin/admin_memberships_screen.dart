// lib/screens/admin/admin_memberships_screen.dart - PART 1

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMembershipsScreen extends StatefulWidget {
  const AdminMembershipsScreen({Key? key}) : super(key: key);

  @override
  State<AdminMembershipsScreen> createState() => _AdminMembershipsScreenState();
}

class _AdminMembershipsScreenState extends State<AdminMembershipsScreen> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMembershipPlans();
  }

  // Üyelik planlarını Firestore'dan yükle
  Future<void> _loadMembershipPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('membership_plans')
          .orderBy('name')
          .get();

      final List<Map<String, dynamic>> plans = [];

      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Firestore'dan süre seçeneklerini işleme
        List<Map<String, dynamic>> durations = [];
        if (data['durations'] != null && data['durations'] is List) {
          durations = List<Map<String, dynamic>>.from(
            (data['durations'] as List)
                .map((item) => Map<String, dynamic>.from(item)),
          );
        }

        // Firestore'dan özellikleri işleme
        List<String> features = [];
        if (data['features'] != null && data['features'] is List) {
          features = List<String>.from(data['features']);
        }

        plans.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'durations': durations,
          'features': features,
          'color': _getPlanColor(data['name'] ?? ''),
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        });
      }

      setState(() {
        _plans = plans;
        _isLoading = false;
      });

      print('${_plans.length} membership plans loaded');
    } catch (e) {
      print('Error loading membership plans: $e');
      setState(() {
        _errorMessage = 'Error loading membership plans: $e';
        _isLoading = false;
      });
    }
  }

  // Plan silme işlemi
  Future<void> _deletePlan(String planId, String planName) async {
    try {
      await FirebaseFirestore.instance
          .collection('membership_plans')
          .doc(planId)
          .delete();

      // Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$planName plan deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Planları yenile
      _loadMembershipPlans();
    } catch (e) {
      print('Error deleting plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Plan için renk belirleme
  Color _getPlanColor(String planName) {
    switch (planName.toLowerCase()) {
      case 'premium':
        return Colors.blue;
      case 'platinum':
        return Colors.purple;
      case 'student':
      case 'öğrenci':
        return Colors.teal;
      case 'family':
      case 'aile':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Membership Plans',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMembershipPlans,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _plans.isEmpty
                  ? _buildEmptyView()
                  : _buildPlansListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
        tooltip: 'Add Plan',
      ),
    );
  }
  // lib/screens/admin/admin_memberships_screen.dart - PART 2

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
              onPressed: _loadMembershipPlans,
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

  // Boş liste görünümü
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_membership, color: Colors.grey, size: 60),
            const SizedBox(height: 16),
            Text(
              'No membership plans available',
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new plan using the + button',
              style: GoogleFonts.ubuntu(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Planlar listesi görünümü
  Widget _buildPlansListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) => _buildPlanCard(_plans[index]),
    );
  }

  // Plan kartı
  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final planColor = plan['color'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Plan başlığı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: planColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'],
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _showEditPlanDialog(plan),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _showDeleteConfirmation(plan),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Plan detayları
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Açıklama
                Text(
                  plan['description'],
                  style: GoogleFonts.ubuntu(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),

                // Fiyat seçenekleri
                Text(
                  'Pricing Options:',
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...(plan['durations'] as List<Map<String, dynamic>>)
                    .map<Widget>((duration) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${duration['months']} ${duration['months'] == 1 ? 'Month' : 'Months'}',
                          style: GoogleFonts.ubuntu(),
                        ),
                        Text(
                          '${duration['price']} TL',
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Özellikler
                Text(
                  'Features:',
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...(plan['features'] as List<String>).map<Widget>((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: planColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.ubuntu(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Silme onay iletişim kutusu
  void _showDeleteConfirmation(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Plan',
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete the ${plan['name']} plan? This action cannot be undone.',
          style: GoogleFonts.ubuntu(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
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
              _deletePlan(plan['id'], plan['name']);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.ubuntu(),
            ),
          ),
        ],
      ),
    );
  }

  // lib/screens/admin/admin_memberships_screen.dart - PART 3

  // Yeni plan ekleme iletişim kutusu
  void _showAddPlanDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final featureController = TextEditingController();

    // Başlangıç özellikleri ve süreler
    List<String> features = [];
    List<Map<String, dynamic>> durations = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Add New Plan',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan adı alanı
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Plan Name',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Premium, Student, Family'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a plan name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Plan açıklaması alanı
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText:
                            'e.g. Our most popular plan with all features'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Süre bölümü
                  Text(
                    'Pricing Options:',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mevcut süreleri göster
                  ...durations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final duration = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${duration['months']} ${duration['months'] == 1 ? 'Month' : 'Months'} - ${duration['price']} TL',
                              style: GoogleFonts.ubuntu(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                durations.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Süre ekleme bölümü
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: durationController,
                          decoration: const InputDecoration(
                              labelText: 'Duration (months)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 1, 3, 12'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                              labelText: 'Price (TL)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 299'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          final months = int.tryParse(durationController.text);
                          final price = int.tryParse(priceController.text);

                          if (months != null &&
                              months > 0 &&
                              price != null &&
                              price > 0) {
                            setState(() {
                              durations.add({
                                'months': months,
                                'price': price,
                              });
                              durationController.clear();
                              priceController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter valid duration and price'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Özellikler bölümü
                  Text(
                    'Features:',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mevcut özellikleri göster
                  ...features.asMap().entries.map((entry) {
                    final index = entry.key;
                    final feature = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.ubuntu(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                features.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Özellik ekleme bölümü
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: featureController,
                          decoration: const InputDecoration(
                              labelText: 'New Feature',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. Access to all gym facilities'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          final feature = featureController.text.trim();
                          if (feature.isNotEmpty) {
                            setState(() {
                              features.add(feature);
                              featureController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a feature'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.ubuntu(),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (durations.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one pricing option'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (features.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one feature'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Planı Firestore'a kaydet
                  try {
                    await FirebaseFirestore.instance
                        .collection('membership_plans')
                        .add({
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'durations': durations,
                      'features': features,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    // Dialog'u kapat
                    Navigator.pop(context);

                    // Başarı mesajı göster
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membership plan created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Planları yenile
                    _loadMembershipPlans();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error creating plan: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Create Plan',
                style: GoogleFonts.ubuntu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Plan düzenleme iletişim kutusu
  void _showEditPlanDialog(Map<String, dynamic> plan) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: plan['name']);
    final descriptionController =
        TextEditingController(text: plan['description']);
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final featureController = TextEditingController();

    // Mevcut özellikleri ve süreleri kopyala
    List<String> features = List<String>.from(plan['features']);
    List<Map<String, dynamic>> durations = [];

    // Durations'ı doğru şekilde kopyala
    for (var duration in plan['durations']) {
      durations.add({
        'months': duration['months'],
        'price': duration['price'],
      });
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Edit ${plan['name']} Plan',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan adı alanı
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Plan Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a plan name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Plan açıklaması alanı
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Süre bölümü
                  Text(
                    'Pricing Options:',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mevcut süreleri göster
                  ...durations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final duration = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${duration['months']} ${duration['months'] == 1 ? 'Month' : 'Months'} - ${duration['price']} TL',
                              style: GoogleFonts.ubuntu(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                durations.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Süre ekleme bölümü
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: durationController,
                          decoration: const InputDecoration(
                              labelText: 'Duration (months)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 1, 3, 12'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                              labelText: 'Price (TL)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 299'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          final months = int.tryParse(durationController.text);
                          final price = int.tryParse(priceController.text);

                          if (months != null &&
                              months > 0 &&
                              price != null &&
                              price > 0) {
                            setState(() {
                              durations.add({
                                'months': months,
                                'price': price,
                              });
                              durationController.clear();
                              priceController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter valid duration and price'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Özellikler bölümü
                  Text(
                    'Features:',
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mevcut özellikleri göster
                  ...features.asMap().entries.map((entry) {
                    final index = entry.key;
                    final feature = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: GoogleFonts.ubuntu(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                features.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Özellik ekleme bölümü
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: featureController,
                          decoration: const InputDecoration(
                              labelText: 'New Feature',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. Access to all gym facilities'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          final feature = featureController.text.trim();
                          if (feature.isNotEmpty) {
                            setState(() {
                              features.add(feature);
                              featureController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a feature'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.ubuntu(),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (durations.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one pricing option'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (features.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one feature'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Planı Firestore'da güncelle
                  try {
                    await FirebaseFirestore.instance
                        .collection('membership_plans')
                        .doc(plan['id'])
                        .update({
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'durations': durations,
                      'features': features,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    // Dialog'u kapat
                    Navigator.pop(context);

                    // Başarı mesajı göster
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membership plan updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Planları yenile
                    _loadMembershipPlans();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating plan: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Update Plan',
                style: GoogleFonts.ubuntu(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
