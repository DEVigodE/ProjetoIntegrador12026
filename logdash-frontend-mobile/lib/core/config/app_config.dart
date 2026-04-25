/// Configuração central de URLs da aplicação.
///
/// Por padrão usa `10.0.2.2` (emulador Android).
/// Para rodar em dispositivo físico, passe o IP da sua máquina via dart-define:
///
///   flutter run --dart-define=API_HOST=192.168.1.100
///
class AppConfig {
  AppConfig._();

  static const _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '10.0.2.2',
  );

  static const keycloakBaseUrl = 'http://$_host:8080';
  static const backendBaseUrl = 'http://$_host:8081';
  static const stompUrl = 'ws://$_host:8081/ws/websocket';
}
