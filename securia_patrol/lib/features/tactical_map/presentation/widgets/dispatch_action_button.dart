import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../models/dispatch_step.dart';

/// Botón principal único de la intervención.
///
/// Siempre en el mismo lugar y del mismo tamaño; solo cambia su texto según el
/// paso: el agente no tiene que buscar qué tocar con el vehículo en marcha.
class DispatchActionButton extends StatelessWidget {
  final DispatchStep step;
  final VoidCallback onPressed;

  const DispatchActionButton({
    super.key,
    required this.step,
    required this.onPressed,
  });

  static const Map<DispatchStep, (String, String, IconData)> _content = {
    DispatchStep.accept: (
      DispatchStrings.actionAccept,
      DispatchStrings.actionHintAccept,
      Icons.flash_on_rounded,
    ),
    DispatchStep.onTheWay: (
      DispatchStrings.actionOnTheWay,
      DispatchStrings.actionHintOnTheWay,
      Icons.local_shipping_rounded,
    ),
    DispatchStep.arrived: (
      DispatchStrings.actionArrived,
      DispatchStrings.actionHintArrived,
      Icons.where_to_vote_rounded,
    ),
    DispatchStep.conclude: (
      DispatchStrings.actionConclude,
      DispatchStrings.actionHintConclude,
      Icons.task_alt_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final content = _content[step];
    if (content == null) return const SizedBox.shrink();
    final (label, hint, icon) = content;

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: PatrolColors.policeAccent,
          foregroundColor: PatrolColors.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      color: PatrolColors.background.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 26),
          ],
        ),
      ),
    );
  }
}
