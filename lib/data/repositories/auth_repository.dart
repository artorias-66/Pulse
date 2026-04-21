import '../../core/storage/local_storage.dart';
import '../models/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
}

class LocalAuthRepository implements AuthRepository {
  static const _demoPassword = 'Demo@123';

  @override
  Future<AuthUser?> getCurrentUser() async {
    return LocalStorage.loadCurrentUser();
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = LocalStorage.loadAuthUsers();

    final account = users.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u != null && u['email']?.toString().toLowerCase() == normalizedEmail,
          orElse: () => null,
        );

    if (account == null) {
      throw Exception('No account found for this email. Please sign up first.');
    }

    final savedPassword = account['password']?.toString() ?? '';
    if (savedPassword != password) {
      throw Exception('Incorrect password. Try Demo@123 for demo account.');
    }

    final user = AuthUser.fromMap(account);
    await LocalStorage.saveCurrentUser(user);
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = LocalStorage.loadAuthUsers();

    final exists = users.any(
      (u) => u['email']?.toString().toLowerCase() == normalizedEmail,
    );
    if (exists) {
      throw Exception('An account with this email already exists. Please sign in.');
    }

    final user = AuthUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: normalizedEmail,
      displayName: displayName.trim().isEmpty ? 'Investor' : displayName.trim(),
    );

    users.add({
      ...user.toMap(),
      'password': password,
    });

    await LocalStorage.saveAuthUsers(users);
    await LocalStorage.saveCurrentUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await LocalStorage.clearCurrentUser();
  }

  static Future<void> seedDemoAccount() async {
    final users = LocalStorage.loadAuthUsers();
    final demoExists = users.any(
      (u) => u['email']?.toString().toLowerCase() == 'demo@pulse.app',
    );

    if (!demoExists) {
      users.add({
        'id': 'demo-user',
        'email': 'demo@pulse.app',
        'displayName': 'Demo User',
        'password': _demoPassword,
      });
      await LocalStorage.saveAuthUsers(users);
    }
  }
}
