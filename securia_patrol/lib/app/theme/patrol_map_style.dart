/// Estilos de Google Maps para la app policial
class PatrolMapStyle {
  PatrolMapStyle._();

  /// Mapa nocturno de verdad (no tiles invertidos): manzanas en azul casi
  /// negro, calles en azul apagado y nombres de calles legibles. Oculta
  /// comercios y transporte para que solo destaquen incidentes y la ruta.
  static const String night = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#0A1426"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#94A3B8"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#050811"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#1E2F4D"}]},
  {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#DDE4EE"}]},
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "stylers": [{"visibility": "simplified"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#0B1F2A"}]},
  {"featureType": "poi.park", "elementType": "labels", "stylers": [{"visibility": "off"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#16294A"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#0A1426"}]},
  {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#1E3558"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#274269"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#B4C0D0"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#050811"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#4A5A6E"}]}
]
''';
}
