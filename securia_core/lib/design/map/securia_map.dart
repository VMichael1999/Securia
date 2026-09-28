import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import '../../models/geo_location.dart';

/// Marcador genérico del mapa (sin depender del SDK de mapas en la UI)
class SecuriaMapMarker {
  final String id;
  final GeoLocation position;
  final gm.BitmapDescriptor? icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final double zIndex;

  const SecuriaMapMarker({
    required this.id,
    required this.position,
    required this.semanticLabel,
    this.icon,
    this.onTap,
    this.zIndex = 0,
  });
}

/// Círculo en metros (radio de cobertura, margen de precisión del GPS)
class SecuriaMapCircle {
  final String id;
  final GeoLocation center;
  final double radiusMeters;
  final Color fill;
  final Color stroke;

  const SecuriaMapCircle({
    required this.id,
    required this.center,
    required this.radiusMeters,
    required this.fill,
    required this.stroke,
  });
}

/// Controla la cámara del mapa desde fuera (recentrar, ir al objetivo)
class SecuriaMapController {
  gm.GoogleMapController? _controller;

  Future<void> moveTo(GeoLocation target, {double zoom = 15}) async {
    await _controller?.animateCamera(
      gm.CameraUpdate.newLatLngZoom(_toLatLng(target), zoom),
    );
  }
}

/// Mapa de Securia sobre Google Maps.
///
/// En pruebas de widgets no existe la vista nativa del mapa: con
/// [debugUseFakeMap] se dibuja un fondo simple con los mismos elementos
/// accesibles, para probar la pantalla sin depender del SDK.
class SecuriaMap extends StatelessWidget {
  final GeoLocation center;
  final double zoom;
  final List<SecuriaMapMarker> markers;
  final List<SecuriaMapCircle> circles;
  final List<GeoLocation> route;
  final Color routeColor;

  /// Estilo JSON de Google Maps (modo nocturno, ocultar comercios, etc.)
  final String? style;
  final SecuriaMapController? controller;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool interactive;

  const SecuriaMap({
    super.key,
    required this.center,
    this.zoom = 15,
    this.markers = const [],
    this.circles = const [],
    this.route = const [],
    this.routeColor = Colors.green,
    this.style,
    this.controller,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.interactive = true,
  });

  @visibleForTesting
  static bool debugUseFakeMap = false;

  @override
  Widget build(BuildContext context) {
    if (debugUseFakeMap) return _FakeMap(markers: markers);

    return gm.GoogleMap(
      initialCameraPosition: gm.CameraPosition(
        target: _toLatLng(center),
        zoom: zoom,
      ),
      style: style,
      padding: padding,
      onMapCreated: (c) => controller?._controller = c,
      onTap: onTap == null ? null : (_) => onTap!(),
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: interactive,
      scrollGesturesEnabled: interactive,
      zoomGesturesEnabled: interactive,
      tiltGesturesEnabled: false,
      markers: {
        for (final m in markers)
          gm.Marker(
            markerId: gm.MarkerId(m.id),
            position: _toLatLng(m.position),
            icon: m.icon ?? gm.BitmapDescriptor.defaultMarker,
            anchor: const Offset(0.5, 0.5),
            zIndexInt: m.zIndex.round(),
            infoWindow: gm.InfoWindow.noText,
            onTap: m.onTap,
          ),
      },
      circles: {
        for (final c in circles)
          gm.Circle(
            circleId: gm.CircleId(c.id),
            center: _toLatLng(c.center),
            radius: c.radiusMeters,
            fillColor: c.fill,
            strokeColor: c.stroke,
            strokeWidth: 2,
          ),
      },
      polylines: {
        if (route.length > 1)
          gm.Polyline(
            polylineId: const gm.PolylineId('route'),
            points: route.map(_toLatLng).toList(),
            color: routeColor,
            width: 5,
            jointType: gm.JointType.round,
            startCap: gm.Cap.roundCap,
            endCap: gm.Cap.roundCap,
          ),
      },
    );
  }
}

gm.LatLng _toLatLng(GeoLocation g) => gm.LatLng(g.latitude, g.longitude);

class _FakeMap extends StatelessWidget {
  final List<SecuriaMapMarker> markers;
  const _FakeMap({required this.markers});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE5E9EC),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final m in markers)
            Semantics(
              label: m.semanticLabel,
              button: m.onTap != null,
              child: GestureDetector(
                onTap: m.onTap,
                child: const SizedBox(width: 1, height: 1),
              ),
            ),
        ],
      ),
    );
  }
}
