import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securia_core/securia_core.dart';
import '../theme/patrol_colors.dart';
import '../theme/patrol_typography.dart';

/// Acción principal del patrullero: verde, 72 px de alto, siempre en el mismo
/// lugar. Se toca con guantes y se lee de reojo.
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  /// Explicación para lectores de pantalla
  final String? semanticHint;

  const PrimaryActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hint: semanticHint,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: SecuriaTouch.primaryAction,
        ),
        child: FilledButton(
          onPressed:
              onPressed == null
                  ? null
                  : () {
                    HapticFeedback.mediumImpact();
                    onPressed!();
                  },
          style: FilledButton.styleFrom(
            backgroundColor: PatrolColors.action,
            foregroundColor: PatrolColors.onAction,
            disabledBackgroundColor: PatrolColors.elevated,
            disabledForegroundColor: PatrolColors.inkMuted,
            minimumSize: const Size.fromHeight(SecuriaTouch.primaryAction),
            padding: const EdgeInsets.symmetric(
              horizontal: SecuriaSpace.md,
              vertical: SecuriaSpace.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SecuriaRadius.lg + 2),
            ),
            textStyle: PatrolTypography.actionLabel,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 28),
                const SizedBox(width: SecuriaSpace.sm - 2),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Acción secundaria: contorno, 64 px de alto
class SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const SecondaryActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: PatrolColors.ink,
        disabledForegroundColor: PatrolColors.inkMuted,
        minimumSize: const Size.fromHeight(SecuriaTouch.patrol),
        side: const BorderSide(color: PatrolColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SecuriaRadius.lg),
        ),
        textStyle: PatrolTypography.buttonLabel,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22),
            const SizedBox(width: SecuriaSpace.xs),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
