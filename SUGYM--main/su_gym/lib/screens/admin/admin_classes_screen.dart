// lib/screens/admin/admin_classes_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // StreamSubscription için gerekli import
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
  StreamSubscription<QuerySnapshot>? _classesSubscription;

  @override
  void initState() {
    super.initState();
    _setupClassesListener();
  }

  @override
  void dispose() {
    _classesSubscription?.cancel();
    super.dispose();
  }

  // Setup real-time listener for classes
  Future<void> _setupClassesListener() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Cancel previous subscription if exists
      _classesSubscription?.cancel();

      // Set up real-time listener
      _classesSubscription = FirebaseFirestore.instance
          .collection('classes')
          .orderBy('day')
          .orderBy('startTime')
          .snapshots()
          .listen(
        (snapshot) {
          final List<ClassModel> classes = snapshot.docs
              .map((doc) => ClassModel.fromFirestore(doc))
              .toList();

          setState(() {
            _classes = classes;
            _isLoading = false;
          });
        },
        onError: (error) {
          print('Error listening to classes: $error');
          setState(() {
            _errorMessage = 'Error loading classes: $error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      print('Error setting up classes listener: $e');
      setState(() {
        _errorMessage = 'Error setting up classes listener: $e';
        _isLoading = false;
      });
    }
  }

  // Update class function
  Future<void> _updateClass(ClassModel classModel) async {
    try {
      // Navigate to edit screen and wait for result
      final result = await Navigator.pushNamed(
        context,
        '/admin/classes/edit',
        arguments: classModel,
      );

      // If successful update, refresh will happen automatically via listener
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error navigating to edit screen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating class: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete class function
  Future<void> _deleteClass(String classId, String className) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Delete Class',
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete "$className"? This action cannot be undone.',
                style: GoogleFonts.ubuntu(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel', style: GoogleFonts.ubuntu()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Delete', style: GoogleFonts.ubuntu()),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirm) return;

      // Delete class document from Firestore
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$className deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // No need to reload classes manually, we have real-time listener
    } catch (e) {
      print('Error deleting class: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting class: $e'),
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
          'Classes Management',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _setupClassesListener,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _classes.isEmpty
                  ? _buildEmptyView()
                  : _buildClassesListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/classes/create');
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
        tooltip: 'Add New Class',
      ),
    );
  }

  // Error view
  Widget _buildErrorView() {
    return Center(
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
            'Error!',
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
            onPressed: _setupClassesListener,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Empty view
  Widget _buildEmptyView() {
    return Center(
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
            'No Classes Available',
            style: GoogleFonts.ubuntu(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new class using the button below',
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Classes list view
  Widget _buildClassesListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        return _buildClassCard(_classes[index]);
      },
    );
  }

  // Class card widget - modified to match the UI in screenshot
  Widget _buildClassCard(ClassModel classInfo) {
    // Format capacity/enrollment info
    final capacityText = '${classInfo.enrolled}/${classInfo.capacity}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class header with name and day
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        classInfo.name,
                        style: GoogleFonts.ubuntu(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        classInfo.day,
                        style: GoogleFonts.ubuntu(
                          color: Colors.blue.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Time
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${classInfo.startTime} - ${classInfo.endTime}',
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Trainer
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      classInfo.trainer,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      classInfo.location,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      capacityText,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit button
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text('Düzenle', style: GoogleFonts.ubuntu()),
                      onPressed: () => _updateClass(classInfo),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete button
                    TextButton.icon(
                      icon:
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: Text('Sil',
                          style: GoogleFonts.ubuntu(color: Colors.red)),
                      onPressed: () =>
                          _deleteClass(classInfo.id, classInfo.name),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
