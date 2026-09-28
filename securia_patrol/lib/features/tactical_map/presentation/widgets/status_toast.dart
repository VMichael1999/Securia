import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/theme/patrol_colors.dart';
import '../../../../app/theme/patrol_typography.dart';

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
      duration: SecuriaMotion.of(context, SecuriaMotion.normal),
      child:
          text == null
              ? const SizedBox.shrink()
              : Semantics(
                key: ValueKey(text),
                liveRegion: true,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: SecuriaSpace.md,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SecuriaSpace.md,
                    vertical: SecuriaSpace.sm,
                  ),
                  decoration: BoxDecoration(
                    color: PatrolColors.elevated,
                    borderRadius: BorderRadius.circular(SecuriaRadius.md + 2),
                    border: Border.all(color: PatrolColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: PatrolColors.inkMuted,
                        size: 20,
                      ),
                      const SizedBox(width: SecuriaSpace.sm - 2),
                      Expanded(
                        child: Text(
                          text,
                          style: PatrolTypography.label.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
