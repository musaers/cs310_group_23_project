import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _uid => _auth.currentUser?.uid;

  // Upload profile image
  Future<String> uploadProfileImage(File file) async {
    if (_uid == null) throw Exception('User not authenticated');

    // Create a reference to the location where the file will be stored
    Reference ref = _storage.ref().child('profile_images').child('$_uid.jpg');

    // Upload the file
    UploadTask uploadTask = ref.putFile(file);

    // Get download URL
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();

    return downloadURL;
  }

  // Upload class image
  Future<String> uploadClassImage(String className, File file) async {
    if (_uid == null) throw Exception('User not authenticated');

    // Create a sanitized file name from the class name
    String sanitizedName = className.toLowerCase().replaceAll(' ', '_');

    // Create a reference to the location where the file will be stored
    Reference ref = _storage
        .ref()
        .child('class_images')
        .child('$sanitizedName.jpg');

    // Upload the file
    UploadTask uploadTask = ref.putFile(file);

    // Get download URL
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();

    return downloadURL;
  }

  // Delete profile image
  Future<void> deleteProfileImage() async {
    if (_uid == null) throw Exception('User not authenticated');

    try {
      Reference ref = _storage.ref().child('profile_images').child('$_uid.jpg');
      await ref.delete();
    } catch (e) {
      // File might not exist
      print('Error deleting profile image: $e');
    }
  }

  // Get profile image URL
  Future<String?> getProfileImageUrl() async {
    if (_uid == null) throw Exception('User not authenticated');

    try {
      Reference ref = _storage.ref().child('profile_images').child('$_uid.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      // File might not exist
      return null;
    }
  }

  // Get class image URL
  Future<String?> getClassImageUrl(String className) async {
    String sanitizedName = className.toLowerCase().replaceAll(' ', '_');

    try {
      Reference ref = _storage
          .ref()
          .child('class_images')
          .child('$sanitizedName.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      // File might not exist
      return null;
    }
  }
}
