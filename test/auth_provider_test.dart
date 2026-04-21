import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/data/models/auth_user.dart';
import 'package:pulse/data/repositories/auth_repository.dart';
import 'package:pulse/providers/app_services_provider.dart';
import 'package:pulse/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  AuthUser? _currentUser;

  @override
  Future<AuthUser?> getCurrentUser() async => _currentUser;

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    _currentUser = AuthUser(id: '1', email: email, displayName: 'User');
    return _currentUser!;
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _currentUser = AuthUser(id: '2', email: email, displayName: displayName);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

void main() {
  test('auth provider signs in and signs out', () async {
    final fakeRepo = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    await _waitForBootstrap(container);

    expect(container.read(authProvider).status, AuthStatus.unauthenticated);

    await container.read(authProvider.notifier).signIn(
          email: 'demo@pulse.app',
          password: 'Demo@123',
        );

    final signedIn = container.read(authProvider);
    expect(signedIn.status, AuthStatus.authenticated);
    expect(signedIn.user?.email, 'demo@pulse.app');

    await container.read(authProvider.notifier).signOut();
    expect(container.read(authProvider).status, AuthStatus.unauthenticated);
  });
}

Future<void> _waitForBootstrap(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    final status = container.read(authProvider).status;
    if (status != AuthStatus.initializing) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  fail('Auth provider bootstrap did not complete in time.');
}
