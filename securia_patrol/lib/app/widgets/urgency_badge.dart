import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../theme/patrol_colors.dart';
import '../theme/patrol_typography.dart';
import 'dashed_rrect_painter.dart';

/// Urgencia legible sin depender del color: la palabra más una forma.
///
/// Crítica en bloque sólido, alta con contorno y media punteada.
class UrgencyBadge extends StatelessWidget {
  final UrgencyLevel urgency;
  final bool compact;

  const UrgencyBadge({super.key, required this.urgency, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final mark = UrgencyMark.of(urgency);
    final color = PatrolColors.urgency(urgency);
    final radius = BorderRadius.circular(SecuriaRadius.sm);
    final textColor =
        mark == UrgencyMark.solid ? PatrolColors.onCritical : color;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? SecuriaSpace.xs : SecuriaSpace.sm - 1,
        vertical: compact ? 3 : 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mark == UrgencyMark.solid) ...[
            Icon(
              Icons.warning_rounded,
              size: compact ? 14 : 16,
              color: textColor,
            ),
            const SizedBox(width: SecuriaSpace.xxs + 2),
          ],
          Text(
            urgency.label,
            style: PatrolTypography.caption.copyWith(
              color: textColor,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    final Widget badge = switch (mark) {
      UrgencyMark.solid => DecoratedBox(
        decoration: BoxDecoration(
          color: PatrolColors.criticalFill,
          borderRadius: radius,
        ),
        child: content,
      ),
      UrgencyMark.outline => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: color, width: 2),
        ),
        child: content,
      ),
      UrgencyMark.dashed => CustomPaint(
        painter: DashedRRectPainter(
          color: color,
          radius: SecuriaRadius.sm,
          strokeWidth: 1.5,
        ),
        child: content,
      ),
      UrgencyMark.none => content,
    };

    return Semantics(
      label: 'Urgencia ${urgency.label.toLowerCase()}',
      excludeSemantics: true,
      child: badge,
    );
  }
}

/// Barra lateral de urgencia de la cola: sólida, contorno o punteada
class UrgencyBar extends StatelessWidget {
  final UrgencyLevel urgency;

  const UrgencyBar({super.key, required this.urgency});

  static const double width = 6;

  @override
  Widget build(BuildContext context) {
    final color = PatrolColors.urgency(urgency);
    final radius = BorderRadius.circular(width / 2);

    return SizedBox(
      width: width,
      child: switch (UrgencyMark.of(urgency)) {
        UrgencyMark.solid => DecoratedBox(
          decoration: BoxDecoration(color: color, borderRadius: radius),
        ),
        UrgencyMark.outline => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color, width: 2),
          ),
        ),
        UrgencyMark.dashed || UrgencyMark.none => CustomPaint(
          painter: DashedRRectPainter(
            color: color,
            radius: width / 2,
            strokeWidth: 1.5,
          ),
        ),
      },
    );
  }
}
