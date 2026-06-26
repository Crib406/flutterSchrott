import 'package:connectivity_plus/connectivity_plus.dart';

/// Kapselt `connectivity_plus` und liefert den Online-Status als einfaches
/// `bool`. Einzige Stelle der App, die das Plugin kennt.
class ConnectivityService {
  const ConnectivityService();

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  /// Aktueller Online-Status.
  Future<bool> isOnline() async {
    return _isOnline(await Connectivity().checkConnectivity());
  }

  /// Liefert bei jeder Verbindungsänderung den neuen Online-Status.
  Stream<bool> get onlineChanges =>
      Connectivity().onConnectivityChanged.map(_isOnline);
}
