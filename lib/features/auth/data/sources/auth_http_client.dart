import 'package:http/http.dart' as http;

/// Interceptor-Client für ALLE authentifizierten Anfragen.
///
/// Hängt an jede ausgehende Anfrage `Authorization: Bearer <token>` (und
/// `Accept: application/json`) und meldet ein serverseitiges **HTTP 401**
/// (Token ungültig/abgelaufen/widerrufen) zentral über [onUnauthorized] – die
/// einzige Stelle der App, die das 401-Handling kennt. Der Aufrufer (App)
/// verwirft daraufhin die Session und landet wieder am Login.
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient({
    required this.token,
    this.onUnauthorized,
    http.Client? inner,
  }) : _inner = inner ?? http.Client();

  /// Bearer-Token der aktiven Session.
  final String token;

  /// Wird beim ersten 401 dieser Client-Instanz aufgerufen (genau einmal).
  final void Function()? onUnauthorized;

  final http.Client _inner;
  bool _notified = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer $token';
    request.headers.putIfAbsent('Accept', () => 'application/json');
    final response = await _inner.send(request);
    if (response.statusCode == 401 && !_notified) {
      _notified = true;
      onUnauthorized?.call();
    }
    return response;
  }

  @override
  void close() => _inner.close();
}
