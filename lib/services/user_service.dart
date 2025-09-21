import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the current logged-in user's document from the 'users' collection.
  ///
  /// Throws an exception if no user is currently logged in.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("No user is currently logged in.");
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        throw Exception("User document does not exist.");
      }
      
      return userDoc;
    } catch (e) {
      // Re-throw the exception to be handled by the UI
      throw Exception("Error fetching user data: $e");
    }
  }

  // Get current user data from Firestore (keeping the old method for compatibility)
  Future<UserModel?> getCurrentUserData() async {
    try {
      final userDoc = await getUserData();
      return UserModel.fromFirestore(userDoc.data()!, userDoc.id);
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Create or update user document in Firestore
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user: $e');
      throw e;
    }
  }

  // Create user document on first sign up
  Future<void> createUserOnSignUp(String uid, String email, {String? displayName}) async {
    try {
      final user = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        portfolioValue: 100000.0, // Starting portfolio value
        level: 1,
        experience: 0,
      );

      await createOrUpdateUser(user);
    } catch (e) {
      print('Error creating user on sign up: $e');
      throw e;
    }
  }

  // Update user's last login time
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Update user's portfolio value
  Future<void> updatePortfolioValue(String uid, double newValue) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'portfolioValue': newValue,
      });
    } catch (e) {
      print('Error updating portfolio value: $e');
      throw e;
    }
  }

  // Update user's level and experience
  Future<void> updateLevelAndExperience(String uid, int level, int experience) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'level': level,
        'experience': experience,
      });
    } catch (e) {
      print('Error updating level and experience: $e');
      throw e;
    }
  }

  // Get user data by UID
  Future<UserModel?> getUserDataByUid(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data by UID: $e');
      return null;
    }
  }

  // Stream user data for real-time updates
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      } else {
        return null;
      }
    });
  }
}
