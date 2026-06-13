class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String preferredCurrency;
  final bool biometricEnabled;
  final String themeMode;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.preferredCurrency = 'USD',
    this.biometricEnabled = false,
    this.themeMode = 'system',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      preferredCurrency: map['preferredCurrency'] as String? ?? 'USD',
      biometricEnabled: (map['biometricEnabled'] as int? ?? 0) == 1,
      themeMode: map['themeMode'] as String? ?? 'system',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'preferredCurrency': preferredCurrency,
      'biometricEnabled': biometricEnabled ? 1 : 0,
      'themeMode': themeMode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      fullName: data['fullName'] as String,
      email: data['email'] as String,
      preferredCurrency: data['preferredCurrency'] as String? ?? 'USD',
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
      themeMode: data['themeMode'] as String? ?? 'system',
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'preferredCurrency': preferredCurrency,
      'biometricEnabled': biometricEnabled,
      'themeMode': themeMode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? preferredCurrency,
    bool? biometricEnabled,
    String? themeMode,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.create({
    required String id,
    required String fullName,
    required String email,
  }) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      preferredCurrency: 'USD',
      biometricEnabled: false,
      themeMode: 'system',
      createdAt: DateTime.now(),
    );
  }
}
