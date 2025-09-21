import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user data from Firestore
  static Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return null;
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      } else {
        print('User document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Create or update user document in Firestore
  static Future<void> createOrUpdateUser(UserModel user) async {
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
  static Future<void> createUserOnSignUp(String uid, String email, {String? displayName}) async {
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
  static Future<void> updateLastLogin(String uid) async {
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
  static Future<void> updatePortfolioValue(String uid, double newValue) async {
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
  static Future<void> updateLevelAndExperience(String uid, int level, int experience) async {
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
  static Future<UserModel?> getUserData(String uid) async {
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
  static Stream<UserModel?> getUserDataStream(String uid) {
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
