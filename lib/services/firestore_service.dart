import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> saveItemToVault({
    required String title,
    required String imageUrl,
    required String type,
    String folderName = 'Main Vault', // ADDED: Default folder name
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Stores data in: users -> [User ID] -> vault -> [Item Document]
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('vault')
          .add({
        'title': title,
        'imageUrl': imageUrl,
        'type': type,
        'folderName': folderName, // ADDED: Save the folder classification
        'savedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print("Vault Error: $e");
      return false;
    }
  }
}