import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/strings/shift_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';
import '../../../../app/widgets/patrol_buttons.dart';
import '../../../auth/presentation/views/patrol_login_view.dart';
import '../../../catalog/presentation/views/component_catalog_view.dart';
import '../../../tactical_map/presentation/bloc/patrol_bloc.dart';
import '../../../tactical_map/presentation/bloc/patrol_event.dart';
import '../../../tactical_map/presentation/bloc/patrol_state.dart';

/// Turno: el código de la unidad en grande (como se dice por radio), el estado
/// de servicio como un interruptor que explica sus consecuencias y las cifras
/// de la guardia.
class ShiftView extends StatelessWidget {
  /// Reloj inyectable para el tiempo restante del turno
  final DateTime Function()? clock;

  const ShiftView({super.key, this.clock});

  Future<void> _endShift(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: PatrolColors.card,
            title: Text(
              ShiftStrings.endShiftTitle,
              style: PatrolTypography.titleLarge,
            ),
            content: Text(
              ShiftStrings.endShiftBody,
              style: PatrolTypography.bodyMedium,
            ),
            actionsPadding: const EdgeInsets.all(SecuriaSpace.md),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryActionButton(
                    label: ShiftStrings.endShiftKeep,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(height: SecuriaSpace.xs),
                  SecondaryActionButton(
                    label: ShiftStrings.endShift,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    context.read<PatrolBloc>().add(
      const PatrolChangeDutyStatus(PatrolStatus.fueraServicio),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatrolLoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatrolColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PatrolBloc, PatrolState>(
          builder: (context, state) {
            final unit = state.currentPatrol;
            final now = (clock ?? DateTime.now)();
            final start = state.shiftStartedAt ?? now;
            final end = start.add(PatrolState.shiftLength);
            final left = end.difference(now);
            final remaining = left.isNegative ? Duration.zero : left;
            final avg = state.averageArrival;
            final hhmm = DateFormat('HH:mm');
            final busy = state.activeDispatchedIncident != null;
            final radius = GeoUtils.formatDistance(state.radarRadiusKm);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                SecuriaSpace.md + 2,
                SecuriaSpace.md,
                SecuriaSpace.md + 2,
                SecuriaSpace.xl,
              ),
              children: [
                Text(unit.officerName, style: PatrolTypography.bodySmall),
                Semantics(
                  header: true,
                  child: Text(
                    unit.unitCode,
                    style: PatrolTypography.mono(
                      size: 40,
                    ).copyWith(height: 1.1),
                  ),
                ),
                const SizedBox(height: SecuriaSpace.md),

                _DutySwitch(
                  available: unit.status != PatrolStatus.fueraServicio,
                  locked: busy,
                  radius: radius,
                  onChanged:
                      (available) => context.read<PatrolBloc>().add(
                        PatrolChangeDutyStatus(
                          available
                              ? PatrolStatus.disponible
                              : PatrolStatus.fueraServicio,
                        ),
                      ),
                ),
                const SizedBox(height: SecuriaSpace.md - 2),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: SecuriaSpace.xs,
                  crossAxisSpacing: SecuriaSpace.xs,
                  childAspectRatio:
                      1.9 / MediaQuery.textScalerOf(context).scale(1),
                  children: [
                    _Stat(
                      '${state.shiftConcludedCount}',
                      ShiftStrings.statInterventions,
                    ),
                    _Stat(
                      avg == null
                          ? DispatchStrings.noValue
                          : DispatchStrings.minutes(
                            (avg.inSeconds / 60).ceil(),
                          ),
                      ShiftStrings.statAvgArrival,
                    ),
                    _Stat(radius, ShiftStrings.statRadius),
                    _Stat(
                      ShiftStrings.remaining(
                        remaining.inHours,
                        remaining.inMinutes % 60,
                      ),
                      ShiftStrings.statRemaining,
                    ),
                  ],
                ),
                const SizedBox(height: SecuriaSpace.md),

                _InfoRow(
                  label: ShiftStrings.shiftLabel,
                  value: '${hhmm.format(start)} – ${hhmm.format(end)}',
                  mono: true,
                ),
                _InfoRow(
                  label: ShiftStrings.location,
                  value: unit.location.address,
                ),
                const SizedBox(height: SecuriaSpace.md),

                SecondaryActionButton(
                  label: ShiftStrings.endShift,
                  icon: Icons.logout_rounded,
                  onPressed: busy ? null : () => _endShift(context),
                ),
                if (busy) ...[
                  const SizedBox(height: SecuriaSpace.xs),
                  Text(
                    ShiftStrings.endShiftLocked,
                    textAlign: TextAlign.center,
                    style: PatrolTypography.bodySmall,
                  ),
                ],
                if (kDebugMode) ...[
                  const SizedBox(height: SecuriaSpace.md),
                  TextButton(
                    onPressed:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ComponentCatalogView(),
                          ),
                        ),
                    style: TextButton.styleFrom(
                      foregroundColor: PatrolColors.inkMuted,
                      minimumSize: const Size.fromHeight(SecuriaTouch.min),
                    ),
                    child: const Text(ShiftStrings.catalog),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Estado de servicio: interruptor con su consecuencia explicada
class _DutySwitch extends StatelessWidget {
  final bool available;
  final bool locked;
  final String radius;
  final ValueChanged<bool> onChanged;

  const _DutySwitch({
    required this.available,
    required this.locked,
    required this.radius,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final radiusCorner = BorderRadius.circular(SecuriaRadius.lg);
    final body =
        locked
            ? ShiftStrings.dutyLocked
            : available
            ? ShiftStrings.dutyOnBody(radius)
            : ShiftStrings.dutyOffBody;

    return Semantics(
      toggled: available,
      enabled: !locked,
      label: available ? ShiftStrings.dutyOn : ShiftStrings.dutyOff,
      hint: body,
      excludeSemantics: true,
      child: Material(
        color: PatrolColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: radiusCorner,
          side: BorderSide(
            color: available ? PatrolColors.action : PatrolColors.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: radiusCorner,
          onTap: locked ? null : () => onChanged(!available),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SecuriaTouch.patrol + 8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(SecuriaSpace.md - 2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          available
                              ? ShiftStrings.dutyOn
                              : ShiftStrings.dutyOff,
                          style: PatrolTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(body, style: PatrolTypography.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: SecuriaSpace.sm),
                  Switch(
                    value: available,
                    onChanged: locked ? null : onChanged,
                    activeColor: PatrolColors.onAction,
                    activeTrackColor: PatrolColors.action,
                    inactiveThumbColor: PatrolColors.inkMuted,
                    inactiveTrackColor: PatrolColors.elevated,
                    trackOutlineColor: const WidgetStatePropertyAll(
                      PatrolColors.border,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(SecuriaSpace.sm),
        decoration: BoxDecoration(
          color: PatrolColors.card,
          borderRadius: BorderRadius.circular(SecuriaRadius.md + 2),
          border: Border.all(color: PatrolColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: PatrolTypography.mono(size: 24)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PatrolTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _InfoRow({required this.label, required this.value, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SecuriaSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PatrolTypography.bodySmall),
          const SizedBox(width: SecuriaSpace.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  mono
                      ? PatrolTypography.mono(size: 13)
                      : PatrolTypography.bodySmall.copyWith(
                        color: PatrolColors.inkSecondary,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
