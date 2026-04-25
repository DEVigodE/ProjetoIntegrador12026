import 'package:jwt_decoder/jwt_decoder.dart';

class UserModel {
  final String id;
  final String username;
  final String? name;
  final String? email;
  final List<String> roles;
  final String accessToken;
  final String refreshToken;

  const UserModel({
    required this.id,
    required this.username,
    this.name,
    this.email,
    required this.roles,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    final claims = JwtDecoder.decode(accessToken);
    final realmAccess = claims['realm_access'] as Map<String, dynamic>?;
    final roles = (realmAccess?['roles'] as List<dynamic>?)
            ?.map((r) => r.toString())
            .toList() ??
        [];
    return UserModel(
      id: claims['sub'] as String? ?? '',
      username: claims['preferred_username'] as String? ?? '',
      name: claims['name'] as String?,
      email: claims['email'] as String?,
      roles: roles,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  String get displayName => name ?? username;

  bool get isClient => roles.contains('CLIENT');
  bool get isAdmin => roles.contains('ADMIN');
  bool get isOperator => roles.contains('OPERATOR');
  bool get isDispatcher => roles.contains('DISPATCHER');
  bool get isCourier => roles.contains('COURIER');
  bool get isStaff => isAdmin || isOperator || isDispatcher;
}
