import 'package:flutter/material.dart';
import '../models/enums.dart';

/// Fuentes empaquetadas en securia_core (no dependen de internet).
///
/// Plus Jakarta Sans para todo el texto y JetBrains Mono solo para cifras,
/// distancias, tiempos y códigos de unidad, con cifras tabulares para que los
/// números no "bailen" al actualizarse.
class SecuriaFonts {
  SecuriaFonts._();

  static const String package = 'securia_core';
  static const String sans = 'PlusJakartaSans';
  static const String mono = 'JetBrainsMono';

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// Estilo monoespaciado para telemetría (distancia, llegada, códigos)
  static TextStyle monoStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: mono,
      package: package,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: tabular,
    );
  }
}

/// Escala de espaciado (múltiplos de 4)
class SecuriaSpace {
  SecuriaSpace._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Radios de esquina
class SecuriaRadius {
  SecuriaRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double sheet = 28;
  static const double pill = 999;
}

/// Áreas de toque mínimas
class SecuriaTouch {
  SecuriaTouch._();

  /// Mínimo de accesibilidad para el ciudadano
  static const double min = 48;

  /// Mínimo en la app policial (se toca con guantes o en movimiento)
  static const double patrol = 64;

  /// Acción principal del patrullero (Aceptar, siguiente paso)
  static const double primaryAction = 72;
}

/// Duraciones y curvas del motion. Todas respetan "reducir movimiento".
class SecuriaMotion {
  SecuriaMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// Tiempo que hay que mantener el SOS para enviarlo
  static const Duration sosHold = Duration(milliseconds: 1500);

  /// Al soltar antes de tiempo, el anillo se vacía rápido
  static const Duration sosRelease = Duration(milliseconds: 250);

  static const Curve standard = Curves.easeOutCubic;

  /// [duration], o cero si el sistema pide reducir animaciones
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
          ? Duration.zero
          : duration;
}

/// Cómo se marca una urgencia sin depender del color:
/// crítica en relleno sólido, alta en contorno, media en línea punteada.
enum UrgencyMark {
  solid,
  outline,
  dashed,
  none;

  static UrgencyMark of(UrgencyLevel urgency) => switch (urgency) {
        UrgencyLevel.critica => UrgencyMark.solid,
        UrgencyLevel.alta => UrgencyMark.outline,
        UrgencyLevel.media => UrgencyMark.dashed,
        UrgencyLevel.baja => UrgencyMark.none,
      };
}
