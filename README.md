# 🛡️ Securia — Ecosistema Integral de Seguridad Ciudadana y Despacho Policial PNP

**Securia** es una plataforma móvil reactiva diseñada para optimizar la respuesta ante emergencias ciudadanas y la coordinación táctica policial en tiempo real. 

El ecosistema está construido con **Flutter** y **Clean Architecture**, compuesto por dos aplicaciones móviles independientes conectadas mediante un paquete central reactivo de georreferenciación y cálculo geodésico:

1. **`securia_citizen`**: Aplicación para el ciudadano. Permite emitir alertas SOS inmediatas con evidencia fotográfica y nivel de urgencia, visualizar un mapa táctico con incidentes del día, seguir en vivo el estado del despacho policial ("Buscando patrulla...", "Patrulla en camino", "En el lugar") y consultar su perfil con datos verificados y contactos de auxilio.
2. **`securia_patrol`**: Terminal táctica para patrulleros y agentes de seguridad (PNP / Serenazgo). Incluye mapa táctico con modo oscuro, perímetro de radar de cobertura (3.5 km), detección de proximidad con alertas sonoras/visuales, balizas animadas de incidentes, **trazado de polilíneas urbanas en vivo** desde la patrulla hacia el objetivo, telemetría (distancia y ETA) y gestión del ciclo de intervención (Aceptar -> En camino con sirena -> En el lugar -> Concluir con reporte policial).
3. **`securia_core`**: Paquete compartido que encapsula modelos de dominio, enums de ciclo de vida, utilidades geodésicas (Haversine, cálculo de ETA a velocidad urbana, generador de polilíneas realistas que siguen cuadrículas de calles) y el contrato de persistencia reactiva por Streams.

---

## 🏗️ Arquitectura del Monorepo

```
securia/
├── securia_core/                     # Paquete Dart de lógica de negocio y geolocalización
│   ├── lib/
│   │   ├── models/                   # IncidentModel, PatrolUnitModel, CitizenProfileModel, Enums
│   │   ├── repository/               # ISecuriaRepository & InMemorySecuriaRepository (Streams)
│   │   └── utils/                    # GeoUtils (Haversine, ETA, Polilíneas urbanas)
│   └── test/                         # Pruebas unitarias e integración de ecosistema
│
├── securia_citizen/                  # App Ciudadano (Android / iOS / Web)
│   ├── lib/
│   │   ├── app/                      # Inyección de dependencias, tema y estilo
│   │   └── features/
│   │       ├── auth/                 # Inicio de sesión por DNI y teléfono
│   │       ├── home/                 # Shell de navegación inferior (3 pestañas)
│   │       ├── map/                  # Mapa OpenStreetMap, Botón SOS pulsante, Diálogo de reporte con foto
│   │       ├── history/              # Historial "Mis Reportes" y Vista Detalle con mini-mapa
│   │       └── profile/              # Perfil ciudadano, contactos de emergencia y centrales (105, 116, Serenazgo)
│   └── test/                         # Smoke test de pantalla de inicio y login
│
└── securia_patrol/                   # App Patrullero / PNP (Android / iOS / Web)
    ├── lib/
    │   ├── app/                      # Tema táctico nocturno de alta visibilidad, BLoC provider
    │   └── features/
    │       ├── auth/                 # Check-in de guardia, código de patrulla (PL-402) y sector
    │       ├── shell/                # Shell táctico con badge de incidentes activos en cola
    │       ├── tactical_map/         # Mapa táctico OSM, Radar de 3.5 km, Polilínea de intercepción, Sirena y HUD
    │       ├── triage/               # Cola de incidentes clasificados por urgencia y distancia
    │       └── profile/              # Estadísticas de turno, telemetría y estado de servicio
    └── test/                         # Smoke test de terminal táctica
```

---

## 🌟 Características Destacadas

### 🚨 Aplicación Ciudadana (`securia_citizen`)
- **Botón SOS de Respuesta Rápida**: Botón flotante animado de alta notoriedad que abre el diálogo de emisión de alerta.
- **Reporte Multimodal**: Selector de tipo de emergencia (Asalto, Robo, Emergencia Médica, Accidente, Incendio, etc.), selector de urgencia (Crítica, Alta, Media, Baja), descripción y captura de evidencia fotográfica (cámara o galería).
- **Mapa Interactivo Libre (OpenStreetMap)**: Utiliza `flutter_map: ^8.3.2` sin necesidad de claves de Google Maps. Marcadores con colores distintivos por tipo de incidente y filtros ("Hoy" vs "Todos", filtro por categoría).
- **Banner de Estado en Tiempo Real**: Notificación persistente superior que informa el avance del auxilio policial en vivo.
- **Detalle de Incidente con Mini-mapa**: Visualización detallada de la emergencia con mapa interactivo centrado en las coordenadas del reporte.

### 🚓 Aplicación de Patrullaje (`securia_patrol`)
- **Radar Táctico de Proximidad**: Perímetro circular visual de 3.5 km centrado en la patrulla. Detecta emergencias activas y despliega alertas HUD flotantes.
- **Balizas Animadas**: Marcadores pulsantes en el mapa con frecuencia ajustada según el nivel de urgencia.
- **Ruta de Intercepción Urbana**: Genera polilíneas tácticas en color cian neón / rojo alerta que simulan la trayectoria real sobre calles de la ciudad, calculando distancia y tiempo estimado de llegada (ETA) en tiempo real.
- **Control de Sirena y Código Rojo**: Botón táctico para activar código policial con pulsación estroboscópica roja y azul.
- **Ciclo Completo de Despacho**:
  1. *Aceptar Despacho*: Asigna la unidad a la emergencia.
  2. *En Camino*: Activa sirenas y traza la ruta hacia el lugar.
  3. *En el Lugar*: Confirma el arribo del personal.
  4. *Concluir Intervención*: Registra el acta policial y finaliza el incidente.

---

## 🚀 Instrucciones de Ejecución

### Prerrequisitos
- Flutter SDK 3.29+ / Dart 3.7+
- macOS, Linux o Windows

### 1. Clonar y verificar paquetes
```bash
cd securia/securia_core
flutter pub get
flutter test

cd ../securia_citizen
flutter pub get
flutter run -d chrome # o emulador iOS / Android

cd ../securia_patrol
flutter pub get
flutter run -d chrome # o dispositivo físico / emulador
```

---

## 🧪 Pruebas Automatizadas

Todos los paquetes cuentan con cobertura de pruebas unitarias, de widgets y de integración end-to-end:

```bash
# Probar el paquete core y la integración reactiva
cd securia/securia_core && flutter test

# Probar la aplicación ciudadana
cd ../securia_citizen && flutter test

# Probar la aplicación de patrullaje táctico
cd ../securia_patrol && flutter test
```

---

## 🔒 Licencia
Desarrollado como solución tecnológica para la seguridad y protección ciudadana.
