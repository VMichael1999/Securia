import 'package:flutter/material.dart';
import 'package:securia_core/securia_core.dart';
import '../../../../app/strings/sos_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import 'hold_sos_button.dart';

/// Controles flotantes sobre el mapa, siempre en el mismo lugar y al alcance
/// del pulgar: el SOS (lo único rojo) y un segundo botón.
///
/// El segundo botón es "Reportar incidente"; si la ubicación no es confiable
/// pasa a ser "Llamar 105", que no depende del GPS.
class SosActionPanel extends StatelessWidget {
  final bool isSending;
  final bool locationReliable;
  final VoidCallback onSosTriggered;
  final ValueChanged<double>? onHoldProgress;
  final VoidCallback onReport;
  final VoidCallback onCall;

  const SosActionPanel({
    super.key,
    required this.isSending,
    required this.locationReliable,
    required this.onSosTriggered,
    required this.onReport,
    required this.onCall,
    this.onHoldProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HoldSosButton(
          isSending: isSending,
          onTriggered: onSosTriggered,
          onHoldProgress: onHoldProgress,
        ),
        const SizedBox(height: SecuriaSpace.xs),
        locationReliable
            ? _PillButton(
                label: SosStrings.reportButton,
                icon: Icons.edit_note_rounded,
                onPressed: isSending ? null : onReport,
              )
            : _PillButton(
                label: SosStrings.call105,
                icon: Icons.call_rounded,
                onPressed: onCall,
              ),
      ],
    );
  }
}

/// Botón blanco con borde, para que el rojo del SOS siga siendo lo único que
/// destaca en la zona del pulgar
class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.ink.withValues(alpha: 0.25),
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SecuriaTouch.min + 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SecuriaSpace.xl),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.ink, size: 22),
                const SizedBox(width: SecuriaSpace.xs),
                Text(label, style: AppTypography.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
