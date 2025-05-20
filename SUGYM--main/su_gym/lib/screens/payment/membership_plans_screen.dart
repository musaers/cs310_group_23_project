// Complete implementation for lib/screens/payment/membership_plans_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/service_provider.dart';

class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  _MembershipPlansScreenState createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  // Selected plan index
  int _selectedPlanIndex = -1;

  // Selected duration for purchase
  Map<String, dynamic>? _selectedDuration;

  // Firestore plans
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  String _errorMessage = '';

  // User membership data
  Map<String, dynamic>? _currentMembership;

  @override
  void initState() {
    super.initState();
    _loadMembershipPlans();
    _loadUserMembership();
  }

  Future<void> _loadMembershipPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Loading membership plans from Firestore...');

      // Firestore sorgunuzu kontrol edin - koleksiyon adı doğru mu?
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(
              'membership_plans') // Koleksiyon adının doğru olduğundan emin olun
          .get();

      print('Firestore query completed. Found ${snapshot.docs.length} plans.');

      List<Map<String, dynamic>> plans = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Processing plan: ${data['name']}');

        // Process durations from Firestore
        List<Map<String, dynamic>> durations = [];
        if (data['durations'] != null && data['durations'] is List) {
          durations = List<Map<String, dynamic>>.from(
            (data['durations'] as List)
                .map((item) => Map<String, dynamic>.from(item)),
          );
        }

        // Process features from Firestore
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
        });
      }

      setState(() {
        _plans = plans;
        _isLoading = false;
      });

      print('${_plans.length} membership plans loaded successfully');
    } catch (e) {
      print('Error loading membership plans: $e');
      setState(() {
        _errorMessage = 'Error loading membership plans: $e';
        _isLoading = false;
      });
    }
  }

  // Load user's current membership
  Future<void> _loadUserMembership() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()!.containsKey('membership')) {
          setState(() {
            _currentMembership =
                doc.data()!['membership'] as Map<String, dynamic>;
          });

          print('Current membership: $_currentMembership');
        }
      }
    } catch (e) {
      print('Error loading user membership: $e');
    }
  }

  // Determine plan color based on name
  Color _getPlanColor(String planName) {
    switch (planName.toLowerCase()) {
      case 'premium':
        return Colors.blue;
      case 'platinum':
        return Colors.purple;
      case 'student':
        return Colors.teal;
      case 'family':
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
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadMembershipPlans();
              _loadUserMembership();
            },
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
    );
  }

  // Error view
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

  // Empty view when no plans are available
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
              'Please check back later',
              style: GoogleFonts.ubuntu(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Plans list view
  Widget _buildPlansListView() {
    return Stack(
      children: [
        // Show current membership status if available
        if (_currentMembership != null &&
            _currentMembership!['status'] == 'Active')
          _buildCurrentMembershipBanner(),

        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If user has active membership, add some spacing
                if (_currentMembership != null &&
                    _currentMembership!['status'] == 'Active')
                  const SizedBox(height: 60),

                Text(
                  'Choose your plan',
                  style: GoogleFonts.ubuntu(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the membership plan that works best for you.',
                  style: GoogleFonts.ubuntu(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Membership plans list
                ...List.generate(
                  _plans.length,
                  (index) => _buildPlanCard(context, _plans[index], index),
                ),
              ],
            ),
          ),
        ),

        // Loading indicator when processing payment
        if (_isProcessingPayment)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Processing payment...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Banner showing current membership status
  Widget _buildCurrentMembershipBanner() {
    final String planName = _currentMembership!['plan'] ?? 'Unknown';
    final endDate = _currentMembership!['endDate'] != null
        ? (_currentMembership!['endDate'] as Timestamp).toDate()
        : DateTime.now();

    final daysRemaining = endDate.difference(DateTime.now()).inDays;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: Colors.green,
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You have an active $planName membership',
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$daysRemaining days left',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Plan card widget
  Widget _buildPlanCard(
      BuildContext context, Map<String, dynamic> plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    final Color planColor = plan['color'];

    // Check if this is the user's current plan
    final bool isCurrentPlan = _currentMembership != null &&
        _currentMembership!['status'] == 'Active' &&
        _currentMembership!['plan'] == plan['name'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
          _selectedDuration =
              null; // Reset selected duration when switching plans
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? planColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? planColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: planColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  // Current plan label if applicable
                  if (isCurrentPlan)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'CURRENT PLAN',
                        style: GoogleFonts.ubuntu(
                          color: planColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  Text(
                    plan['name'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan['description'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Plan details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Duration options
                  Text(
                    'Duration Options:',
                    style: GoogleFonts.ubuntu(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...plan['durations'].map<Widget>((duration) {
                    final bool isSelectedDuration = _selectedPlanIndex ==
                            index &&
                        _selectedDuration != null &&
                        _selectedDuration!['months'] == duration['months'] &&
                        _selectedDuration!['price'] == duration['price'];

                    return InkWell(
                      onTap: () {
                        if (_selectedPlanIndex == index) {
                          setState(() {
                            _selectedDuration = duration;
                          });
                        } else {
                          setState(() {
                            _selectedPlanIndex = index;
                            _selectedDuration = duration;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelectedDuration
                                ? planColor
                                : Colors.grey.shade300,
                            width: isSelectedDuration ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelectedDuration
                              ? planColor.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${duration['months']} ${duration['months'] == 1 ? 'Month' : 'Months'}',
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (duration['months'] > 1)
                                  Text(
                                    'Save ${_calculateDiscount(plan, duration)}%',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              '${duration['price']} TL',
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  // Features title
                  Text(
                    'Features:',
                    style: GoogleFonts.ubuntu(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Features list
                  ...plan['features'].map<Widget>((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: planColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
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

                  const SizedBox(height: 20),

                  // Buy button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: planColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isSelected && _selectedDuration != null
                          ? () => _showPaymentDialog(context, plan)
                          : () {
                              setState(() {
                                _selectedPlanIndex = index;
                                // Auto-select first duration if none is selected
                                if (_selectedDuration == null &&
                                    plan['durations'].isNotEmpty) {
                                  _selectedDuration = plan['durations'][0];
                                }
                              });
                            },
                      child: Text(
                        isCurrentPlan ? 'Renew Plan' : 'Buy',
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
          ],
        ),
      ),
    );
  }

  // Calculate discount percentage for longer durations
  int _calculateDiscount(
      Map<String, dynamic> plan, Map<String, dynamic> duration) {
    if (plan['durations'].isEmpty || duration['months'] <= 1) return 0;

    // Get the monthly price from the 1-month option
    final oneMonthOption = plan['durations'].firstWhere((d) => d['months'] == 1,
        orElse: () => {'price': duration['price'], 'months': 1});

    final oneMonthPrice = oneMonthOption['price'] as num;
    final currentPrice = duration['price'] as num;
    final currentMonths = duration['months'] as num;

    // Calculate the total equivalent price if paying monthly
    final equivalentMonthlyTotal = oneMonthPrice * currentMonths;

    // Calculate the discount
    final savings = equivalentMonthlyTotal - currentPrice;
    final discountPercentage = (savings / equivalentMonthlyTotal) * 100;

    return discountPercentage.round();
  }

  // Payment dialog
  void _showPaymentDialog(BuildContext context, Map<String, dynamic> plan) {
    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a duration option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Purchase ${plan['name']} Plan',
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to purchase:',
              style: GoogleFonts.ubuntu(),
            ),
            const SizedBox(height: 16),

            // Plan details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plan:',
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        plan['name'],
                        style: GoogleFonts.ubuntu(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration:',
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_selectedDuration!['months']} ${_selectedDuration!['months'] == 1 ? 'Month' : 'Months'}',
                        style: GoogleFonts.ubuntu(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price:',
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_selectedDuration!['price']} TL',
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Note: This is a demo app. No actual payment will be processed.',
              style: GoogleFonts.ubuntu(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
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
              backgroundColor: plan['color'],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _processMembershipPurchase(plan);
            },
            child: Text(
              'Proceed to Payment',
              style: GoogleFonts.ubuntu(),
            ),
          ),
        ],
      ),
    );
  }

  // Purchase processing
  Future<void> _processMembershipPurchase(Map<String, dynamic> plan) async {
    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a duration option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to purchase a membership');
      }

      // Get selected duration details
      final months = _selectedDuration!['months'] as int;
      final price = _selectedDuration!['price'];

      // Show payment details screen
      final didCompletePayment =
          await _showPaymentDetailsScreen(plan, _selectedDuration!);

      if (!didCompletePayment) {
        setState(() {
          _isProcessingPayment = false;
        });
        return;
      }

      // Calculate membership dates
      final now = DateTime.now();
      DateTime startDate = now;

      // If extending current membership, start from end date
      if (_currentMembership != null &&
          _currentMembership!['status'] == 'Active' &&
          _currentMembership!['endDate'] != null) {
        final currentEndDate =
            (_currentMembership!['endDate'] as Timestamp).toDate();
        if (currentEndDate.isAfter(now)) {
          startDate = currentEndDate;
        }
      }

      final endDate = startDate.add(Duration(days: 30 * months));

      // Update user's membership in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'membership.plan': plan['name'],
        'membership.planId': plan['id'],
        'membership.startDate': startDate,
        'membership.endDate': endDate,
        'membership.status': 'Active',
      });

      // Create payment record
      await FirebaseFirestore.instance.collection('payments').add({
        'userId': user.uid,
        'planId': plan['id'],
        'planName': plan['name'],
        'amount': price,
        'duration': months,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'Completed',
        'paymentMethod':
            'Credit Card', // In a real app, this would come from payment processing
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${plan['name']} plan purchased successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reload user membership
      await _loadUserMembership();

      // Navigate to profile page after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/profile');
      });
    } catch (e) {
      print('Error purchasing membership: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  // Show payment details screen
// _showPaymentDetailsScreen metodunu komple yeni haliyle değiştirin
  Future<bool> _showPaymentDetailsScreen(
      Map<String, dynamic> plan, Map<String, dynamic> duration) async {
    bool paymentCompleted = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık ve Kapat butonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Details',
                          style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sipariş özeti
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${plan['name']} (${duration['months']} ${duration['months'] == 1 ? 'Month' : 'Months'})',
                                style: GoogleFonts.ubuntu(),
                              ),
                              Text(
                                '${duration['price']} TL',
                                style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${duration['price']} TL',
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ödeme yöntemi başlığı
                    Text(
                      'Payment Method',
                      style: GoogleFonts.ubuntu(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Kredi kartı ödeme seçeneği
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue.withOpacity(0.05),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.credit_card, color: Colors.blue),
                              const SizedBox(width: 12),
                              Text(
                                'Credit/Debit Card',
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.check_circle,
                                  color: Colors.blue),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Kart numarası
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Card Number',
                              hintText: '1234 5678 9012 3456',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: '4111 1111 1111 1111',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Son kullanma tarihi ve CVV
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Expiry Date',
                                    hintText: 'MM/YY',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: '12/25',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                    hintText: '123',
                                    border: OutlineInputBorder(),
                                  ),
                                  initialValue: '123',
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Kart sahibinin adı
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Cardholder Name',
                              hintText: 'John Doe',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: 'John Doe',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Diğer ödeme yöntemleri (devre dışı)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            'Bank Transfer',
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Coming Soon',
                              style: GoogleFonts.ubuntu(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // PayPal seçeneği (devre dışı)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payment, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            'PayPal',
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Coming Soon',
                              style: GoogleFonts.ubuntu(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ödeme butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plan['color'],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Ödeme işlemi simülasyonu
                          setState(() {
                            paymentCompleted = true;
                          });

                          // Yükleme göster
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Dialog(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Processing payment...'),
                                  ],
                                ),
                              ),
                            ),
                          );

                          // İşlemi beklet
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pop(
                                context); // Yükleme iletişim kutusunu kapat
                            Navigator.pop(context); // Ödeme sayfasını kapat
                          });
                        },
                        child: Text(
                          'Pay ${duration['price']} TL',
                          style: GoogleFonts.ubuntu(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );

    return paymentCompleted;
  }
}
