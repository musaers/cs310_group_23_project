import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
    DateTime dateOfBirth,
  ) async {
    try {
      // Create user account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _createUserProfile(result.user!.uid, username, email, dateOfBirth);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(
    String uid,
    String username,
    String email,
    DateTime dateOfBirth,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'createdAt': FieldValue.serverTimestamp(),
      'membership': {
        'plan': 'None',
        'startDate': null,
        'endDate': null,
        'status': 'Inactive',
      },
      'fitness': {
        'currentWeight': null,
        'targetWeight': null,
        'startingWeight': null,
        'progress': 0,
      },
      'statistics': {
        'weeklyVisits': 0,
        'monthlyVisits': 0,
        'totalVisits': 0,
        'mostAttendedClass': '',
      },
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<void> updateProfile(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  // Update user email
  Future<void> updateEmail(String email) async {
    await _auth.currentUser?.updateEmail(email);
  }

  // Update user password
  Future<void> updatePassword(String password) async {
    await _auth.currentUser?.updatePassword(password);
  }

  // ******************** ADMIN FUNCTIONS ******************** //

  // Admin kontrolü
  Future<bool> isAdmin(String uid) async {
    try {
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(uid).get();
      return adminDoc.exists;
    } catch (e) {
      print('Admin kontrolü sırasında hata: $e');
      return false;
    }
  }

  // Admin kaydı
  Future<UserCredential> registerAdmin({
    required String email,
    required String password,
    required String username,
    String role = 'admin',
    List<String> permissions = const ['manage_classes', 'view_reports'],
  }) async {
    try {
      // Kullanıcı hesabı oluştur
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Admin bilgilerini Firestore'a kaydet
      await _firestore.collection('admins').doc(result.user!.uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'role': role,
        'permissions': permissions,
      });

      return result;
    } catch (e) {
      print('Admin kaydı sırasında hata: $e');
      rethrow;
    }
  }

  // Admin girişi (normal giriş ile aynı, ama admin kontrolü yapar)
  Future<UserCredential> adminLogin(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Admin kontrolü
      bool isUserAdmin = await isAdmin(userCredential.user!.uid);

      if (!isUserAdmin) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'Bu kullanıcı admin yetkilerine sahip değil.',
        );
      }

      return userCredential;
    } catch (e) {
      print('Admin girişi sırasında hata: $e');
      rethrow;
    }
  }
}

