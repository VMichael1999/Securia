import 'package:flutter/material.dart';
import '../../../../app/theme/patrol_colors.dart';

/// Aviso breve en la parte superior del mapa.
///
/// Va arriba a propósito: un SnackBar inferior taparía el botón principal de
/// la intervención justo cuando el agente va a tocar el siguiente paso.
class StatusToast extends StatelessWidget {
  final String? message;

  const StatusToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final text = message;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child:
          text == null
              ? const SizedBox.shrink()
              : Container(
                key: ValueKey(text),
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: PatrolColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: PatrolColors.policeAccent,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PatrolColors.background.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: PatrolColors.policeAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: PatrolColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
