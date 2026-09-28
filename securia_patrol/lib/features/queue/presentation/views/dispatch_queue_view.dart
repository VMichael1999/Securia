import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/strings/queue_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/widgets/urgency_badge.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_event.dart';
import '../../../tactical_map/presentation/bloc/patrol_state.dart';

/// Cola de despacho: primero la urgencia y luego la distancia.
///
/// La urgencia se ve en la barra lateral (sólida, contorno o punteada) y en la
/// palabra; la distancia va a la derecha en monoespaciada. Lo que atiende otra
/// unidad queda atenuado.
class DispatchQueueView extends StatelessWidget {
  /// Lleva al mapa después de elegir un incidente
  final VoidCallback? onOpenMap;

  /// Reloj inyectable para el "hace N min"
  final DateTime Function()? clock;

  const DispatchQueueView({super.key, this.onOpenMap, this.clock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PatrolBloc, PatrolState>(
          builder: (context, state) {
            final queue = state.triageQueue;
            final now = (clock ?? DateTime.now)();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    SecuriaSpace.md + 2,
                    SecuriaSpace.md,
                    SecuriaSpace.md + 2,
                    SecuriaSpace.xs,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            QueueStrings.title,
                            style: PatrolTypography.headline,
                          ),
                        ),
                        const SizedBox(height: SecuriaSpace.xxs),
                        Text(
                          QueueStrings.subtitle,
                          style: PatrolTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isLoading)
                  const SliverToBoxAdapter(child: _QueueSkeleton())
                else if (queue.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyQueue(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SecuriaSpace.md + 2,
                    ),
                    sliver: SliverList.separated(
                      itemCount: queue.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            height: 1,
                            color: PatrolColors.border,
                          ),
                      itemBuilder: (context, i) {
                        final incident = queue[i];
                        return QueueRow(
                          incident: incident,
                          patrol: state.currentPatrol,
                          now: now,
                          onTap: () {
                            context.read<PatrolBloc>().add(
                              PatrolSelectIncident(incident),
                            );
                            onOpenMap?.call();
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Fila de la cola de despacho
class QueueRow extends StatelessWidget {
  final IncidentModel incident;
  final PatrolUnitModel patrol;
  final DateTime now;
  final VoidCallback onTap;

  const QueueRow({
    super.key,
    required this.incident,
    required this.patrol,
    required this.now,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = incident.assignedPatrolId == patrol.id;
    final takenByOther = !isMine && incident.assignedPatrolId != null;
    final distance = GeoUtils.formatDistance(
      GeoUtils.calculateDistanceKm(patrol.location, incident.location),
    );
    final urgencyColor = PatrolColors.urgency(incident.urgency);

    final (String subtitle, String status, Color statusColor) =
        isMine
            ? (
              incident.location.address,
              QueueStrings.mine,
              PatrolColors.action,
            )
            : takenByOther
            ? (
              DispatchStrings.takenBy(incident.assignedPatrolCode ?? ''),
              QueueStrings.cannotTake,
              PatrolColors.inkMuted,
            )
            : (
              incident.location.address,
              QueueStrings.urgencyAgo(
                incident.urgency.label,
                DispatchStrings.ago(now.difference(incident.timestamp)),
              ),
              urgencyColor,
            );

    return Opacity(
      opacity: takenByOther ? 0.45 : 1,
      child: Semantics(
        button: true,
        hint: QueueStrings.rowHint(incident.type.title.toLowerCase()),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SecuriaTouch.patrol),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SecuriaSpace.sm),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UrgencyBar(urgency: incident.urgency),
                    const SizedBox(width: SecuriaSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            incident.type.title,
                            style: PatrolTypography.label,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PatrolTypography.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            status,
                            style: PatrolTypography.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: SecuriaSpace.sm),
                    Text(distance, style: PatrolTypography.mono(size: 15)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SecuriaSpace.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.task_alt_rounded,
            size: 48,
            color: PatrolColors.inkMuted,
          ),
          const SizedBox(height: SecuriaSpace.md),
          Text(
            QueueStrings.emptyTitle,
            textAlign: TextAlign.center,
            style: PatrolTypography.titleMedium,
          ),
          const SizedBox(height: SecuriaSpace.xs),
          Text(
            QueueStrings.emptyBody,
            textAlign: TextAlign.center,
            style: PatrolTypography.bodyMedium.copyWith(
              color: PatrolColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filas de carga con la misma forma que la cola real
class _QueueSkeleton extends StatelessWidget {
  const _QueueSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: PatrolColors.elevated,
        borderRadius: BorderRadius.circular(SecuriaRadius.sm / 2),
      ),
    );

    return Semantics(
      label: 'Cargando la cola',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SecuriaSpace.md + 2),
        child: Column(
          children: [
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SecuriaSpace.sm),
                child: Row(
                  children: [
                    bar(UrgencyBar.width, 52),
                    const SizedBox(width: SecuriaSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bar(160, 14),
                          const SizedBox(height: SecuriaSpace.xs),
                          bar(220, 12),
                          const SizedBox(height: SecuriaSpace.xs),
                          bar(90, 10),
                        ],
                      ),
                    ),
                    bar(48, 14),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
