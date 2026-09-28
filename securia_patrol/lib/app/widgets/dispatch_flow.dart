import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../strings/dispatch_strings.dart';
import '../theme/patrol_colors.dart';
import '../theme/patrol_typography.dart';

/// Pasos de la intervención en una línea: Aceptado · En camino · Llegué · Concluir.
///
/// Un solo color (verde) con check para lo hecho; el paso resaltado en blanco
/// es el que ejecuta el botón principal.
class DispatchFlow extends StatelessWidget {
  /// Índice del paso siguiente (0 a 3); los anteriores quedan hechos
  final int current;

  const DispatchFlow({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final steps = DispatchStrings.flowSteps;
    final style = PatrolTypography.caption;

    return Semantics(
      label:
          '${DispatchStrings.flowProgress(current + 1)}: ${steps[current.clamp(0, steps.length - 1)]}',
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: SecuriaSpace.xxs + 2,
        runSpacing: SecuriaSpace.xxs,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) Text('·', style: style),
            if (i < current)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: PatrolColors.action,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    steps[i],
                    style: style.copyWith(color: PatrolColors.action),
                  ),
                ],
              )
            else
              Text(
                steps[i],
                style: style.copyWith(
                  color:
                      i == current ? PatrolColors.ink : PatrolColors.inkMuted,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
