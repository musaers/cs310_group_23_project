// lib/screens/admin/admin_class_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/class_model.dart';
import '../../services/service_provider.dart';

class AdminClassEditScreen extends StatefulWidget {
  const AdminClassEditScreen({Key? key}) : super(key: key);

  @override
  _AdminClassEditScreenState createState() => _AdminClassEditScreenState();
}

class _AdminClassEditScreenState extends State<AdminClassEditScreen> {
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
  final _equipmentController = TextEditingController();

  List<String> _equipment = [];
  String _intensity = 'Medium';
  String _day = 'Monday';
  String? _classId;

  bool _isLoading = false;
  bool _isInitialized = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Days and intensity options
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load class data from arguments if not already initialized
    if (!_isInitialized) {
      final classModel =
          ModalRoute.of(context)?.settings.arguments as ClassModel?;
      if (classModel != null) {
        _initializeWithClassData(classModel);
      }
      _isInitialized = true;
    }
  }

  void _initializeWithClassData(ClassModel classModel) {
    _classId = classModel.id;
    _nameController.text = classModel.name;
    _trainerController.text = classModel.trainer;
    _startTimeController.text = classModel.startTime;
    _endTimeController.text = classModel.endTime;
    _day = classModel.day;
    _capacityController.text = classModel.capacity.toString();
    _descriptionController.text = classModel.description;
    _locationController.text = classModel.location;
    _caloriesController.text = classModel.calories;
    _intensity = classModel.intensity;
    _equipment = List<String>.from(classModel.equipment);
  }

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
    _equipmentController.dispose();
    super.dispose();
  }

  // Add equipment function
  void _addEquipment(String equipment) {
    if (equipment.isNotEmpty && !_equipment.contains(equipment)) {
      setState(() {
        _equipment.add(equipment);
        _equipmentController.clear();
      });
    }
  }

  // Remove equipment function
  void _removeEquipment(String equipment) {
    setState(() {
      _equipment.remove(equipment);
    });
  }

  // Update class function
  Future<void> _updateClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      if (_classId == null) {
        throw Exception('Class ID is missing');
      }

      // Prepare class data
      final classData = {
        'name': _nameController.text.trim(),
        'trainer': _trainerController.text.trim(),
        'startTime': _startTimeController.text.trim(),
        'endTime': _endTimeController.text.trim(),
        'day': _day,
        'capacity': int.parse(_capacityController.text.trim()),
        'description': _descriptionController.text.trim(),
        'equipment': _equipment,
        'intensity': _intensity,
        'calories': _caloriesController.text.trim(),
        'location': _locationController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update class document in Firestore
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(_classId)
          .update(classData);

      // Success message
      setState(() {
        _successMessage = 'Class updated successfully!';
      });

      // Return to classes screen after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      });
    } catch (e) {
      print('Error updating class: $e');
      setState(() {
        _errorMessage = 'Error updating class: $e';
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
          'Edit Class',
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
                // Title
                Text(
                  'Class Information',
                  style: GoogleFonts.ubuntu(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Error message
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

                // Success message
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

                // Class name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a class name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Trainer name
                TextFormField(
                  controller: _trainerController,
                  decoration: const InputDecoration(
                    labelText: 'Trainer',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter trainer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Day selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Day',
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

                // Time information
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                          hintText: '09:00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter start time';
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
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                          hintText: '10:00',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter end time';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Capacity
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter capacity';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Intensity
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Intensity',
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

                // Calories
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories (e.g. 300-500)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter class description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Equipment section
                Text(
                  'Required Equipment',
                  style: GoogleFonts.ubuntu(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Add equipment
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _equipmentController,
                        decoration: const InputDecoration(
                          labelText: 'Equipment',
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
                        if (_equipmentController.text.isNotEmpty) {
                          _addEquipment(_equipmentController.text);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Equipment list
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

                // Update button
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.purple,
                          ),
                          onPressed: _updateClass,
                          child: Text(
                            'Update Class',
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

