import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firestore_datasource.dart';
import '../datasources/local_database.dart';
import '../models/user_model.dart';

extension UserModelX on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      email: email,
      preferredCurrency: preferredCurrency,
      biometricEnabled: biometricEnabled,
      themeMode: themeMode,
      createdAt: createdAt,
    );
  }
}

extension UserEntityX on UserEntity {
  UserModel toModel() {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      preferredCurrency: preferredCurrency,
      biometricEnabled: biometricEnabled,
      themeMode: themeMode,
      createdAt: createdAt,
    );
  }
}

class AuthRepositoryImpl implements AuthRepository {
  final FirestoreDataSource _firestoreDataSource;
  final LocalDatabase _localDatabase;

  AuthRepositoryImpl({
    required FirestoreDataSource firestoreDataSource,
    required LocalDatabase localDatabase,
  })  : _firestoreDataSource = firestoreDataSource,
        _localDatabase = localDatabase;

  @override
  bool get isAuthenticated =>
      FirebaseAuth.instance.currentUser != null;

  @override
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;
    final localUser = await _localDatabase.getUser(firebaseUser.uid);
    if (localUser != null) return localUser.toEntity();
    final remoteUser = await _firestoreDataSource.getUser(firebaseUser.uid);
    if (remoteUser != null) {
      await _localDatabase.insertUser(remoteUser);
      return remoteUser.toEntity();
    }
    return null;
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final localUser = await _localDatabase.getUser(uid);
    if (localUser != null) return localUser.toEntity();
    final remoteUser = await _firestoreDataSource.getUser(uid);
    if (remoteUser != null) {
      await _localDatabase.insertUser(remoteUser);
      return remoteUser.toEntity();
    }
    final fallback = UserModel.create(
      id: uid,
      fullName: credential.user?.displayName ?? '',
      email: email,
    );
    await _localDatabase.insertUser(fallback);
    await _firestoreDataSource.saveUser(fallback);
    return fallback.toEntity();
  }

  @override
  Future<UserEntity> signUp(
      String email, String password, String fullName) async {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final newUser = UserModel.create(
      id: credential.user!.uid,
      fullName: fullName,
      email: email,
    );
    await _localDatabase.insertUser(newUser);
    await _firestoreDataSource.saveUser(newUser);
    return newUser.toEntity();
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    final localUser = await _localDatabase.getUser(userId);
    if (localUser != null) return localUser.toEntity();
    final remoteUser = await _firestoreDataSource.getUser(userId);
    if (remoteUser != null) {
      await _localDatabase.insertUser(remoteUser);
      return remoteUser.toEntity();
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    final model = user.toModel();
    await _localDatabase.updateUser(model);
    await _firestoreDataSource.saveUser(model);
  }
}
