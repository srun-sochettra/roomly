/// Android emulator: http://10.0.2.2:8000/api
/// Real phone: http://<your-laptop-LAN-IP>:8000/api, with `php artisan serve --host=0.0.0.0`
/// Override with: flutter run --dart-define=API_URL=http://192.168.1.20:8000/api
class AppConfig {
  static const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000/api');
}
