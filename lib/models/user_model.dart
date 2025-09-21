class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;
  final double? portfolioValue;
  final int? level;
  final int? experience;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
    this.createdAt,
    this.lastLoginAt,
    this.preferences,
    this.portfolioValue,
    this.level,
    this.experience,
  });

  // Get the display name, prioritizing firstName + lastName, then displayName, then email
  String get fullDisplayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    } else {
      return email.split('@')[0];
    }
  }

  // Get first name for avatar initials
  String get firstNameForAvatar {
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName![0].toUpperCase();
    } else if (displayName != null && displayName!.isNotEmpty) {
      return displayName![0].toUpperCase();
    } else {
      return email[0].toUpperCase();
    }
  }

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: data['createdAt']?.toDate(),
      lastLoginAt: data['lastLoginAt']?.toDate(),
      preferences: data['preferences'],
      portfolioValue: data['portfolioValue']?.toDouble(),
      level: data['level'],
      experience: data['experience'],
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'preferences': preferences,
      'portfolioValue': portfolioValue,
      'level': level,
      'experience': experience,
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    double? portfolioValue,
    int? level,
    int? experience,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      portfolioValue: portfolioValue ?? this.portfolioValue,
      level: level ?? this.level,
      experience: experience ?? this.experience,
    );
  }
}
