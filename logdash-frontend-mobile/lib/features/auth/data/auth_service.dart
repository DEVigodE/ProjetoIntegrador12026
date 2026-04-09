import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';

const _keycloakBase = 'http://10.0.2.2:8080';
const _realm = 'logdash';
const _clientId = 'logdash-webapp';

class AuthService {
  final _dio = Dio(BaseOptions(baseUrl: _keycloakBase));

  AsyncResult<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/realms/$_realm/protocol/openid-connect/token',
        data: {
          'grant_type': 'password',
          'client_id': _clientId,
          'username': username,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return Success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['error_description'] ?? 'Erro ao fazer login';
      return Failure(Exception(msg.toString()));
    }
  }

  AsyncResult<String> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // 1. Obter token de admin via realm master
      final tokenResp = await _dio.post(
        '/realms/master/protocol/openid-connect/token',
        data: {
          'grant_type': 'password',
          'client_id': 'admin-cli',
          'username': 'admin',
          'password': 'admin',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final adminToken = tokenResp.data['access_token'] as String;

      // 2. Criar usuário no realm logdash
      final createResp = await _dio.post(
        '/admin/realms/$_realm/users',
        data: {
          'username': username,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'enabled': true,
          'credentials': [
            {'type': 'password', 'value': password, 'temporary': false},
          ],
        },
        options: Options(
          headers: {'Authorization': 'Bearer $adminToken'},
          contentType: 'application/json',
        ),
      );

      // 3. Extrair ID do usuário criado pelo header Location
      final location = createResp.headers.value('location') ?? '';
      final userId = location.split('/').last;

      // 4. Buscar detalhes da role CLIENT
      final roleResp = await _dio.get(
        '/admin/realms/$_realm/roles/CLIENT',
        options: Options(headers: {'Authorization': 'Bearer $adminToken'}),
      );
      final clientRole = roleResp.data as Map<String, dynamic>;

      // 5. Atribuir a role CLIENT ao novo usuário
      await _dio.post(
        '/admin/realms/$_realm/users/$userId/role-mappings/realm',
        data: [clientRole],
        options: Options(
          headers: {'Authorization': 'Bearer $adminToken'},
          contentType: 'application/json',
        ),
      );

      return Success(userId);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['errorMessage'] ?? 'Erro ao registrar usuário';
      return Failure(Exception(msg.toString()));
    }
  }
}
