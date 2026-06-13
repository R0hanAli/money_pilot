class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String preferredCurrency;
  final bool biometricEnabled;
  final String themeMode;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.preferredCurrency,
    required this.biometricEnabled,
    required this.themeMode,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? preferredCurrency,
    bool? biometricEnabled,
    String? themeMode,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
