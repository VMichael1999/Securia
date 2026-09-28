import 'package:flutter/material.dart';
import '../../../../app/strings/dispatch_strings.dart';
import '../../../../app/widgets/patrol_buttons.dart';
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
      Icons.check_rounded,
    ),
    DispatchStep.onTheWay: (
      DispatchStrings.actionOnTheWay,
      DispatchStrings.actionHintOnTheWay,
      Icons.navigation_rounded,
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

    return PrimaryActionButton(
      label: label,
      icon: icon,
      semanticHint: hint,
      onPressed: onPressed,
    );
  }
}
