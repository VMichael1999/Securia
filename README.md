# 🛡️ Securia — Ecosistema de Seguridad Ciudadana y Despacho Policial

**Securia** es una plataforma móvil para responder a emergencias ciudadanas en segundos y coordinar a las unidades policiales (PNP / Serenazgo) en tiempo real.

Está construida con **Flutter**, **BLoC** y **Clean Architecture**, como un monorepo con dos aplicaciones y un paquete compartido:

| Proyecto | Para quién | Qué hace |
|---|---|---|
| **`securia_citizen`** | Ciudadano | Envía un SOS al instante, reporta incidentes con foto y observación, y sigue en vivo la llegada de la patrulla. |
| **`securia_patrol`** | Patrullero / agente | Recibe alertas a pantalla completa y atiende la intervención con un solo botón que avanza por cada paso. |
| **`securia_core`** | Ambas apps | Modelos, reglas del ciclo del incidente, sesión del ciudadano, cálculos geográficos y repositorio reactivo. |

> **Principio de diseño:** en una emergencia nada debe frenar la alerta. *Primero se envía, después se completa.*

---

## 🎨 Identidad visual

| App | Colores | Criterio |
|---|---|---|
| Ciudadano | Azul casi oscuro, verde casi oscuro y blanco | El **rojo** se reserva solo para el SOS, para encontrarlo al instante. |
| Policial | Negro, azul casi oscuro y verde casi oscuro | Pensada para uso nocturno: mapa invertido a modo noche y alto contraste. |

---

## 🚨 App Ciudadano (`securia_citizen`)

### Acceso
- **Iniciar sesión** con DNI (8 dígitos) y celular (9 dígitos). Mensajes claros si el DNI no está registrado o el celular no coincide.
- **Crear cuenta**: nombres y apellidos, DNI, celular y un contacto de emergencia opcional. Al registrarse entra directo al mapa.
- **Cerrar sesión** desde *Mi Perfil*, con confirmación.
- Cada ciudadano reporta con **sus propios datos**.

### Dos formas de pedir ayuda
Ambos controles flotan sobre el mapa, sin paneles que lo tapen.

| | **SOS** | **Reportar incidente** |
|---|---|---|
| Cuándo | Emergencia en curso, sin tiempo | Hay tiempo para describir lo que pasa |
| Cómo | **Mantener presionado 1,5 s** (un anillo se llena y el teléfono vibra; soltar antes cancela) | 1. Elegir qué pasa (obligatorio) · 2. Foto (opcional) · 3. Observación (opcional) · **Enviar reporte** |
| Después | Pregunta opcional *"¿Qué está pasando?"*: la alerta ya salió | Nada más: sale completo |

- La **urgencia se asigna sola** según el tipo (asalto, violencia, incendio o emergencia médica → crítica; robo o accidente → alta; sospechoso → media).
- Mantener presionado evita alertas accidentales en el bolsillo sin agregar pasos.

### Seguimiento de la alerta
Mientras hay una alerta activa, el SOS se reemplaza por un panel con:
- Pasos **Enviada → Asignada → En camino (con minutos de llegada) → En lugar**.
- Botones **Llamar 105**, **Detalles** (agregar foto u observación después de enviar) y **Cancelar** (con confirmación; libera a la patrulla asignada).

### Además
- Mapa **OpenStreetMap** (`flutter_map`) sin claves de Google, con los incidentes del día.
- Historial *Mis Reportes* con detalle y mini mapa.
- Perfil con ficha médica, contacto de emergencia y centrales (105, 116, 106, Serenazgo).

---

## 🚓 App Policial (`securia_patrol`)

- **Alerta entrante a pantalla completa**: qué pasa, dónde, distancia y minutos de llegada, con vibración y sonido. Un botón enorme **ACEPTAR** o **Ignorar** (y aparece la siguiente alerta pendiente).
- **Un solo botón que avanza el estado**, siempre en el mismo lugar:
  **ACEPTAR → EN CAMINO → LLEGUÉ → CONCLUIR**. La sirena se enciende al salir y se apaga al llegar.
