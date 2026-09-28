import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/strings/shift_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/widgets/dispatch_flow.dart';
import '../../../../app/widgets/patrol_buttons.dart';
import '../../../../app/widgets/urgency_badge.dart';
import '../../../queue/presentation/views/dispatch_queue_view.dart';
import '../../../tactical_map/presentation/models/dispatch_step.dart';
import '../../../tactical_map/presentation/widgets/dispatch_action_button.dart';
import '../../../tactical_map/presentation/widgets/status_toast.dart';
import '../../../tactical_map/presentation/widgets/telemetry_tile.dart';

/// Catálogo de componentes del sistema "Sereno" (solo en debug).
///
/// Sirve para revisar de un vistazo colores, tipografía y componentes con
/// texto grande o brillo bajo, sin recorrer todo el flujo.
class ComponentCatalogView extends StatelessWidget {
  const ComponentCatalogView({super.key});

  static final _sample = IncidentModel(
    id: 'catalogo',
    type: IncidentType.asalto,
    title: 'Asalto',
    description: '',
    location: const GeoLocation(
      latitude: -12.0920,
      longitude: -77.0300,
      address: 'Calle Las Begonias 441, San Isidro',
    ),
    citizenId: 'c',
    citizenName: 'Ciudadana',
    citizenPhone: '900 000 001',
    timestamp: DateTime(2026, 9, 27, 21, 13),
    urgency: UrgencyLevel.critica,
  );

  @override
  Widget build(BuildContext context) {
    const unit = PatrolUnitModel(
      id: 'u',
      unitCode: 'PL-402',
      officerName: 'S3 C. Ramírez',
      phone: '900 000 101',
      location: GeoLocation(
        latitude: -12.0835,
        longitude: -77.0378,
        address: '',
      ),
    );

    return Scaffold(
      backgroundColor: PatrolColors.background,
      appBar: AppBar(
        backgroundColor: PatrolColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(ShiftStrings.catalog, style: PatrolTypography.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SecuriaSpace.md),
        children: [
          const _Section('Colores: un solo trabajo cada uno'),
          const _Swatch(PatrolColors.background, 'Fondo', '#000000'),
          const _Swatch(PatrolColors.card, 'Tarjetas', '#0A1426'),
          const _Swatch(PatrolColors.border, 'Bordes', '#1E2F4D'),
          const _Swatch(
            PatrolColors.action,
            'Acción principal y ayuda en marcha',
            '#34D399',
          ),
          const _Swatch(
            PatrolColors.criticalFill,
            'Urgencia crítica (relleno)',
            '#DC2626',
          ),
          const _Swatch(PatrolColors.high, 'Urgencia alta', '#F59E0B'),
          const _Swatch(PatrolColors.inkMuted, 'Texto secundario', '#94A3B8'),

          const _Section('Tipografía'),
          Text('Asalto a mano armada', style: PatrolTypography.display),
          Text('Cola de despacho', style: PatrolTypography.headline),
          Text('Título de ficha', style: PatrolTypography.titleLarge),
          Text(
            'Texto de lectura en tarjetas',
            style: PatrolTypography.bodyMedium,
          ),
          Text('Etiqueta pequeña', style: PatrolTypography.caption),
          Text(
            'PL-402 · 1.2 km · 4 min',
            style: PatrolTypography.mono(size: 18),
          ),

          const _Section('Urgencia sin depender del color'),
          const Wrap(
            spacing: SecuriaSpace.xs,
            runSpacing: SecuriaSpace.xs,
            children: [
              UrgencyBadge(urgency: UrgencyLevel.critica),
              UrgencyBadge(urgency: UrgencyLevel.alta),
              UrgencyBadge(urgency: UrgencyLevel.media),
              UrgencyBadge(urgency: UrgencyLevel.baja),
            ],
          ),
          const SizedBox(height: SecuriaSpace.sm),
          const SizedBox(
            height: 44,
            child: Row(
              children: [
                UrgencyBar(urgency: UrgencyLevel.critica),
                SizedBox(width: SecuriaSpace.md),
                UrgencyBar(urgency: UrgencyLevel.alta),
                SizedBox(width: SecuriaSpace.md),
                UrgencyBar(urgency: UrgencyLevel.media),
              ],
            ),
          ),

          const _Section('Pasos de la intervención'),
          for (var i = 0; i < 4; i++) ...[
            DispatchFlow(current: i),
            const SizedBox(height: SecuriaSpace.xs),
          ],

          const _Section('Botones (72 y 64 px)'),
          for (final step in DispatchStep.values.where(
            (s) => s != DispatchStep.none,
          )) ...[
            DispatchActionButton(step: step, onPressed: () {}),
            const SizedBox(height: SecuriaSpace.xs),
          ],
          const PrimaryActionButton(label: DispatchStrings.resolveConfirm),
          const SizedBox(height: SecuriaSpace.xs),
          SecondaryActionButton(
            label: ShiftStrings.endShift,
            icon: Icons.logout_rounded,
            onPressed: () {},
          ),

          const _Section('Telemetría'),
          const Row(
            children: [
              Expanded(
                child: TelemetryTile(
                  label: DispatchStrings.distanceLabel,
                  value: '1.2 km',
                ),
              ),
              SizedBox(width: SecuriaSpace.xs),
              Expanded(
                child: TelemetryTile(
                  label: DispatchStrings.etaLabel,
                  value: '4 min',
                ),
              ),
            ],
          ),
          const SizedBox(height: SecuriaSpace.xs),
          const TelemetryStrip(
            items: [
              (DispatchStrings.distanceLabel, '0.8 km'),
              (DispatchStrings.etaLabel, '3 min'),
              (DispatchStrings.arrivalTimeLabel, '21:19'),
            ],
          ),

          const _Section('Fila de la cola'),
          QueueRow(
            incident: _sample,
            patrol: unit,
            now: DateTime(2026, 9, 27, 21, 15),
            onTap: () {},
          ),
          QueueRow(
            incident: _sample.copyWith(
              type: IncidentType.sospechoso,
              urgency: UrgencyLevel.media,
              assignedPatrolId: 'otra',
              assignedPatrolCode: 'MOTO-08',
            ),
            patrol: unit,
            now: DateTime(2026, 9, 27, 21, 15),
            onTap: () {},
          ),

          const _Section('Aviso'),
          const StatusToast(message: DispatchStrings.arrived),
          const SizedBox(height: SecuriaSpace.xxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: SecuriaSpace.xl,
        bottom: SecuriaSpace.sm,
      ),
      child: Text(title, style: PatrolTypography.caption),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String role;
  final String hex;

  const _Swatch(this.color, this.role, this.hex);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SecuriaSpace.xxs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(SecuriaRadius.sm),
              border: Border.all(color: PatrolColors.border),
            ),
          ),
          const SizedBox(width: SecuriaSpace.sm),
          Expanded(child: Text(role, style: PatrolTypography.bodyMedium)),
          Text(
            hex,
            style: PatrolTypography.mono(
              size: 12,
              color: PatrolColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
