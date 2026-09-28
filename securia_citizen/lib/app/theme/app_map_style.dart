/// Estilos de Google Maps para la app ciudadana
class AppMapStyle {
  AppMapStyle._();

  /// Mapa tranquilo: oculta comercios, transporte y puntos de interés para que
  /// ningún ícono de colores compita con el SOS ni con los reportes.
  static const String calm = '''
[
  {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  {"featureType": "poi.park", "stylers": [{"visibility": "simplified"}]},
  {"featureType": "poi.park", "elementType": "labels", "stylers": [{"visibility": "off"}]},
  {"featureType": "transit", "stylers": [{"visibility": "off"}]},
  {"featureType": "road", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#F3F5F6"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#CFDCE6"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#FFFFFF"}]},
  {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#FFFFFF"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#E3E8EC"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#4A5A6E"}]}
]
''';
}