- **Cierre rápido**: se elige el resultado (*Detenido, Disuelto, Atendido, Derivado, Falsa alarma*) y una nota opcional; el acta se genera sola.
- **Llamar al ciudadano** a un toque durante toda la intervención.
- **Radar de 3,5 km**: ofrece primero la alerta más urgente; si la unidad está *fuera de servicio* no recibe alertas.
- **Cola de despacho** ordenada por urgencia y luego por distancia.
- Si otra unidad ya tomó el incidente, se indica *"Atendido por…"* y no se puede tomar dos veces.
- Si el ciudadano cancela, la unidad queda libre y recibe el aviso.
- Avisos de estado en la parte superior, para no tapar el botón principal.

---

## 🏗️ Arquitectura del monorepo

```
securia/
├── securia_core/                     # Paquete compartido (Dart/Flutter)
│   ├── lib/
│   │   ├── models/                   # Incidente, patrulla, ciudadano, enums y errores de acceso
│   │   ├── repository/               # ISecuriaRepository e InMemorySecuriaRepository (Streams)
│   │   └── utils/                    # GeoUtils: Haversine, ETA, polilíneas urbanas
│   └── test/                         # Ciclo del incidente, sesión y flujo de despacho
│
├── securia_citizen/                  # App Ciudadano
│   ├── lib/
│   │   ├── app/                      # Tema, textos (strings), utilidades e inyección de dependencias
│   │   └── features/
│   │       ├── auth/                 # Login, registro (Cubit) y componentes de formulario
│   │       ├── home/                 # Navegación inferior; crea el BLoC de la sesión
│   │       ├── map/                  # Mapa, SOS, reporte con detalle y seguimiento
│   │       ├── history/              # Mis Reportes y detalle con mini mapa
│   │       └── profile/              # Perfil, contactos de emergencia y cierre de sesión
│   └── test/                         # BLoC, widgets y flujos completos (login, SOS, reporte)
│
└── securia_patrol/                   # App Policial
    ├── lib/
    │   ├── app/                      # Tema oscuro, textos (strings) y utilidades
    │   └── features/
    │       ├── auth/                 # Inicio de guardia y selección de unidad
    │       ├── shell/                # Navegación con contador de incidentes activos
    │       ├── tactical_map/         # Mapa nocturno, radar, alerta entrante, HUD y cierre rápido
    │       ├── triage/               # Cola de despacho por urgencia y distancia
    │       └── profile/              # Estado de servicio y estadísticas del turno
    └── test/                         # BLoC, componentes y flujo de despacho completo
```

---

## 🚀 Cómo ejecutar

### Requisitos
- Flutter SDK 3.29+ / Dart 3.7+
- Xcode (para iOS) o Android Studio (para Android)

### Instalar dependencias
```bash
cd securia_core && flutter pub get
cd ../securia_citizen && flutter pub get
cd ../securia_patrol && flutter pub get
```

### Ejecutar en simulador de iOS
```bash
cd securia_citizen
flutter run -d "iPhone 17 Pro Max"
```

```bash
cd securia_patrol
flutter run -d "iPhone 17 Pro"
```

### Cuenta de prueba
El ciudadano de prueba está en los datos semilla de `securia_core/lib/repository/in_memory_securia_repository.dart`. También se puede crear una cuenta nueva desde **Crear cuenta**.

---

## 🧪 Pruebas

```bash
cd securia_core && flutter test      # 15 pruebas
cd ../securia_citizen && flutter test   # 36 pruebas
cd ../securia_patrol && flutter test    # 32 pruebas
```

Incluyen pruebas de BLoC, de widgets (tocando y verificando lo que se ve) y de flujos completos: inicio de sesión, registro, cierre de sesión, SOS, reporte con detalle y despacho policial de principio a fin.

---

## ⚠️ Limitaciones actuales

- **Datos en memoria:** `InMemorySecuriaRepository` vive dentro de cada app. Las cuentas nuevas y los incidentes se pierden al cerrarla, y **las dos apps no se comunican entre dispositivos** todavía. Para producción hace falta un backend (por ejemplo Firebase, Supabase o WebSocket) que implemente `ISecuriaRepository`; las apps no necesitan cambios para usarlo.
- **Verificación del celular:** hoy el acceso valida DNI y celular contra los datos registrados. En producción conviene confirmar el celular con un código SMS.

---

## 🔒 Licencia
Desarrollado como solución tecnológica para la seguridad y protección ciudadana.
