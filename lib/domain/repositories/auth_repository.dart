import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(String email, String password, String fullName);
  Future<void> signOut();
  Future<void> updateUserProfile(UserEntity user);
  Future<UserEntity?> getUserProfile(String userId);
  bool get isAuthenticated;
  String? get currentUserId;
}
