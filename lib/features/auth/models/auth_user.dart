import '../../../core/role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.role,
    required this.areaId,
  });

  final int id;
  final String name;
  final UserRole role;
  final int areaId;
}
