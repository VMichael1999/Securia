import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Genera íconos de marcador circulares (ícono Material sobre un color)
/// para Google Maps, que solo acepta imágenes. Se cachean por estilo.
class MapMarkerIcons {
  MapMarkerIcons._();

  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> circle({
    required IconData icon,
    required Color fill,
    Color iconColor = Colors.white,
    Color? ring,
    double size = 40,
    double devicePixelRatio = 3,
  }) async {
    final key =
        '${icon.codePoint}-${fill.toARGB32()}-${iconColor.toARGB32()}-${ring?.toARGB32()}-$size';
    final cached = _cache[key];
    if (cached != null) return cached;

    final px = size * devicePixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(px / 2, px / 2);
    final ringWidth = ring == null ? 0.0 : px * 0.09;

    if (ring != null) {
      canvas.drawCircle(center, px / 2, Paint()..color = ring);
    }
    canvas.drawCircle(center, px / 2 - ringWidth, Paint()..color = fill);

    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: px * 0.5,
          color: iconColor,
        ),
      )
      ..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(px.round(), px.round());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: size,
      height: size,
    );
    return _cache[key] = descriptor;
  }
}
