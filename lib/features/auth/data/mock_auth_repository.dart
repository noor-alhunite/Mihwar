import '../../../core/role.dart';
import '../models/auth_user.dart';

class MockAuthRepository {
  static const List<_MockCredential> _users = [
    _MockCredential(
      id: 1001,
      password: '1234',
      name: 'Ahmed Kareem',
      role: UserRole.driver,
      areaId: 1,
    ),
    _MockCredential(
      id: 1006,
      password: '1234',
      name: 'Training Driver',
      role: UserRole.driver,
      areaId: 1,
    ),
    _MockCredential(
      id: 2001,
      password: '1234',
      name: 'Sara Hassan',
      role: UserRole.supervisor,
      areaId: 1,
    ),
    _MockCredential(
      id: 3001,
      password: '1234',
      name: 'Omar Nabil',
      role: UserRole.governorateManager,
      areaId: 0,
    ),
  ];

  Future<AuthUser?> login({
    required String idInput,
    required String passwordInput,
  }) async {
    final int? parsedId = int.tryParse(idInput.trim());
    if (parsedId == null) {
      return null;
    }

    final _MockCredential? match = _users.cast<_MockCredential?>().firstWhere(
          (user) => user!.id == parsedId && user.password == passwordInput.trim(),
          orElse: () => null,
        );

    if (match == null) {
      return null;
    }

    return AuthUser(
      id: match.id,
      name: match.name,
      role: match.role,
      areaId: match.areaId,
    );
  }

  /// Returns the demo user for the given id, or null if not found.
  /// Used by the role-entry screen to sign in without credentials.
  AuthUser? getUserById(int id) {
    final _MockCredential? match = _users.cast<_MockCredential?>().firstWhere(
          (user) => user!.id == id,
          orElse: () => null,
        );
    if (match == null) return null;
    return AuthUser(
      id: match.id,
      name: match.name,
      role: match.role,
      areaId: match.areaId,
    );
  }
}

class _MockCredential {
  const _MockCredential({
    required this.id,
    required this.password,
    required this.name,
    required this.role,
    required this.areaId,
  });

  final int id;
  final String password;
  final String name;
  final UserRole role;
  final int areaId;
}
