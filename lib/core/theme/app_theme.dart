import 'package:flutter/material.dart';

/// Zentrale Theme-Definition der App.
///
/// Bewusst statisch und ohne Logik gehalten – ein einziger Ort, an dem das
/// Erscheinungsbild definiert wird. Erweiterbar um Dark-Theme etc.
abstract final class AppTheme {
  const AppTheme._();

  /// Markenfarbe als Seed für das Material-3-Farbschema.
  static const Color _seedColor = Color(0xFF1565C0);

  /// Helles Theme der App.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      );
}
